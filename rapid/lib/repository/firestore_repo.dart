import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rapid/model/bundesland.dart';
import 'package:rapid/model/rapid_test.dart';
import 'package:intl/intl.dart';

import 'firebase_storage_repo.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class FireStoreRepo {
  final CollectionReference usersCollection = firestore.collection('users');

  final CollectionReference titleCollection = firestore.collection('titles');

  final CollectionReference testKitsCollection = firestore.collection('tests');

  final CollectionReference bundeslandCollection =
      firestore.collection('bundeslaender');

  final CollectionReference certificatesCollection =
      firestore.collection('certificates');

  Future<void> addUser(
      String uid,
      String email,
      String firstName,
      String lastName,
      String? postalCode,
      String? city,
      String? bundesland,
      bool isDeutschlandUpdates) {
    return usersCollection
        .doc(uid)
        .set({
          'uid': uid,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'postalCode': postalCode,
          'city': city,
          'bundesland': bundesland,
          'imagePath': null,
          'testKitUID': '',
          'isDeutschlandUpdates': isDeutschlandUpdates,
          'deviceToken': '',
        })
        .whenComplete(() => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> addNewTest(
      String testKitStage, DocumentSnapshot userSnapshot, File imageFile) {
    String userID = userSnapshot['uid'];
    DocumentReference newTestRef = testKitsCollection.doc();

    return FirebaseStorageRepo()
        .uploadTestKitWithMetadata(
            imageFile, userSnapshot, testKitStage, newTestRef.id)
        .whenComplete(() async => newTestRef.set({
              'testKitUID': newTestRef.id,
              'userID': userID,
              'testKitStage': testKitStage,
              'imagePath': await FirebaseStorageRepo()
                  .getDownloadURL(userSnapshot, newTestRef.id),
              'label': '',
              'barCode': null,
              'validBarCode': false,
              'completed': false,
              'predicting': false,
              'created':
                  DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now()),
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }).whenComplete(() {
              updateUser(userID, 'testKitUID', newTestRef.id, null);
            }).catchError(
                (error) => print("Failed to add new test kit: $error")));
  }

  Future<void> addCertificate(String testID, bool expired, String userID,
      String certificateName, String expiringDate) {
    return certificatesCollection.doc().set({
      'testID': testID,
      'userID': userID,
      'expired': expired,
      'certificateName': certificateName,
      'expiringDate': expiringDate,
    });
  }

  Future<void> deleteTestKit(String testKitID) {
    return testKitsCollection.doc(testKitID).delete();
  }

  Future updateUser(String currentUserID, String field, String? newValueString,
      bool? newValueBool) async {
    final QuerySnapshot result = await usersCollection
        .where('uid', isEqualTo: currentUserID)
        .limit(1)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    for (DocumentSnapshot document in documents) {
      String documentID = document.id;
      usersCollection.doc(documentID).update(
          {field: (newValueBool == null) ? newValueString : newValueBool});
    }
  }

  Future updateTestKit(
      String testKitID, String field, String? newValue, bool resetLabel) async {
    final QuerySnapshot result = await testKitsCollection
        .where('testKitUID', isEqualTo: testKitID)
        .limit(1)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    for (DocumentSnapshot document in documents) {
      String documentID = document.id;

      DocumentReference documentReference = testKitsCollection.doc(documentID);

      resetLabel
          ? documentReference.update({field: newValue, 'label': ""})
          : documentReference.update({field: newValue});
    }
  }

  Future updateBoolTestKit(
      String testKitID, String field, bool newValue) async {
    final QuerySnapshot result = await testKitsCollection
        .where('testKitUID', isEqualTo: testKitID)
        .limit(1)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    for (DocumentSnapshot document in documents) {
      String documentID = document.id;

      DocumentReference documentReference = testKitsCollection.doc(documentID);

      documentReference.update({field: newValue});
    }
  }

  Future<bool> checkForEmail(String email) async {
    bool exists = false;
    final QuerySnapshot result =
        await usersCollection.where('email', isEqualTo: email).get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.length == 1) {
      exists = true;
    } else {
      exists = false;
    }
    return exists;
  }

  Stream<QuerySnapshot> getUser(String uid) {
    Stream<QuerySnapshot> userStream;

    userStream = usersCollection.where('uid', isEqualTo: uid).snapshots();

    return userStream;
  }

  Future<RapidTest?> getTestKit(String? userUID) async {
    RapidTest? testKit;

    final QuerySnapshot result = await testKitsCollection
        .where("userID", isEqualTo: userUID)
        .where("completed", isEqualTo: false)
        .limit(1)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    documents.forEach((DocumentSnapshot nonJsonDocument) {
      Map<String, dynamic> document =
          jsonDecode(jsonEncode(nonJsonDocument.data()));
      testKit = RapidTest.fromJson(document);
    });
    return testKit;
  }

  Future<List<Bundesland?>> getBundesland(String query) async {
    List listOfBundeslaender = [];

    final QuerySnapshot result = await bundeslandCollection.get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.isNotEmpty) {
      documents.forEach((DocumentSnapshot nonJsonDocument) {
        final document = jsonDecode(jsonEncode(nonJsonDocument.data()));
        listOfBundeslaender.add(document);
      });

      return listOfBundeslaender
          .map((json) => Bundesland.fromJson(json))
          .where((document) {
        final nameLower = document.name.toLowerCase();
        final queryLower = query.toLowerCase();

        return nameLower.contains(queryLower) && nameLower != "deutschland";
      }).toList();
    } else {
      throw Exception();
    }
  }

  Stream<QuerySnapshot> getCoronaTilesTitle() {
    return titleCollection.orderBy('orderBy').snapshots();
  }

  Stream<DocumentSnapshot> getCoronaInfo(String? bundesland) {
    return bundeslandCollection.doc(bundesland).snapshots();
  }

  Stream<QuerySnapshot> getTestKitStream(String testKitID) {
    return testKitsCollection
        .where('testKitUID', isEqualTo: testKitID)
        .snapshots();
  }

  Stream<QuerySnapshot> getCertificateStream(String userID, int index) {
    bool expired = (index == 0) ? false : true;
    return certificatesCollection
        .where('userID', isEqualTo: userID)
        .where('expired', isEqualTo: expired)
        .snapshots();
  }

  Stream<QuerySnapshot> getActiveCertificateStream(String userID) {
    return certificatesCollection
        .where('userID', isEqualTo: userID)
        .where('expired', isEqualTo: false)
        .snapshots();
  }
}

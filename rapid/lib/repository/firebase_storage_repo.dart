import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:firebase_storage/firebase_storage.dart";

FirebaseStorage storage = FirebaseStorage.instance;

class FirebaseStorageRepo {
  Future<void> uploadProfilePictureWithMetadata(
      File file, DocumentSnapshot userSnapshot) async {
    SettableMetadata metadata = SettableMetadata(
      cacheControl: 'max-age=60',
      customMetadata: <String, String>{
        'uid': userSnapshot['uid'],
        'email': userSnapshot['email'],
      },
    );
    try {
      await storage
          .ref()
          .child('profilePictures')
          .child('${userSnapshot['uid']}')
          .putFile(file, metadata);
    } on FirebaseException catch (e) {
      print(e.code);
    }
  }

  Future<void> uploadTestKitWithMetadata(
      File file,
      DocumentSnapshot userSnapshot,
      String testkitStage,
      String testKitUID) async {
    SettableMetadata metadata = SettableMetadata(
      cacheControl: 'max-age=60',
      customMetadata: <String, String>{
        'testKitUID': testKitUID,
        'userID': userSnapshot['uid'],
        'userEmail': userSnapshot['email'],
        'testkitStage': testkitStage,
      },
    );

    UploadTask task = storage
        .ref()
        .child('tests')
        .child('${userSnapshot['uid']}')
        .child(testKitUID)
        .putFile(file, metadata);

    try {
      await task;
    } on FirebaseException catch (e) {
      print(e.code);
    }
  }

  Future<String?> getMetadata(
      DocumentSnapshot userSnapshot, String getField, String testKitUID) async {
    FullMetadata metadata = await storage
        .ref()
        .child('tests')
        .child('${userSnapshot['uid']}')
        .child(testKitUID)
        .getMetadata();

    String? value = metadata.customMetadata![getField];

    return value;
  }

  Future<String?> getDownloadURL(
      DocumentSnapshot userSnapshot, String testKitUID) async {
    String downloadURL = await storage
        .ref()
        .child('tests')
        .child('${userSnapshot['uid']}')
        .child(testKitUID)
        .getDownloadURL();

    return downloadURL;
  }

  Future<void> deleteFile(
      DocumentSnapshot userSnapshot, String testKitUID) async {
    await storage
        .ref()
        .child('tests')
        .child('${userSnapshot['uid']}')
        .child(testKitUID)
        .delete();
  }
}

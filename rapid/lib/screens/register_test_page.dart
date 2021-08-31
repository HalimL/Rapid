import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid/model/rapid_test.dart';
import 'package:rapid/repository/firebase_storage_repo.dart';
import 'package:rapid/repository/firestore_repo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rapid/screens/verify_test.dart';

import 'package:rapid/styling/styling_constants.dart';
import 'package:rapid/widgets/appbar_widget.dart';
import 'package:rapid/widgets/test_page_shimmer.dart';

class RegisterTest extends StatefulWidget {
  @override
  RegisterTestState createState() => RegisterTestState();
}

class RegisterTestState extends State<RegisterTest> {
  late DocumentSnapshot currentUserSnapshot;
  DocumentSnapshot? currentTestKitSnapshot;

  bool imageSelected = false;

  RapidTest _testKit = RapidTest();
  final String testKitStage = 'initial';

  @override
  void initState() {
    super.initState();
  }

  Future<RapidTest?> getTestKit(String? userUID) {
    return FireStoreRepo().getTestKit(userUID);
  }

  Stream<QuerySnapshot> getTestKitStream(String testKitID) {
    return FireStoreRepo().getTestKitStream(testKitID);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuerySnapshot?>(builder: (context, userSnapshot, child) {
      currentUserSnapshot = userSnapshot!.docs.single;

      return Scaffold(
        appBar: buildAppBar(context),
        body: FutureBuilder(
            future: getTestKit(currentUserSnapshot['uid']),
            builder: (_, futureSnapshot) {
              if (futureSnapshot.hasData &&
                  futureSnapshot.connectionState == ConnectionState.done) {
                _testKit = futureSnapshot.data as RapidTest;
                return StreamBuilder(
                    stream: getTestKitStream(_testKit.testKitUID!),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> testKitSnapshot) {
                      if (testKitSnapshot.hasData) {
                        currentTestKitSnapshot =
                            testKitSnapshot.data!.docs.single;

                        return DelayedDisplay(
                          child: Column(
                            children: [
                              _buildHeading(),
                              SizedBox(
                                height: 40,
                              ),
                              _buildInstructions(),
                              SizedBox(
                                height: 40,
                              ),
                              _buildPredictionNotification(
                                  context,
                                  currentUserSnapshot,
                                  testKitStage,
                                  currentTestKitSnapshot),
                              SizedBox(
                                height: 80,
                              ),
                              _buildReadInstructions(context),
                              SizedBox(
                                height: 80,
                              ),
                              _buildNextButton(
                                  context,
                                  currentTestKitSnapshot!['label'],
                                  currentTestKitSnapshot!['testKitUID'],
                                  currentTestKitSnapshot!['predicting']),
                              _buildRetryButton(
                                  currentTestKitSnapshot!['label'],
                                  currentUserSnapshot,
                                  currentTestKitSnapshot!['testKitUID'],
                                  currentTestKitSnapshot!['predicting']),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        );
                      }
                    });
              } else if (!futureSnapshot.hasData &&
                  futureSnapshot.connectionState == ConnectionState.done &&
                  !imageSelected) {
                return DelayedDisplay(
                  child: Column(
                    children: [
                      _buildHeading(),
                      SizedBox(
                        height: 40,
                      ),
                      _buildInstructions(),
                      SizedBox(
                        height: 200,
                      ),
                      _buildReadInstructions(context),
                      SizedBox(
                        height: 80,
                      ),
                      _buildTakePhotoButton(
                          context, currentTestKitSnapshot, currentUserSnapshot),
                    ],
                  ),
                );
              } else if (!futureSnapshot.hasData &&
                  imageSelected &&
                  futureSnapshot.connectionState == ConnectionState.done) {
                return Column(
                  children: [
                    _buildHeading(),
                    SizedBox(
                      height: 40,
                    ),
                    _buildInstructions(),
                    SizedBox(
                      height: 40,
                    ),
                    _buildSubmittingProcess(context),
                    SizedBox(
                      height: 80,
                    ),
                    _buildReadInstructions(context),
                  ],
                );
              } else {
                return _buildRegisterTestScreenShimmer();
              }
            }),
      );
    });
  }

  Widget _buildHeading() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 30.0, 0.0, 10.0),
          child: Text(
            'Register Test Kit',
            style: StylingConstants().titleTextTextStyle(),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10.0, 40.0, 0.0, 10.0),
          child: Icon(
            Icons.verified_sharp,
            color: Colors.green,
            size: 50,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 20.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text:
              "Register your corona test kit by taking a picture of your test kit. Make sure the picture is visible and clear.",
          style: StylingConstants().inputTextTextStyle(),
        ),
      ),
    );
  }

  Widget _buildReadInstructions(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 42,
        ),
        Icon(
          CupertinoIcons.doc_text,
          color: Color.fromRGBO(100, 149, 237, 1.0),
        ),
        SizedBox(
          width: 2,
        ),
        RichText(
          text: TextSpan(
              text: "Instructions",
              style: StylingConstants().clickableTextTextStyleActive(),
              recognizer: TapGestureRecognizer()..onTap = () {}),
        ),
      ],
    );
  }

  Widget _buildRegisterTestScreenShimmer() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 60,
          ),
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              TestPageShimmer.title(width: 220, height: 50),
              SizedBox(
                width: 20,
              ),
              TestPageShimmer.circle(width: 50, height: 50),
            ],
          ),
          SizedBox(
            height: 60,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 10.0),
            child: TestPageShimmer.title(width: double.infinity, height: 20),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 10.0),
            child: TestPageShimmer.title(width: double.infinity, height: 20),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(60.0, 0.0, 60.0, 10.0),
            child: TestPageShimmer.title(width: double.infinity, height: 20),
          ),
          SizedBox(
            height: 180,
          ),
          Row(
            children: [
              SizedBox(
                width: 42,
              ),
              TestPageShimmer.title(width: 20, height: 20),
              SizedBox(
                width: 10,
              ),
              TestPageShimmer.title(width: 180, height: 20),
            ],
          ),
          SizedBox(
            height: 100,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(42.0, 0.0, 42.0, 0.0),
            child: TestPageShimmer.title(width: double.infinity, height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildTakePhotoButton(BuildContext context,
      DocumentSnapshot? testKitSnapshot, DocumentSnapshot userSnapshot) {
    return Visibility(
      visible: (testKitSnapshot == null) && (!imageSelected),
      child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 311,
              height: 40,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: StylingConstants().greenButtonColorEnabled,
                  elevation: StylingConstants().buttonElevation,
                ),
                onPressed: () {
                  uploadImage(userSnapshot, testKitStage);
                },
                child: Text(
                  'Take Photo',
                  style: StylingConstants().buttonTextTextStyle(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmittingProcess(
    BuildContext context,
  ) {
    return Column(
      children: [
        CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          'submitting test kit...',
          style: StylingConstants().notificationTextTextStyle('success'),
        ),
      ],
    );
  }

  Widget _buildPredictionNotification(
      BuildContext context,
      DocumentSnapshot userSnapshot,
      String testKitStage,
      DocumentSnapshot? testKitSnapshot) {
    if (testKitSnapshot != null) {
      String testLabel = testKitSnapshot['label'];
      bool predicting = testKitSnapshot['predicting'];

      if (testLabel == testKitStage && !predicting) {
        return Column(
          children: [
            buildImage('assets/icons8_checkmark_144.png'),
            SizedBox(
              height: 10,
            ),
            Text(
              'test kit succesfully registered',
              style: StylingConstants().notificationTextTextStyle('success'),
            ),
          ],
        );
      } else if (predicting && testLabel.isEmpty) {
        return Column(
          children: [
            CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'registering test kit...',
              style: StylingConstants().notificationTextTextStyle('success'),
            ),
          ],
        );
      } else if (!predicting &&
          testLabel != testKitStage &&
          testLabel.isNotEmpty) {
        return Column(
          children: [
            buildImage('assets/icons8_cross_mark_96.png'),
            SizedBox(
              height: 10,
            ),
            Text(
              'failed to register test kit',
              style: StylingConstants().notificationTextTextStyle('error'),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            SizedBox(
              height: 30,
            ),
            CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        );
      }
    } else {
      return Scaffold();
    }
  }

  Widget _buildNextButton(BuildContext context, String testLabel,
      String testKitUID, bool predicting) {
    return Visibility(
      visible: (testLabel == testKitStage && !predicting) ? true : false,
      child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 311,
              height: 40,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: StylingConstants().greenButtonColorEnabled,
                  elevation: StylingConstants().buttonElevation,
                ),
                onPressed: () async => {
                  FireStoreRepo()
                      .updateTestKit(
                          testKitUID, 'testKitStage', 'verify', false)
                      .whenComplete(() => FireStoreRepo()
                          .updateTestKit(testKitUID, 'label', '', false))
                      .whenComplete(() =>
                          navigateToVerifyTest(context, currentUserSnapshot))
                },
                child: Text(
                  'Next',
                  style: StylingConstants().buttonTextTextStyle(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton(String testLabel, DocumentSnapshot userSnapshot,
      String testKitUID, bool predicting) {
    return Visibility(
      visible:
          (testLabel.isNotEmpty && testLabel != testKitStage && !predicting)
              ? true
              : false,
      child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 311,
              height: 40,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: StylingConstants().greenButtonColorEnabled,
                  elevation: StylingConstants().buttonElevation,
                ),
                onPressed: () {
                  reUploadImage(userSnapshot, testKitStage, testKitUID);
                },
                child: Text(
                  'Retry',
                  style: StylingConstants().buttonTextTextStyle(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCircle(
      {required Color color, required double all, required Widget child}) {
    return ClipOval(
      child: Container(
        padding: EdgeInsets.all(all),
        color: color,
        child: child,
      ),
    );
  }

  Widget buildImage(String image) {
    return Image.asset(
      image,
      height: 50,
      width: 50,
    );
  }

  void uploadImage(DocumentSnapshot userSnapshot, String testKitStage) async {
    final picker =
        // ideally we want to use the camera as our image source
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (picker == null) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final name = basename(picker.path);
    final imageFile = File('${directory.path}/$name');
    final newImage = await File(picker.path).copy(imageFile.path);

    setState(() {
      imageSelected = true;
    });

    FireStoreRepo().addNewTest(testKitStage, userSnapshot, imageFile);
  }

  void reUploadImage(DocumentSnapshot userSnapshot, String testKitStage,
      String testKitUID) async {
    final picker =
        // ideally we want to use the camera as our image source
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (picker == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final name = basename(picker.path);
    final imageFile = File('${directory.path}/$name');
    final newImage = await File(picker.path).copy(imageFile.path);

    setState(() {
      imageSelected = true;
    });

    String? path =
        await FirebaseStorageRepo().getDownloadURL(userSnapshot, testKitUID);

    FireStoreRepo()
        .updateTestKit(testKitUID, 'imagePath', path, true)
        .whenComplete(() => FirebaseStorageRepo().uploadTestKitWithMetadata(
            imageFile, userSnapshot, testKitStage, testKitUID));
  }

  void navigateToVerifyTest(
      BuildContext context, DocumentSnapshot? currentUserSnapshot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyTest(
          initTimer: true,
          userSnapshot: currentUserSnapshot,
        ),
      ),
    );
  }
}

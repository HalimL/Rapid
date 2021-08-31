import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid/model/rapid_test.dart';
import 'package:rapid/repository/firestore_repo.dart';

import 'package:rapid/screens/register_test_page.dart';
import 'package:rapid/screens/test_result.dart';
import 'package:rapid/screens/verify_test.dart';
import 'package:rapid/styling/styling_constants.dart';
import 'package:rapid/widgets/test_page_shimmer.dart';

class TestProgress extends StatefulWidget {
  @override
  TestProgressState createState() => TestProgressState();
}

class TestProgressState extends State<TestProgress> {
  late DocumentSnapshot currentUserSnapshot;

  RapidTest _testKit = RapidTest();

  Future<RapidTest?> getTestKit(String? userUID) {
    return FireStoreRepo().getTestKit(userUID);
  }

  Stream<QuerySnapshot> getTestKitStream(String testKitID) {
    return FireStoreRepo().getTestKitStream(testKitID);
  }

  Stream<QuerySnapshot> getActiveCertificateStream(String userID) {
    return FireStoreRepo().getActiveCertificateStream(userID);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuerySnapshot?>(builder: (context, userSnapshot, child) {
      currentUserSnapshot = userSnapshot!.docs.single;
      return Scaffold(
        body: FutureBuilder(
          future: getTestKit(currentUserSnapshot['uid']),
          builder: (_, futureSnapshot) {
            if (futureSnapshot.hasData) {
              _testKit = futureSnapshot.data as RapidTest;
              return _buildOnGoingTestScreeen(
                  context, _testKit, currentUserSnapshot);
            } else if (!futureSnapshot.hasData) {
              return _buildInitialScreeen(context,
                  getActiveCertificateStream(currentUserSnapshot['uid']));
            } else {
              return Container();
            }
          },
        ),
      );
    });
  }
}

Widget _buildInitialScreeen(
    BuildContext context, Stream<QuerySnapshot> certificateStream) {
  return StreamBuilder(
      stream: certificateStream,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot> certificateSnapshot) {
        if (certificateSnapshot.hasData &&
            certificateSnapshot.data!.docs.isNotEmpty) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                _buildImage('rapid-testing.jpg'),
                SizedBox(
                  height: 80,
                ),
                _buildNotice(context),
                SizedBox(
                  height: 140,
                ),
                _buildReadInstructions(context),
                SizedBox(
                  height: 60,
                ),
              ],
            ),
          );
        } else if (!certificateSnapshot.hasData ||
            certificateSnapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                _buildImage('rapid-testing.jpg'),
                SizedBox(
                  height: 40,
                ),
                _buildTestInstructions(context),
                SizedBox(
                  height: 140,
                ),
                _buildReadInstructions(context),
                SizedBox(
                  height: 60,
                ),
                _buildStartTestButton(context, 'Start Test', null, null),
              ],
            ),
          );
        } else {
          return _buildStartTestScreenShimmer();
        }
      });
}

Widget _buildOnGoingTestScreeen(BuildContext context, RapidTest currentTestKit,
    DocumentSnapshot currentUser) {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 100,
        ),
        _buildImage('rapid-testing.jpg'),
        SizedBox(
          height: 40,
        ),
        _buildContinueText(context),
        SizedBox(
          height: 140,
        ),
        _buildReadInstructions(context),
        SizedBox(
          height: 60,
        ),
        _buildStartTestButton(
            context, 'Continue Test', currentUser, currentTestKit),
      ],
    ),
  );
}

Widget _buildStartTestScreenShimmer() {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 100,
        ),
        TestPageShimmer.circle(width: 200, height: 200),
        SizedBox(
          height: 40,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(42.0, 0.0, 42.0, 10.0),
          child: TestPageShimmer.title(width: double.infinity, height: 20),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 10.0),
          child: TestPageShimmer.title(width: double.infinity, height: 20),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(56.0, 0.0, 56.0, 10.0),
          child: TestPageShimmer.title(width: double.infinity, height: 20),
        ),
        SizedBox(
          height: 140,
        ),
        Row(
          children: [
            SizedBox(
              width: 42,
            ),
            TestPageShimmer.title(width: 180, height: 20),
          ],
        ),
        SizedBox(
          height: 60,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(42.0, 0.0, 42.0, 0.0),
          child: TestPageShimmer.title(width: double.infinity, height: 40),
        ),
      ],
    ),
  );
}

Widget _buildImage(String imageFile) {
  return ClipOval(
    child: Material(
      color: Colors.transparent,
      child: Ink.image(
        image: AssetImage('assets/$imageFile'),
        fit: BoxFit.cover,
        width: 200,
        height: 200,
      ),
    ),
  );
}

Widget _buildTestInstructions(BuildContext context) {
  return Padding(
    padding: EdgeInsets.fromLTRB(42.0, 0.0, 42.0, 0.0),
    child: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text:
            "Read the instructions carefully then click on the Start Test button to begin a new corona rapid test.",
        style: StylingConstants().inputTextTextStyle(),
      ),
    ),
  );
}

Widget _buildNotice(BuildContext context) {
  return Padding(
    padding: EdgeInsets.fromLTRB(42.0, 0.0, 42.0, 0.0),
    child: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text:
            "You can only start a new rapid test after the certificate of your previous rapid test has expired.",
        style: StylingConstants().redSubtitleTextTextStyle(),
      ),
    ),
  );
}

Widget _buildContinueText(BuildContext context) {
  return Padding(
    padding: EdgeInsets.fromLTRB(42.0, 0.0, 42.0, 0.0),
    child: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "Continue your corona test where you left off.",
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

Widget _buildStartTestButton(
  BuildContext context,
  String testProgress,
  DocumentSnapshot? currentUserSnapshot,
  RapidTest? testKit,
) {
  return Container(
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
              if (testKit != null) {
                if (testKit.testKitStage == "initial") {
                  navigateToRegisterTest(context);
                } else if (testKit.label == 'positive' ||
                    testKit.label == 'negative') {
                  navigateToViewResults(context, testKit, currentUserSnapshot!);
                } else {
                  navigateToVerifyTest(context, currentUserSnapshot);
                }
              } else {
                navigateToRegisterTest(context);
              }
            },
            child: Text(
              testProgress,
              style: StylingConstants().buttonTextTextStyle(),
            ),
          ),
        ),
      ],
    ),
  );
}

void navigateToRegisterTest(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RegisterTest(),
    ),
  );
}

void navigateToVerifyTest(
    BuildContext context, DocumentSnapshot? currentUserSnapshot) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VerifyTest(
        initTimer: false,
        userSnapshot: currentUserSnapshot,
      ),
    ),
  );
}

void navigateToViewResults(
    BuildContext context, RapidTest testKit, DocumentSnapshot userSnapshot) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => TestResult(
              testKit: testKit,
              userSnapshot: userSnapshot,
            )),
  );
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:path/path.dart';
import 'package:rapid/repository/firebase_storage_repo.dart';

import 'dart:math' as math;

import 'package:rapid/repository/firestore_repo.dart';
import 'package:rapid/screens/test_progress.dart';
import 'package:rapid/screens/test_result.dart';
import 'package:rapid/styling/styling_constants.dart';
import 'package:rapid/utils/app_preferences.dart';

class VerifyTest extends StatefulWidget {
  final bool initTimer;
  final DocumentSnapshot? userSnapshot;

  VerifyTest({Key? key, required this.initTimer, required this.userSnapshot})
      : super(key: key);

  @override
  _VerifyTestState createState() => _VerifyTestState();
}

class _VerifyTestState extends State<VerifyTest>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController controller;
  late Stream<QuerySnapshot>? testKitStream;

  static const double controllerValueQuarterMarkUpperBound = 0.2500494999999999;
  static const double controllerValueQuarterMarkLowerBound =
      0.24977913333333335;
  static const double controllerValueHalfMarkUpperBound = 0.5001335833333334;
  static const double controllerValueHalfMarkLowerBound = 0.4998551;

  bool? counterInProgress;
  double? oldControllerValue;
  DateTime? detachedTime;

  Stream<QuerySnapshot> getTestKitStream(String testKitID) {
    return FireStoreRepo().getTestKitStream(testKitID);
  }

  String get timerString {
    Duration duration = controller.duration! * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void addControllerListerner(String testKitUID) {
    controller.addStatusListener(
      (status) {
        if (status == AnimationStatus.dismissed) {
          AppPreferences.setCounterCompleted(true).whenComplete(() =>
              FireStoreRepo().updateTestKit(testKitUID, 'label', '', false));
          setState(() {});
        }
      },
    );
  }

  void timerValueTracker(DocumentSnapshot testKitSnapshot) {
    controller.addListener(() {
      if ((controller.value < controllerValueQuarterMarkUpperBound &&
              controller.value > controllerValueQuarterMarkLowerBound) ||
          controller.value < controllerValueHalfMarkUpperBound &&
              controller.value > controllerValueHalfMarkLowerBound) {
        setState(() {});
      } else if (testKitSnapshot['label'] == 'positive' ||
          testKitSnapshot['label'] == 'negative') {
        controller.stop();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    testKitStream = getTestKitStream(widget.userSnapshot!['testKitUID']);
    controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: 1),
    );

    if (widget.initTimer == true) {
      this.controller.value = 0;
      startCounting(controller);
    } else {
      setupControllerValuePreferences(
          this.controller, this.oldControllerValue, this.detachedTime);
      setupTimerCounterPreferences(this.controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      body: DelayedDisplay(
        child: Padding(
          padding: EdgeInsets.fromLTRB(40.0, 100.0, 40.0, 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildReminder(controller.value),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.topCenter,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: controller,
                            builder: (BuildContext context, Widget? child) {
                              return CustomPaint(
                                  painter: TimerPainter(
                                animation: controller,
                                backgroundColor: (controller.value <
                                            controllerValueHalfMarkUpperBound &&
                                        controller.value >
                                            controllerValueQuarterMarkUpperBound)
                                    ? Colors.orange.shade600
                                    : (controller.value >
                                            controllerValueHalfMarkUpperBound)
                                        ? Colors.green
                                        : Colors.red,
                                color: Colors.white,
                              ));
                            },
                          ),
                        ),
                        Align(
                          alignment: FractionalOffset.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                  (AppPreferences.getCounterCompleted() !=
                                              null &&
                                          AppPreferences.getCounterCompleted()!)
                                      ? "Time Up"
                                      : "Count Down",
                                  style: (controller.value >
                                          controllerValueHalfMarkUpperBound)
                                      ? themeData.textTheme.subtitle1!
                                          .apply(color: Colors.green)
                                      : (controller.value <
                                              controllerValueQuarterMarkUpperBound)
                                          ? themeData.textTheme.subtitle1!
                                              .apply(color: Colors.red)
                                          : themeData.textTheme.subtitle1!
                                              .apply(
                                              color: Colors.orange[600],
                                            )),
                              AnimatedBuilder(
                                  animation: controller,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Text(timerString,
                                        style: (controller.value >
                                                controllerValueHalfMarkUpperBound)
                                            ? themeData.textTheme.headline1!
                                                .apply(color: Colors.green)
                                            : (controller.value <
                                                    controllerValueQuarterMarkUpperBound)
                                                ? themeData.textTheme.headline1!
                                                    .apply(color: Colors.red)
                                                : themeData.textTheme.headline1!
                                                    .apply(
                                                    color: Colors.orange[600],
                                                  ));
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              StreamBuilder(
                  stream: testKitStream,
                  builder: (_, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.hasData) {
                      DocumentSnapshot testKitSnapshot =
                          streamSnapshot.data!.docs.single;
                      addControllerListerner(testKitSnapshot['testKitUID']);
                      timerValueTracker(testKitSnapshot);
                      return buildBody(
                          context,
                          testKitSnapshot,
                          widget.userSnapshot!,
                          AppPreferences.getCounterCompleted());
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
        print('detached');
        break;
      case AppLifecycleState.paused:
        print('paused');
        break;
      case AppLifecycleState.resumed:
        print('resumed');
        break;
      case AppLifecycleState.inactive:
        DateTime currentTime = new DateTime.now().toLocal();
        await AppPreferences.setControllerValue(controller.value);
        await AppPreferences.setDetachedTime(currentTime.toString());
        print('inactive');
        break;
    }
  }

  Widget buildBody(BuildContext context, DocumentSnapshot testKitSnapshot,
      DocumentSnapshot userSnapshot, bool? counterCompleted) {
    bool counterInProgress =
        (counterCompleted != null) ? !counterCompleted : true;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        buildInstructions(counterInProgress, testKitSnapshot),
        buildVerifyImageButton(context, userSnapshot['testKitUID'],
            testKitSnapshot, userSnapshot, counterInProgress),
      ],
    );
  }

  Widget buildInstructions(
      bool counterInProgress, DocumentSnapshot testKitSnapshot) {
    if (counterInProgress && testKitSnapshot['label'] == '') {
      return Container(
        margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 80.0),
        child: Text(
          'Make sure you verify your test kit before the timer runs out.',
          style: StylingConstants().greenSubtitleTextTextStyle(),
          textAlign: TextAlign.center,
        ),
      );
    } else if (counterInProgress && testKitSnapshot['label'] == 'positive' ||
        testKitSnapshot['label'] == 'negative') {
      return Container(
        margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 100.0),
        child: Text(
          'Test kit verified successfully, view your test result.',
          style: StylingConstants().greenSubtitleTextTextStyle(),
          textAlign: TextAlign.center,
        ),
      );
    } else if (counterInProgress && testKitSnapshot['label'] == 'initial' ||
        testKitSnapshot['label'] == 'invalid') {
      return Container(
        margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 80.0),
        child: Text(
          "Couldn't verify test kit, please retake a picture of your test kit.",
          style: StylingConstants().greenSubtitleTextTextStyle(),
          textAlign: TextAlign.center,
        ),
      );
    } else if (!counterInProgress) {
      return Container(
        margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 80.0),
        child: Text(
          "You didn't verify your test kit before the timer ran out. Please start a new test.",
          style: StylingConstants().greenSubtitleTextTextStyle(),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 80.0),
        child: Text(
          "Something went wrong!",
          style: StylingConstants().greenSubtitleTextTextStyle(),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  Widget buildReminder(double controllerValue) {
    return Visibility(
      visible: (controllerValue < controllerValueQuarterMarkUpperBound &&
              controllerValue > 0)
          ? true
          : false,
      child: Container(
        margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 60.0),
        child: BlinkText(
          'Time is almost running out!',
          style: StylingConstants().reminderSubtitleTextTextStyle(),
          textAlign: TextAlign.center,
          endColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildVerifyImageButton(
      BuildContext context,
      String testKitUID,
      DocumentSnapshot testKitSnapshot,
      DocumentSnapshot userSnapshot,
      bool counterInProgress) {
    if (testKitSnapshot['predicting'] == false) {
      if (testKitSnapshot['label'] == '') {
        return Container(
          child: Column(
            children: [
              SizedBox(
                width: 311,
                height: 40,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: (counterInProgress)
                        ? StylingConstants().greenButtonColorEnabled
                        : StylingConstants().redButtonColorEnabled,
                    elevation: StylingConstants().buttonElevation,
                  ),
                  onPressed: () {
                    (counterInProgress)
                        ? verifyImage(userSnapshot,
                            testKitSnapshot['testKitStage'], testKitUID)
                        : forfeitTestKit(testKitUID, userSnapshot, context);
                  },
                  child: Text(
                    (counterInProgress) ? 'Verify Kit' : 'Start New Test',
                    style: StylingConstants().buttonTextTextStyle(),
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (testKitSnapshot['label'] == "positive" ||
          testKitSnapshot['label'] == "negative") {
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
                    navigateToViewResults(
                        context, testKitSnapshot, userSnapshot);
                  },
                  child: Text(
                    'View Test Result',
                    style: StylingConstants().buttonTextTextStyle(),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          child: Column(
            children: [
              SizedBox(
                width: 311,
                height: 40,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: StylingConstants().redButtonColorEnabled,
                    elevation: StylingConstants().buttonElevation,
                  ),
                  onPressed: () {
                    verifyImage(userSnapshot, testKitSnapshot['testKitStage'],
                        testKitUID);
                  },
                  child: Text(
                    'Reupload Test Kit',
                    style: StylingConstants().buttonTextTextStyle(),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else if (testKitSnapshot['predicting'] == true) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 80.0),
        child: Text(
          "Something went wrong!",
          style: StylingConstants().subtitleTextTextStyle(),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  void setNewControllerValue(double oldControllerValue, DateTime detachedTime,
      AnimationController controller) {
    DateTime currentTime = new DateTime.now().toLocal();

    double differenceInSeconds =
        ((currentTime.difference(detachedTime)).inSeconds / 1800);
    double newControllerValue = oldControllerValue - differenceInSeconds;

    updateController(newControllerValue, controller);
  }

  void updateController(
      double controllerValue, AnimationController controller) {
    controller.value = controllerValue;
  }

  void verifyImage(DocumentSnapshot userSnapshot, String testKitStage,
      String testKitUID) async {
    final picker =
        // ideally we want to use the camera as our image source
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (picker == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final name = basename(picker.path);
    final imageFile = File('${directory.path}/$name');
    final newImage = await File(picker.path).copy(imageFile.path);

    String? path =
        await FirebaseStorageRepo().getDownloadURL(userSnapshot, testKitUID);

    FireStoreRepo()
        .updateTestKit(testKitUID, 'imagePath', path, false)
        .whenComplete(() => FirebaseStorageRepo().uploadTestKitWithMetadata(
            imageFile, userSnapshot, testKitStage, testKitUID));
  }

  void forfeitTestKit(
      String testKitUID, DocumentSnapshot userSnapshot, BuildContext context) {
    FireStoreRepo()
        .updateBoolTestKit(testKitUID, 'completed', true)
        .whenComplete(() {
      navigateToTestProgress(context);
      AppPreferences().resetCounter();
    });
  }

  void navigateToTestProgress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TestProgress()),
    );
  }

  void navigateToViewResults(BuildContext context,
      DocumentSnapshot testKitSnapshot, DocumentSnapshot userSnapshot) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TestResult(
              testKitSnapshot: testKitSnapshot, userSnapshot: userSnapshot)),
    );
  }

  void startCounting(AnimationController controller) {
    controller.reverse(
        from: (controller.value == 0.0) ? 1.0 : controller.value);
  }

  void setupControllerValuePreferences(AnimationController controller,
      double? oldControllerValue, DateTime? detachedTime) {
    if (AppPreferences.getControllerValue() != null &&
        AppPreferences.getDetachedTime() != null) {
      oldControllerValue = AppPreferences.getControllerValue();
      detachedTime =
          DateTime.parse(AppPreferences.getDetachedTime().toString());
      setNewControllerValue(oldControllerValue!, detachedTime, controller);
    }
  }

  void setupTimerCounterPreferences(AnimationController controller) {
    if (AppPreferences.getCounterCompleted() != null &&
        AppPreferences.getCounterCompleted() == false) {
      startCounting(controller);
    } else if (AppPreferences.getCounterCompleted() == null) {
      AppPreferences.setCounterCompleted(false);
      startCounting(controller);
    }
  }
}

class TimerPainter extends CustomPainter {
  TimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}

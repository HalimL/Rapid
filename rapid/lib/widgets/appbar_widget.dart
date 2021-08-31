import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rapid/repository/firestore_repo.dart';
import 'package:rapid/screens/navigation_page.dart';
import 'package:rapid/screens/signup_second_page.dart';
import 'package:rapid/screens/test_progress.dart';
import 'package:rapid/styling/styling_constants.dart';
import 'package:rapid/utils/app_preferences.dart';

final icon = CupertinoIcons.arrow_right;

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    leading: BackButton(
      color: Colors.blue.shade500,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}

AppBar buildAppBarTestResults(BuildContext context, String testKitUID) {
  return AppBar(
    leading: CloseButton(
        color: Colors.red.shade500,
        onPressed: () {
          completeTest(context, testKitUID);
        }),
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}

AppBar buildAppBarVerifyTest(BuildContext context) {
  return AppBar(
    leading: BackButton(
      color: Colors.blue.shade500,
      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}

AppBar buildAppBarSignUpPage(
    BuildContext context,
    List<TextEditingController> textEditingControllers,
    GlobalKey<FormState> formKey) {
  return AppBar(
    leading: CloseButton(
        color: Colors.red.shade500,
        onPressed: () {
          Navigator.pop(context);
          clearAllControllers(textEditingControllers);
        }),
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      IconButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignUpSecondPage(),
              ),
            );
          }
        },
        icon: Icon(icon),
      ),
    ],
  );
}

void clearAllControllers(List<TextEditingController> textEditingControllers) {
  for (TextEditingController textEditingController in textEditingControllers) {
    textEditingController.clear();
  }
}

void navigateToNavigationPage(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => NavigationPage(),
    ),
  );
}

void navigateToTestProgress(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => TestProgress()),
  );
}

void completeTest(BuildContext context, String testKitUID) {
  if (AppPreferences.getShownAlert() != null &&
      AppPreferences.getShownAlert() == true) {
    FireStoreRepo()
        .updateBoolTestKit(testKitUID, 'completed', true)
        .whenComplete(
          () => navigateToTestProgress(context),
        );
  } else {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return _buildAlertDialog(context, testKitUID);
        });
  }
}

Widget okButton(BuildContext context, String testKitUID) {
  return TextButton(
      child:
          Text('OK', style: StylingConstants().clickableTextTextStyleActive()),
      onPressed: () {
        Navigator.of(context).pop();
        AppPreferences.setShownAlert(true);
      });
}

AlertDialog _buildAlertDialog(BuildContext context, String testKitUID) {
  return AlertDialog(
    title: Text(
      'Finished your test?',
    ),
    content: Text(
      'Pressing the close button will complete your current Rapid Test.',
    ),
    actions: [
      okButton(context, testKitUID),
    ],
  );
}

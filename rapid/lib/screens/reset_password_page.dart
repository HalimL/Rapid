import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid/styling/styling_constants.dart';
import 'package:rapid/services/authentification_service.dart';
import 'package:rapid/widgets/appbar_widget.dart';

BuildContext? scaffoldContext;

class ResetPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ResetPasswordPageState();
  }
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  void showInSnackBar(String message) {
    final snackBar = new SnackBar(
      content: new Text(
        message,
        textAlign: TextAlign.center,
        style: StylingConstants().buttonTextTextStyle(),
      ),
      backgroundColor: StylingConstants().snackBarColor,
      elevation: 6.0,
      behavior: SnackBarBehavior.floating,
      duration: new Duration(seconds: 5),
      shape: StylingConstants().snackbarCorners(),
    );
    ScaffoldMessenger.of(scaffoldContext!).showSnackBar(snackBar);
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    scaffoldContext = context;
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(67.0, 0.0, 82.0, 0.0),
              child: Text(
                "Reset Password",
                textAlign: TextAlign.center,
                style: StylingConstants().headerTextTextStyle(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32.0, 20.0, 32.0, 0.0),
            child: Text(
              "You can reset your current password here if you've forgotten it.",
              style: StylingConstants().inputTextTextStyle(),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 140,
          ),
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 30.0),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email*',
                      labelStyle: StylingConstants().textFormFieldTextStyle(),
                      hintText: 'Enter email',
                      hintStyle: StylingConstants().textFormFieldTextStyle(),
                      contentPadding: StylingConstants().textFormFieldPadding,
                      enabledBorder: StylingConstants().textFormFieldBoarder(),
                      border: OutlineInputBorder(),
                    ),
                    style: StylingConstants().inputTextTextStyle(),
                    validator: (value) {
                      return (value != null &&
                              !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value))
                          ? 'Please enter a valid email address'
                          : null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 20.0),
                  child: SizedBox(
                    width: 311,
                    height: 40,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            StylingConstants().blueButtonColorEnabled,
                        elevation: StylingConstants().buttonElevation,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthentificationService>().resetPassword(
                                emailController.text.trim(),
                              );
                        }
                      },
                      child: Text(
                        'Send',
                        style: StylingConstants().buttonTextTextStyle(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid/screens/reset_password_page.dart';
import 'package:rapid/screens/signup_main_page.dart';
import 'package:rapid/services/authentification_service.dart';
import 'package:rapid/styling/styling_constants.dart';

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

BuildContext? scaffoldContext;

class SignInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SignInPageState();
  }
}

class SignInPageState extends State<SignInPage> {
  Future navigateToSignUpMain(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SignUpMainPage()));
  }

  Future navigateToResetPasswordPage(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));
  }

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

  final GlobalKey<FormState> _formKey1 = GlobalKey();

  List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  Widget build(BuildContext context) {
    scaffoldContext = context;

    return Scaffold(
      backgroundColor: Colors.white,
      body: DelayedDisplay(
        delay: Duration(milliseconds: 500),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 80,
              ),
              ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: Ink.image(
                    image: AssetImage('assets/logo.png'),
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Form(
                  key: _formKey1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 30.0),
                        child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email*',
                            labelStyle:
                                StylingConstants().textFormFieldTextStyle(),
                            hintText: 'Enter email',
                            hintStyle:
                                StylingConstants().textFormFieldTextStyle(),
                            contentPadding:
                                StylingConstants().textFormFieldPadding,
                            enabledBorder:
                                StylingConstants().textFormFieldBoarder(),
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
                        padding:
                            const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 30.0),
                        child: TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password*',
                            labelStyle:
                                StylingConstants().textFormFieldTextStyle(),
                            hintText: 'Enter password',
                            hintStyle:
                                StylingConstants().textFormFieldTextStyle(),
                            contentPadding:
                                StylingConstants().textFormFieldPadding,
                            enabledBorder:
                                StylingConstants().textFormFieldBoarder(),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          style: StylingConstants().inputTextTextStyle(),
                          validator: (value) {
                            return (value != null && value.length < 6)
                                ? 'Password too short'
                                : null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
                        child: RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            text: "Forgot password?",
                            style: StylingConstants()
                                .clickableTextTextStyleActive(),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                navigateToResetPasswordPage(context);
                              },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 20.0),
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
                              if (_formKey1.currentState!.validate()) {
                                context
                                    .read<AuthentificationService>()
                                    .signIn(emailController.text.trim(),
                                        passwordController.text.trim())
                                    .whenComplete(() {
                                  passwordController.clear();
                                });
                              }
                            },
                            child: Text(
                              'Sign In',
                              style: StylingConstants().buttonTextTextStyle(),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 42,
                          ),
                          RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Don't have an account?  ",
                                  style:
                                      StylingConstants().inputTextTextStyle(),
                                ),
                                TextSpan(
                                  text: "Sign Up",
                                  style: StylingConstants()
                                      .clickableTextTextStyleActive(),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      navigateToSignUpMain(context);
                                      emailController.clear();
                                      passwordController.clear();
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid/screens/signin_page.dart';
import 'package:rapid/styling/styling_constants.dart';
import 'package:rapid/widgets/appbar_widget.dart';

final TextEditingController firstNameController = TextEditingController();
final TextEditingController lastNameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

BuildContext? scaffoldContext;

class SignUpMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SignUpMainPageState();
  }
}

class SignUpMainPageState extends State<SignUpMainPage> {
  List<TextEditingController> mainSignUpPageCredentialControllers = [
    firstNameController,
    lastNameController,
    emailController,
    passwordController,
  ];

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

  @override
  Widget build(BuildContext context) {
    scaffoldContext = context;
    return Consumer<SignInPageState>(
      builder: (context, signInPageState, child) {
        List<GlobalKey<FormState>> formKeys = signInPageState.formKeys;
        return Scaffold(
          appBar: buildAppBarSignUpPage(
              context, mainSignUpPageCredentialControllers, formKeys[0]),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(67.0, 0.0, 82.0, 0.0),
                    child: Text(
                      "Sign Up",
                      textAlign: TextAlign.center,
                      style: StylingConstants().headerTextTextStyle(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 80,
                ),
                Container(
                  child: Form(
                    key: formKeys[0],
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(32.0, 30.0, 32.0, 30.0),
                          child: TextFormField(
                            controller: firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name*',
                              labelStyle:
                                  StylingConstants().textFormFieldTextStyle(),
                              hintText: 'Enter first name',
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
                              return (value!.length < 2)
                                  ? 'Please enter a valid name'
                                  : null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 30.0),
                          child: TextFormField(
                            controller: lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name*',
                              labelStyle:
                                  StylingConstants().textFormFieldTextStyle(),
                              hintText: 'Enter last name',
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
                              return (value!.length < 2)
                                  ? 'Please enter a valid name'
                                  : null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
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
                          height: 30,
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

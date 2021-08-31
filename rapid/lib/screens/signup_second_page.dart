import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:rapid/model/bundesland.dart';
import 'package:rapid/model/firebase_user.dart';
import 'package:rapid/repository/firestore_repo.dart';
import 'package:rapid/screens/signin_page.dart';
import 'package:provider/provider.dart';
import 'package:rapid/screens/signup_main_page.dart';
import 'package:rapid/services/authentification_service.dart';
import 'package:rapid/styling/styling_constants.dart';
import 'package:rapid/widgets/appbar_widget.dart';

final TextEditingController postalCodeController = TextEditingController();
final TextEditingController cityController = TextEditingController();
final TextEditingController bundeslandController = TextEditingController();

final List<TextEditingController> secondSignUpPageCredentialControllers = [
  postalCodeController,
  cityController,
  bundeslandController,
];

class SignUpSecondPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SignUpSecondPageState();
  }
}

class SignUpSecondPageState extends State<SignUpSecondPage> {
  bool isChecked = false;
  String? selectedItem;

  Future navigateToSignIn(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SignInPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SignUpMainPageState, SignInPageState>(
        builder: (context, signUpMainPageState, signInPageState, child) {
      List<GlobalKey<FormState>> formKeys = signInPageState.formKeys;
      List<TextEditingController> allCredentialControllers =
          signUpMainPageState.mainSignUpPageCredentialControllers;

      allCredentialControllers.addAll(secondSignUpPageCredentialControllers);
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () {
            toggleRadioButton(false);
            Navigator.pop(context);
            clearAllControllers(secondSignUpPageCredentialControllers);
          }),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
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
                  key: formKeys[1],
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(32.0, 30.0, 32.0, 30.0),
                        child: TypeAheadFormField<Bundesland?>(
                          suggestionsCallback: FireStoreRepo().getBundesland,
                          debounceDuration: Duration(milliseconds: 500),
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: bundeslandController,
                            decoration: InputDecoration(
                              labelText: 'Bundesland*',
                              labelStyle:
                                  StylingConstants().textFormFieldTextStyle(),
                              hintText: 'Enter Bundesland',
                              hintStyle:
                                  StylingConstants().textFormFieldTextStyle(),
                              contentPadding:
                                  StylingConstants().textFormFieldPadding,
                              enabledBorder:
                                  StylingConstants().textFormFieldBoarder(),
                              border: OutlineInputBorder(),
                            ),
                            style: StylingConstants().inputTextTextStyle(),
                          ),
                          validator: (value) {
                            return (value!.isEmpty || selectedItem == null)
                                ? 'please select a valid bundesland'
                                : null;
                          },
                          itemBuilder: (context, Bundesland? suggestion) {
                            final bundesland = suggestion!;
                            return ListTile(
                              title: Text(bundesland.name),
                            );
                          },
                          noItemsFoundBuilder: (context) {
                            //this enables calling set state after build is done
                            WidgetsBinding.instance!.addPostFrameCallback(
                              (_) => setState(
                                () {
                                  selectedItem = null;
                                },
                              ),
                            );
                            return Container(
                              height: 50,
                              child: Center(
                                child: Text(
                                  'No Bundesland Found',
                                  style:
                                      StylingConstants().inputTextTextStyle(),
                                ),
                              ),
                            );
                          },
                          onSuggestionSelected: (Bundesland? suggestion) {
                            bundeslandController.text = suggestion!.name;
                            WidgetsBinding.instance!.addPostFrameCallback(
                              (_) => setState(() {
                                selectedItem = suggestion.name;
                              }),
                            );
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
                          controller: cityController,
                          decoration: InputDecoration(
                            labelText: 'City*',
                            labelStyle:
                                StylingConstants().textFormFieldTextStyle(),
                            hintText: 'Enter City',
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
                            return (value!.length < 3)
                                ? 'please enter a city'
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
                          controller: postalCodeController,
                          decoration: InputDecoration(
                            labelText: 'Postal Code*',
                            labelStyle:
                                StylingConstants().textFormFieldTextStyle(),
                            hintText: 'Enter postal Code',
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
                            return (value!.length != 5)
                                ? 'Please enter a valid postal code'
                                : null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Checkbox(
                    checkColor: StylingConstants().hintColor,
                    activeColor: StylingConstants().clickableTextColor,
                    value: isChecked,
                    onChanged: (value) {
                      toggleRadioButton(value!);
                    },
                  ),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "I agree to the ",
                          style: StylingConstants().inputTextTextStyle(),
                        ),
                        TextSpan(
                          text: "Terms & Conditions",
                          style:
                              StylingConstants().clickableTextTextStyleActive(),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 60,
              ),
              SizedBox(
                width: 311,
                height: 40,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: isChecked
                        ? StylingConstants().blueButtonColorEnabled
                        : StylingConstants().buttonColorDisabled,
                    elevation: StylingConstants().buttonElevation,
                  ),
                  onPressed: () async {
                    if (formKeys[1].currentState!.validate() && isChecked) {
                      formKeys[1].currentState!.save();
                      FirebaseUser newUser = FirebaseUser(
                        firstName: allCredentialControllers[0].text.trim(),
                        lastName: allCredentialControllers[1].text.trim(),
                        email: allCredentialControllers[2].text.trim(),
                        postalCode: allCredentialControllers[4].text.trim(),
                        city: allCredentialControllers[5].text.trim(),
                        bundesland: allCredentialControllers[6].text.trim(),
                        isDeutschlandUpdates: false,
                      );
                      context
                          .read<AuthentificationService>()
                          .signUp(
                              newUser.email,
                              allCredentialControllers[3].text.trim(),
                              newUser.firstName,
                              newUser.lastName,
                              newUser.postalCode,
                              newUser.city,
                              newUser.bundesland,
                              newUser.isDeutschlandUpdates,
                              context)
                          .whenComplete(() =>
                              clearAllControllers(allCredentialControllers));
                    }
                  },
                  child: Text(
                    'Sign Up',
                    style: StylingConstants().buttonTextTextStyle(),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
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
                          text: "Already have an account?  ",
                          style: StylingConstants().inputTextTextStyle(),
                        ),
                        TextSpan(
                          text: "Sign In",
                          style:
                              StylingConstants().clickableTextTextStyleActive(),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              clearAllControllers(allCredentialControllers);
                              navigateToSignIn(context);
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
      );
    });
  }

  void toggleRadioButton(bool value) {
    setState(
      () {
        isChecked = value;
      },
    );
  }
}

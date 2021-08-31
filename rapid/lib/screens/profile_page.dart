import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rapid/model/bundesland.dart';
import 'package:rapid/repository/firebase_storage_repo.dart';
import 'package:rapid/repository/firestore_repo.dart';
import 'package:rapid/services/authentification_service.dart';
import 'package:rapid/styling/styling_constants.dart';
import 'package:rapid/utils/app_preferences.dart';
import 'package:rapid/widgets/appbar_widget.dart';
import 'package:rapid/widgets/profile_picture_widget.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late DocumentSnapshot currentUserSnapshot;
  @override
  Widget build(BuildContext context) {
    return Consumer<QuerySnapshot?>(builder: (context, userSnapshot, child) {
      if (userSnapshot != null) {
        currentUserSnapshot = userSnapshot.docs.single;

        return Scaffold(
            appBar: buildAppBar(context),
            body: DelayedDisplay(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfilePicture(currentUserSnapshot),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        "${currentUserSnapshot['firstName']} ${currentUserSnapshot['lastName']}",
                        style: StylingConstants().profileTextStyle(),
                      ),
                    ),
                    SizedBox(
                      height: 80,
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                      elevation: 8.0,
                      child: _buildTiles(context, currentUserSnapshot),
                    ),
                    SizedBox(
                      height: 70,
                    ),
                    _buildSignOutButton(context),
                  ],
                ),
              ),
            ));
      } else {
        return Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        );
      }
    });
  }
}

Widget _buildProfilePicture(DocumentSnapshot currentUserSnapshot) {
  return Center(
    child: ProfileWidget(
      onClicked: () async {
        final picker =
            await ImagePicker().getImage(source: ImageSource.gallery);

        if (picker == null) return;

        final directory = await getApplicationDocumentsDirectory();
        final name = basename(picker.path);
        final imageFile = File('${directory.path}/$name');
        final newImage = await File(picker.path).copy(imageFile.path);

        FireStoreRepo().updateUser(
            currentUserSnapshot['uid'], "imagePath", newImage.path, null);

        FirebaseStorageRepo()
            .uploadProfilePictureWithMetadata(imageFile, currentUserSnapshot);
      },
      imagePath: currentUserSnapshot['imagePath'],
      className: (ProfilePage).toString(),
    ),
  );
}

Widget _buildTiles(BuildContext context, DocumentSnapshot currentUserSnapshot) {
  return Column(
    children: <Widget>[
      ListTile(
        leading: Icon(
          Icons.email_outlined,
          color: Colors.greenAccent.shade700,
        ),
        title: Text(
          "${currentUserSnapshot['email']}",
          style: StylingConstants().clickableTextTextStyleInactive(),
        ),
      ),
      _buildDivider(),
      ListTile(
        leading: Icon(
          Icons.lock_outline,
          color: Colors.greenAccent.shade700,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          color: Colors.greenAccent.shade700,
        ),
        title: Text("Change Password",
            style: StylingConstants().inputTextTextStyle()),
        onTap: () => buildChangePasswordDialog(context, currentUserSnapshot),
      ),
      _buildDivider(),
      ListTile(
        leading: Icon(
          Icons.location_pin,
          color: Colors.greenAccent.shade700,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          color: Colors.greenAccent.shade700,
        ),
        title: Text("Change Location",
            style: StylingConstants().inputTextTextStyle()),
        onTap: () => buildChangeLocationDialog(context, currentUserSnapshot),
      ),
      _buildDivider(),
      ListTile(
        trailing: Switch(
          value: currentUserSnapshot['isDeutschlandUpdates'],
          onChanged: (value) => FireStoreRepo().updateUser(
              currentUserSnapshot['uid'], 'isDeutschlandUpdates', null, value),
          activeColor: Colors.greenAccent.shade700,
        ),
        title: Text("Deutschlandweit RKI Zahlen",
            style: StylingConstants().inputTextTextStyle()),
      ),
    ],
  );
}

Widget _buildDivider() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8.0),
    width: double.infinity,
    height: 1.0,
    color: Colors.grey.shade400,
  );
}

Widget _buildSignOutButton(BuildContext context) {
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
              context.read<AuthentificationService>().signOut(context);
            },
            child: Text(
              'Sign Out',
              style: StylingConstants().buttonTextTextStyle(),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildUpdateLocationButton(BuildContext context, String? newLocation,
    DocumentSnapshot currentUserSnapshot, GlobalKey<FormState> formKey) {
  return Container(
    child: Column(
      children: [
        SizedBox(
          width: 120,
          height: 40,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: StylingConstants().blueButtonColorEnabled,
              elevation: StylingConstants().buttonElevation,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                FireStoreRepo().updateUser(currentUserSnapshot['uid'],
                    "bundesland", newLocation, null);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Update',
              style: StylingConstants().buttonTextTextStyle(),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildChangePasswordButton(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController newPasswordController,
    TextEditingController oldPasswordController) {
  return StatefulBuilder(builder: (context, setState) {
    return Container(
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 40,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: StylingConstants().blueButtonColorEnabled,
                elevation: StylingConstants().buttonElevation,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  User? currentUser =
                      context.read<AuthentificationService>().getCurrentUser();

                  if (currentUser != null) {
                    String currentUserEmailAddress = currentUser.email!;

                    AuthCredential credential = EmailAuthProvider.credential(
                        email: currentUserEmailAddress,
                        password: oldPasswordController.text);

                    //Firebase requires recent login before you can change your password
                    if (await context
                        .read<AuthentificationService>()
                        .reauthenticateUser(currentUser, credential)) {
                      context
                          .read<AuthentificationService>()
                          .updatePassword(newPasswordController.text, context);
                    }
                  }
                }
              },
              child: Text(
                'Update',
                style: StylingConstants().buttonTextTextStyle(),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

buildChangeLocationDialog(
    BuildContext context, DocumentSnapshot currentUserSnapshot) {
  final TextEditingController bundeslandController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  String? selectedItem;

  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Container(
                height: 330,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(CupertinoIcons.clear),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                        child: Text(
                          "Current Location:",
                          style: StylingConstants().inputTextTextStyle(),
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: Colors.blueAccent,
                        ),
                        title: Text("${currentUserSnapshot['bundesland']}",
                            style: StylingConstants().inputTextTextStyle()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                      child: Form(
                        key: _formKey,
                        child: TypeAheadFormField<Bundesland?>(
                          suggestionsCallback: FireStoreRepo().getBundesland,
                          debounceDuration: Duration(milliseconds: 500),
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: bundeslandController,
                            decoration: InputDecoration(
                              labelText: 'New Bundesland*',
                              labelStyle:
                                  StylingConstants().textFormFieldTextStyle(),
                              hintText: 'Enter new Bundesland',
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
                              (_) => setState(() {
                                selectedItem = null;
                              }),
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
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                        child: _buildUpdateLocationButton(context, selectedItem,
                            currentUserSnapshot, _formKey),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
}

buildChangePasswordDialog(
    BuildContext context, DocumentSnapshot currentUserSnapshot) {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Container(
                height: 420,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(CupertinoIcons.clear),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 0.0, 20.0, 10.0),
                            child: TextFormField(
                              controller: oldPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Old Password*',
                                labelStyle:
                                    StylingConstants().textFormFieldTextStyle(),
                                hintText: 'Enter old password',
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
                                    ? 'Wrong Password'
                                    : null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 10.0, 20.0, 10.0),
                            child: TextFormField(
                              controller: newPasswordController,
                              decoration: InputDecoration(
                                labelText: 'New Password*',
                                labelStyle:
                                    StylingConstants().textFormFieldTextStyle(),
                                hintText: 'Enter new password',
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 10.0, 20.0, 20.0),
                            child: TextFormField(
                              controller: confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Confirm new Password*',
                                labelStyle:
                                    StylingConstants().textFormFieldTextStyle(),
                                hintText: 'Enter new password',
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
                                return (newPasswordController.text !=
                                        confirmPasswordController.text)
                                    ? "Password doesn't match"
                                    : null;
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 0.0, 20.0, 20.0),
                              child: _buildChangePasswordButton(
                                  context,
                                  _formKey,
                                  newPasswordController,
                                  oldPasswordController),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
}

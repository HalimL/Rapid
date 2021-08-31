import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rapid/repository/firestore_repo.dart';
import 'package:rapid/screens/reset_password_page.dart';
import 'package:rapid/screens/signin_page.dart';
import 'package:rapid/screens/signup_main_page.dart';
import 'package:rapid/utils/app_preferences.dart';

import '../main.dart';

class AuthentificationService {
  final FirebaseAuth _firebaseAuth;
  final _firebaseRepo = FireStoreRepo();

  AuthentificationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((userCredential) {
        User? user = userCredential.user;
        if (user != null) {
          Fluttertoast.showToast(
            msg: "Signed in",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
          );
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        SignInPageState().showInSnackBar('No user found for $email');
      } else if (e.code == 'wrong-password') {
        SignInPageState().showInSnackBar('Wrong password');
      }
    }
  }

  Future<void> signUp(
      String email,
      String password,
      String firstName,
      String lastName,
      String? postalCode,
      String? city,
      String? bundesland,
      bool isDeutschlandUpdates,
      BuildContext context) async {
    try {
      await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((userCredential) {
        User? user = userCredential.user;
        AdditionalUserInfo? userInfo = userCredential.additionalUserInfo;

        if (user != null && userInfo!.isNewUser) {
          user.sendEmailVerification();
          _firebaseRepo.addUser(user.uid, email, firstName, lastName,
              postalCode, city, bundesland, isDeutschlandUpdates);

          navigateToMyApp(context);

          Fluttertoast.showToast(
            msg: "Account succesfully created",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
          );
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        SignUpMainPageState().showInSnackBar('Password too weak');
      } else if (e.code == 'email-already-in-use') {
        SignUpMainPageState()
            .showInSnackBar('Account already exists for $email');
      }
    } catch (e) {
      print(e);
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> signOut(BuildContext context) async {
    await _firebaseAuth.signOut().then((value) {
      Fluttertoast.showToast(
        msg: "Signed out",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      );
      navigateToMyApp(context);
    });
  }

  Future<bool> reauthenticateUser(
      User currentUser, AuthCredential credential) async {
    bool success = true;
    try {
      await currentUser.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      success = false;
      if (e.code == "wrong-password") {
        showToast("Wrong Password");
      } else if (e.code == "too-many-requests") {
        showToast(
            "You've entered a wrong password too many times please try again in few minutes");
      }
    }
    return success;
  }

  Future<void> updatePassword(String newPassword, BuildContext context) async {
    await getCurrentUser()!.updatePassword(newPassword);
    Navigator.pop(context);
    showToast("Password changed");
  }

  Future<void> resetPassword(String email) async {
    bool exists = await _firebaseRepo.checkForEmail(email);

    if (exists) {
      await _firebaseAuth.sendPasswordResetEmail(email: email).whenComplete(() {
        ResetPasswordPageState()
            .showInSnackBar('A password reset link has been sent to $email');
      });
    } else {
      ResetPasswordPageState().showInSnackBar('No user with $email');
    }
  }

  Future navigateToMyApp(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
  }
}

void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    textColor: Colors.red,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.TOP,
    timeInSecForIosWeb: 1,
  );
}

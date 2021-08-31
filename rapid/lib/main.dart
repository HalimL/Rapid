import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapid/repository/firestore_repo.dart';
import 'package:rapid/screens/navigation_page.dart';
import 'package:rapid/screens/signin_page.dart';
import 'package:rapid/screens/signup_main_page.dart';
import 'package:rapid/services/authentification_service.dart';
import 'package:rapid/utils/app_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _rapidApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthentificationService>(
          create: (_) => AuthentificationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          initialData: null,
          create: (context) =>
              context.read<AuthentificationService>().authStateChanges,
        ),
        Provider<SignInPageState>(
          create: (context) => SignInPageState(),
        ),
        Provider<SignUpMainPageState>(
          create: (context) => SignUpMainPageState(),
        ),
        StreamProvider<QuerySnapshot?>(
          initialData: null,
          create: (context) => NavigationPageState().getCurrentUserInfo(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rapid',
        theme: ThemeData(
          primaryColor: Colors.blue.shade300,
          primarySwatch: Colors.blue,
          accentColor: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FutureBuilder(
          future: _rapidApp,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasError) {
              print('You have an error! ${snapshot.error.toString()}');
              return Text('Something went wrong');
            } else if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final rapidAppUser = context.watch<User?>();
              return AuthenticationWrapper(rapidAppUser: rapidAppUser);
            } else {
              return Container(
                color: Colors.white,
              );
            }
          },
        ),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  final User? rapidAppUser;

  const AuthenticationWrapper({
    Key? key,
    required this.rapidAppUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rapidAppUser != null) {
      initializeMessagingToken(rapidAppUser!);
      return NavigationPage();
    } else if (rapidAppUser == null) {
      return SignInPage();
    } else {
      return Container();
    }
  }

  void initializeMessagingToken(User currentUser) async {
    String? deviceToken = await FirebaseMessaging.instance.getToken();

    await FireStoreRepo()
        .updateUser(currentUser.uid, 'deviceToken', deviceToken, null);
    FirebaseMessaging.instance.onTokenRefresh.listen((event) {
      FireStoreRepo()
          .updateUser(currentUser.uid, 'deviceToken', deviceToken, null);
    });
  }
}

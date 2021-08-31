import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rapid/repository/firestore_repo.dart';
import 'package:rapid/screens/certificate_page.dart';
import 'package:rapid/screens/home_page.dart';
import 'package:rapid/screens/test_progress.dart';
import 'package:rapid/styling/rapid_icons.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({Key? key}) : super(key: key);

  @override
  NavigationPageState createState() => NavigationPageState();
}

class NavigationPageState extends State<NavigationPage> {
  int _pageIndex = 0;

  Stream<QuerySnapshot> getCurrentUserInfo() {
    return FireStoreRepo().getUser(FirebaseAuth.instance.currentUser!.uid);
  }

  Widget pageChooser() {
    switch (this._pageIndex) {
      case 0:
        return CupertinoTabView(
          builder: (context) {
            return CupertinoPageScaffold(
              child: new HomePage(),
            );
          },
        );

      case 1:
        return CupertinoTabView(
          builder: (context) {
            return CupertinoPageScaffold(
              child: new TestProgress(),
            );
          },
        );

      case 2:
        return CupertinoTabView(
          builder: (context) {
            return CupertinoPageScaffold(
              child: new CertificatePage(),
            );
          },
        );

      default:
        return CupertinoTabView(
          builder: (context) {
            return CupertinoPageScaffold(
              child: new Container(
                child: new Center(
                  child: new Text(
                    'Something went wrong.',
                    style: new TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            );
          },
        );
    }
  }

  void onItemTapped(int index) {
    if (_pageIndex != index)
      setState(() {
        _pageIndex = index;
      });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              RapidIcons.home,
            ),
            activeIcon: Icon(
              RapidIcons.home,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              RapidIcons.rapid_test,
            ),
            activeIcon: Icon(
              RapidIcons.rapid_test,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              RapidIcons.test_results,
            ),
            activeIcon: Icon(
              RapidIcons.test_results,
            ),
          ),
        ],
        onTap: onItemTapped,
        backgroundColor: Colors.white,
        activeColor: Colors.green,
        inactiveColor: Colors.grey,
        iconSize: 26,
      ),
      tabBuilder: (context, index) {
        return pageChooser();
      },
    );
  }
}

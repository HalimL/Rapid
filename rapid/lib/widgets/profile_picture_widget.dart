import 'dart:io';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String homePage = "HomePage";
  final String profilePage = "ProfilePage";
  final VoidCallback onClicked;

  final String? imagePath;
  final String className;

  ProfileWidget({
    Key? key,
    required this.onClicked,
    required this.imagePath,
    required this.className,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Colors.green.shade800;
    return Center(
      child: (className == homePage)
          ? Stack(
              children: [
                buildCircle(
                  color: Colors.white,
                  all: 3,
                  child: buildImage(
                    imagePath,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: buildEditIcon(color),
                ),
              ],
            )
          : Stack(
              children: [
                buildImage(imagePath),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: buildAddPhotoIcon(color),
                ),
              ],
            ),
    );
  }

  Widget buildImage(String? imagePath) {
    if (imagePath != null && File(imagePath).existsSync()) {
      return ClipOval(
        child: Material(
          color: Colors.transparent,
          child: Ink.image(
            image: FileImage(File(imagePath)),
            fit: BoxFit.cover,
            width: (className == profilePage) ? 128 : 96,
            height: (className == profilePage) ? 128 : 96,
            child: InkWell(onTap: onClicked),
          ),
        ),
      );
    } else {
      return ClipOval(
        child: Material(
          color: Colors.transparent,
          child: Ink.image(
            image: AssetImage('assets/blankProfilePicture.png'),
            fit: BoxFit.cover,
            width: (className == profilePage) ? 128 : 96,
            height: (className == profilePage) ? 128 : 96,
            child: InkWell(onTap: onClicked),
          ),
        ),
      );
    }
  }

  Widget buildAddPhotoIcon(Color color) {
    return buildCircle(
      color: Colors.white,
      all: 3,
      child: buildCircle(
        color: color,
        all: 8,
        child: InkWell(
          child: Icon(
            Icons.add_a_photo,
            color: Colors.white,
            size: 20,
          ),
          onTap: onClicked,
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) {
    return buildCircle(
      color: Colors.white,
      all: 2,
      child: buildCircle(
        color: color,
        all: 6,
        child: InkWell(
          child: Icon(
            Icons.edit,
            color: Colors.white,
            size: 14,
          ),
          onTap: onClicked,
        ),
      ),
    );
  }

  Widget buildCircle(
      {required Color color, required double all, required Widget child}) {
    return ClipOval(
      child: Container(
        padding: EdgeInsets.all(all),
        color: color,
        child: child,
      ),
    );
  }
}

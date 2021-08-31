import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StylingConstants {
  //Colors
  final Color hintColor = Color.fromRGBO(152, 157, 189, 1.0);
  final Color black = Color.fromRGBO(0, 0, 0, 1.0);
  final Color white = Color.fromRGBO(255, 255, 255, 1.0);
  final Color green = Colors.green.shade700;
  final Color red = Colors.red.shade700;
  final Color clickableTextColor = Color.fromRGBO(100, 149, 237, 1.0);
  final Color snackBarColor = Colors.red[600]!;

  //Material Properties
  final MaterialStateProperty<Color?> blueButtonColorEnabled =
      MaterialStateProperty.all<Color>(Color.fromRGBO(100, 149, 237, 1.0));

  final MaterialStateProperty<Color?> greenButtonColorEnabled =
      MaterialStateProperty.all<Color>(Color.fromRGBO(0, 153, 51, 1.0));

  final MaterialStateProperty<Color?> redButtonColorEnabled =
      MaterialStateProperty.all<Color>(Color.fromRGBO(230, 0, 0, 1.0));

  final MaterialStateProperty<Color?> buttonColorDisabled =
      MaterialStateProperty.all<Color>(Color.fromRGBO(152, 157, 189, 1.0));
  final MaterialStateProperty<double?> buttonElevation =
      MaterialStateProperty.all<double>(10.0);

  //Font Weights
  final FontWeight mediumWeight = FontWeight.w500;
  final FontWeight semiBoldWeight = FontWeight.w600;
  final FontWeight boldWeight = FontWeight.w700;

  //Font Sizes
  final double smallFontSize = 13.0;
  final double mediumFontSize = 16.0;
  final double semiMediumFontSize = 18.0;
  final double largeFontSize = 20.0;
  final double large2FontSize = 24.0;
  final double veryLargeFontSize = 26.0;

  //Padding
  final EdgeInsetsGeometry textFormFieldPadding =
      new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0);

  //Border Side
  final BorderSide textFormFieldBorderSide =
      new BorderSide(color: Color.fromRGBO(152, 157, 189, 0.5));

  //Border Radius
  final BorderRadius textFormFieldBorderRadius = BorderRadius.circular(8.0);

  //Navi Options
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  //Snackbar
  TextStyle textFormFieldTextStyle() {
    return GoogleFonts.openSans(
      fontSize: mediumFontSize,
      fontWeight: mediumWeight,
      color: hintColor,
    );
  }

  TextStyle greetingsTextStyle() {
    return GoogleFonts.openSans(
      fontSize: veryLargeFontSize,
      fontWeight: semiBoldWeight,
      color: black,
    );
  }

  TextStyle greetingsWhiteTextStyle() {
    return GoogleFonts.openSans(
      fontSize: veryLargeFontSize,
      fontWeight: semiBoldWeight,
      color: white,
    );
  }

  TextStyle profileTextStyle() {
    return GoogleFonts.openSans(
      fontSize: large2FontSize,
      fontWeight: boldWeight,
      color: black,
    );
  }

  TextStyle containerTextStyleText() {
    return GoogleFonts.openSans(
      fontSize: largeFontSize,
      fontWeight: semiBoldWeight,
      color: black,
    );
  }

  TextStyle descriptionTextStyleText() {
    return GoogleFonts.openSans(
      fontSize: largeFontSize,
      fontWeight: semiBoldWeight,
      color: black,
    );
  }

  TextStyle containerTextStyleNumbers(Color? color) {
    return GoogleFonts.openSans(
      fontSize: veryLargeFontSize,
      fontWeight: semiBoldWeight,
      color: color,
    );
  }

  TextStyle inputTextTextStyle() {
    return GoogleFonts.openSans(
      fontSize: semiMediumFontSize,
      fontWeight: mediumWeight,
      color: black,
    );
  }

  TextStyle titleTextTextStyle() {
    return GoogleFonts.openSans(
      fontSize: veryLargeFontSize,
      fontWeight: semiBoldWeight,
      color: black,
    );
  }

  TextStyle subtitleTextTextStyle() {
    return GoogleFonts.openSans(
      fontSize: semiMediumFontSize,
      fontWeight: mediumWeight,
      color: black,
    );
  }

  TextStyle greenSubtitleTextTextStyle() {
    return GoogleFonts.openSans(
      fontSize: semiMediumFontSize,
      fontWeight: mediumWeight,
      color: green,
    );
  }

  TextStyle redSubtitleTextTextStyle() {
    return GoogleFonts.openSans(
      fontSize: semiMediumFontSize,
      fontWeight: mediumWeight,
      color: red,
    );
  }

  TextStyle reminderSubtitleTextTextStyle() {
    return GoogleFonts.openSans(
      fontSize: mediumFontSize,
      fontWeight: mediumWeight,
      color: red,
    );
  }

  TextStyle notificationTextTextStyle(String status) {
    return GoogleFonts.openSans(
      fontSize: mediumFontSize,
      fontWeight: mediumWeight,
      color: (status == 'success') ? green : red,
    );
  }

  TextStyle clickableTextTextStyleActive() {
    return GoogleFonts.openSans(
      fontSize: semiMediumFontSize,
      fontWeight: mediumWeight,
      color: clickableTextColor,
    );
  }

  TextStyle clickableTextTextStyleInactive() {
    return GoogleFonts.openSans(
      fontSize: semiMediumFontSize,
      fontWeight: mediumWeight,
      color: hintColor,
    );
  }

  RoundedRectangleBorder snackbarCorners() {
    return RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)));
  }

  TextStyle buttonTextTextStyle() {
    return GoogleFonts.openSans(
      fontSize: semiMediumFontSize,
      fontWeight: semiBoldWeight,
      color: white,
    );
  }

  TextStyle headerTextTextStyle() {
    return GoogleFonts.openSans(
      fontSize: largeFontSize,
      fontWeight: boldWeight,
      color: clickableTextColor,
    );
  }

  InputBorder textFormFieldBoarder() {
    return OutlineInputBorder(
        borderSide: textFormFieldBorderSide,
        borderRadius: textFormFieldBorderRadius);
  }
}

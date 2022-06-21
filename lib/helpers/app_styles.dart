
import 'package:flutter/material.dart';

class CustomAppStyle {

  static const String headlineFontsLabel = 'Taviraj';
  static const String bodyFontsRegularLabel = 'PoppinsRegular';
  static const String bodyFontsSemiBoldLabel = 'PoppinsSemibold';

  static TextStyle headline1(BuildContext context) {
  return Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 48.0, fontWeight: FontWeight.normal, height: 1.25, letterSpacing: 0.0, fontFamily: headlineFontsLabel);
  }

  static TextStyle headline2(BuildContext context) {
  return Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 48.0, fontWeight: FontWeight.normal, height: 1.38, letterSpacing: 0.0, fontFamily: headlineFontsLabel);
  }

  static TextStyle headline3(BuildContext context) {
  return Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 48.0, fontWeight: FontWeight.normal, height: 1.19, letterSpacing: 0.0, fontFamily: headlineFontsLabel);
  }

  static TextStyle headline4(BuildContext context) {
  return Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 48.0, fontWeight: FontWeight.normal, height: 1.33, letterSpacing: 0.0, fontFamily: headlineFontsLabel);
  }

  static TextStyle headline5(BuildContext context) {
  return Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 48.0, fontWeight: FontWeight.normal, height: 1.3, letterSpacing: 0.0, fontFamily: headlineFontsLabel);
  }

  static TextStyle headline6(BuildContext context) {
  return Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 48.0, fontWeight: FontWeight.w600, height: 1.25, letterSpacing: 0.0, fontFamily: headlineFontsLabel);
  }

  static TextStyle body14pxRegular(BuildContext context) {
  return Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 14.0, fontWeight: FontWeight.normal, height: 1.43, letterSpacing: 0.0, fontFamily: bodyFontsRegularLabel);
  }

  static TextStyle body12pxRegular(BuildContext context) {
  return Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, height: 1.5, letterSpacing: 0.0, fontFamily: bodyFontsRegularLabel);
  }
}
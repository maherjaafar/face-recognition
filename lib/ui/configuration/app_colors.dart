import 'package:flutter/material.dart';

class AppColors {
  static const blackUi = Colors.black;
  static const whiteUi = Colors.white;
  static const orangeUi = Color(0xfff08021);
  static const blueUi = Color(0xff1aa7e0);
  static const blueSkyUi = Color(0xFF20B9D6);
  static const greenLightUi = Color(0xFF28CDCC);
  // ---- Grey ----
  static const greyLightUi = Color(0xffe5e5e5);
  static const greyDarkUi = Color(0xffa5a5a5);
  static const greyBackgroundUi = Color(0xffEBEBEB);
  static const transparent = Colors.transparent;

  // ----- Gradients -----
  static const linearGradient = LinearGradient(
      colors: [blueSkyUi, greenLightUi],
      begin: const FractionalOffset(0.0, 0.0),
      end: const FractionalOffset(1.0, 0.0),
      stops: [0.0, 1.0],
      tileMode: TileMode.clamp);
}

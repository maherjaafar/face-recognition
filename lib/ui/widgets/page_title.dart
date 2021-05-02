import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

Widget buildPageTitle({@required String title}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 30),
    child: AutoSizeText(
      title,
      maxFontSize: 30,
      minFontSize: 25,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

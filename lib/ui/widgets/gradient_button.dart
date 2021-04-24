import 'package:auto_size_text/auto_size_text.dart';

import 'package:facerecognition/ui/configuration/configuration.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({Key key, this.text, this.onPressed}) : super(key: key);
  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: 60,
        width: width,
        padding: EdgeInsets.all(AppMargins.large),
        decoration: BoxDecoration(
            gradient: AppColors.linearGradient,
            borderRadius: BorderRadius.all(Radius.circular(36))),
        child: AutoSizeText(
          'Scan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

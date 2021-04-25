import 'package:auto_size_text/auto_size_text.dart';
import 'package:facerecognition/ui/configuration/configuration.dart';
import 'package:flutter/material.dart';

class AppTextWidget extends StatelessWidget {
  const AppTextWidget(
    this.text, {
    this.minFontSize,
    this.maxFontSize,
    this.style,
  });

  final String text;
  final double minFontSize;
  final double maxFontSize;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text ?? 'N/A',
      style: style ?? AppStyles.regularTextStyle,
      minFontSize: minFontSize ?? AppFontSizes.mediumFontSize,
      maxFontSize: maxFontSize ?? double.infinity,
    );
  }
}

import 'package:facerecognition/ui/configuration/configuration.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppRadius {
  // 65.0
  static const radiusCircular = 65.0;
}

class AppMargins {
  /// 6.0
  static const xxxSmall = 6.0;

  /// 8.0
  static const xxSmall = 8.0;

  /// 10.0
  static const xSmall = 10.0;

  /// 12.0
  static const small = 12.0;

  /// 14.0
  static const medium = 14.0;

  /// 16.0
  static const large = 16.0;

  /// 18.0
  static const xLarge = 18.0;

  /// 20.0
  static const xxLarge = 20.0;

  /// 30.0
  static const xxxLarge = 30.0;
}

class AppStyles {
  /// Poppins
  static final defaultFont = GoogleFonts.poppins();

  /// Regular
  static final regularTextStyle = defaultFont.copyWith(fontWeight: FontWeight.normal);

  /// Medium
  static final mediumTextStyle = defaultFont.copyWith(fontWeight: FontWeight.w600);

  /// Bold
  static final boldTextStyle = defaultFont.copyWith(fontWeight: FontWeight.bold);
}

class AppFontSizes {
  /// 15.0
  static const verySmallFontSize = 13.0;

  /// 17.0
  static const smallFontSize = 15.0;

  /// 19.0
  static const mediumFontSize = 17.0;

  /// 22.0
  static const bigFontSize = 19.0;
}

import 'package:facerecognition/ui/configuration/configuration.dart';
import 'package:facerecognition/ui/widgets/app_text.dart';
import 'package:facerecognition/ui/widgets/gradient_divider.dart';
import 'package:flutter/material.dart';

class InformationRow extends StatelessWidget {
  const InformationRow({
    this.title,
    this.info,
  });

  final String title;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppMargins.small, AppMargins.small, AppMargins.small, AppMargins.xxSmall),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppTextWidget(
                title,
                style: AppStyles.mediumTextStyle,
                minFontSize: AppFontSizes.verySmallFontSize,
              ),
              AppTextWidget(
                info,
                style: AppStyles.mediumTextStyle,
                minFontSize: AppFontSizes.verySmallFontSize,
              ),
            ],
          ),
        ),
        GradientDivider(),
      ],
    );
  }
}

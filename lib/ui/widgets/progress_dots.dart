import 'package:facerecognition/ui/configuration/configuration.dart';
import 'package:flutter/material.dart';

class ProgressDot extends StatelessWidget {
  const ProgressDot({
    Key key,
    this.isCurrentIndex,
  }) : super(key: key);

  final bool isCurrentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isCurrentIndex
            ? Container(
                alignment: Alignment.center,
                width: 30.0,
                height: 10.0,
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  gradient: AppColors.linearGradient,
                  color: AppColors.whiteUi,
                  shape: BoxShape.rectangle,
                ),
              )
            : Container(
                alignment: Alignment.center,
                width: 10.0,
                height: 10.0,
                decoration: new BoxDecoration(
                  color: AppColors.whiteUi,
                  shape: BoxShape.circle,
                ),
              ),
        SizedBox(width: 5),
      ],
    );
  }
}

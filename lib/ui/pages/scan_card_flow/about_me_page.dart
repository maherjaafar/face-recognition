import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:facerecognition/core/models/scan_result.dart';
import 'package:facerecognition/core/services/blink_id_service.dart';

import 'package:facerecognition/ui/configuration/configuration.dart';
import 'package:facerecognition/ui/pages/scan_card_flow/verify_photo_page.dart';
import 'package:facerecognition/ui/widgets/app_text.dart';
import 'package:facerecognition/ui/widgets/gradient_button.dart';
import 'package:facerecognition/ui/widgets/information_row.dart';
import 'package:facerecognition/ui/widgets/page_title.dart';
import 'package:facerecognition/ui/widgets/progress_dots.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AboutMePage extends StatefulWidget {
  const AboutMePage({
    this.cameraDescription,
  });

  final CameraDescription cameraDescription;
  @override
  _AboutMePageState createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    //_getCurrentPage(context);

    return Scaffold(
        appBar: AppBar(
          leading: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          automaticallyImplyLeading: true,
          elevation: 0,
          backgroundColor: AppColors.transparent,
        ),
        body: Container(
          height: height,
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              buildPageTitle(title: 'About me'),
              SizedBox(height: 30),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.greyBackgroundUi,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(AppRadius.radiusCircular),
                            topRight: Radius.circular(AppRadius.radiusCircular),
                          )),
                    ),
                    _buildAboutMePage(width, height, context),
                    Positioned(
                      width: width,
                      bottom: 50,
                      child: ProgressDot(
                        isCurrentIndex: true,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget _buildAboutMePage(double width, double height, BuildContext context) {
    final _blinkIdService = Provider.of<BlinkIdService>(context);
    final scanResult = _blinkIdService.scanResult;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppMargins.xxxLarge),
      child: Column(
        children: [
          SizedBox(height: AppMargins.xxxLarge),
          Row(
            children: [
              _buildFaceImage(_blinkIdService),
              SizedBox(width: AppMargins.xxLarge),
              _buildNameAndDocumentNumber(scanResult),
            ],
          ),
          SizedBox(height: AppMargins.xxxLarge),
          InformationRow(
            title: 'Nationality',
            info: scanResult.nationality,
          ),
          SizedBox(height: AppMargins.xxxLarge),
          InformationRow(
            title: 'Expiration Date',
            info: scanResult.dateOfExpiry,
          ),
          SizedBox(height: 70),
          _buildPrivacyPolicy(),
          SizedBox(height: 2 * AppMargins.medium),
          GradientButton(
            text: 'Next',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => VerifyPhotoPage(
                    cameraDescription: widget.cameraDescription,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    final primaryStyle = AppStyles.regularTextStyle
        .copyWith(color: AppColors.blackUi, fontSize: AppFontSizes.verySmallFontSize);
    final secondaryStyle = primaryStyle.copyWith(color: AppColors.greenLightUi);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppMargins.xxxSmall),
      child: RichText(
        text: TextSpan(
          text: 'By continuing you agree to Bank’s  and Privacy Policy ',
          style: primaryStyle,
          children: <TextSpan>[
            TextSpan(
              text: 'Terms and Conditions ',
              style: secondaryStyle,
            ),
            TextSpan(
              text: 'and ',
              style: primaryStyle,
            ),
            TextSpan(text: 'Privacy Policy ', style: secondaryStyle),
          ],
        ),
      ),
    );
  }

  Column _buildNameAndDocumentNumber(ScanResult scanResult) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextWidget(
          '${scanResult.firstName} ${scanResult.lastName}',
          minFontSize: AppFontSizes.bigFontSize,
          style: AppStyles.boldTextStyle,
        ),
        AppTextWidget(
          "${scanResult.documentNumber}",
          style: AppStyles.mediumTextStyle,
          minFontSize: AppFontSizes.mediumFontSize,
        ),
      ],
    );
  }

  Widget _buildFaceImage(BlinkIdService _blinkIdService) {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: MemoryImage(
            Base64Decoder().convert(_blinkIdService.scanResult.faceImageBase64),
          ),
        ),
      ),
    );
  }
}

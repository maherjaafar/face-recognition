import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:facerecognition/core/services/blink_id_service.dart';
import 'package:facerecognition/ui/configuration/configuration.dart';
import 'package:facerecognition/ui/widgets/gradient_button.dart';
import 'package:facerecognition/ui/widgets/progress_dots.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ScanCardPage extends StatefulWidget {
  @override
  _ScanCardPageState createState() => _ScanCardPageState();
}

class _ScanCardPageState extends State<ScanCardPage> {
  var _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;
    final BlinkIdService _blinkIdService = Provider.of<BlinkIdService>(context);

    Widget fullDocumentFrontImage = Container();
    Widget fullDocumentBackImage = Container();
    Widget faceImage = Container();

    _getCurrentPage(context);

    if (_blinkIdService.fullDocumentFrontImageBase64 != null &&
        _blinkIdService.fullDocumentFrontImageBase64 != "") {
      fullDocumentFrontImage = Column(
        children: <Widget>[
          Text("Document Front Image:"),
          Image.memory(
            Base64Decoder().convert(_blinkIdService.fullDocumentFrontImageBase64),
            height: 180,
            width: 350,
          )
        ],
      );
    }

    if (_blinkIdService.fullDocumentBackImageBase64 != null &&
        _blinkIdService.fullDocumentBackImageBase64 != "") {
      fullDocumentBackImage = Column(
        children: <Widget>[
          Text("Document Back Image:"),
          Image.memory(
            Base64Decoder().convert(_blinkIdService.fullDocumentBackImageBase64),
            height: 180,
            width: 350,
          )
        ],
      );
    }

    if (_blinkIdService.faceImageBase64 != null && _blinkIdService.faceImageBase64 != "") {
      faceImage = Column(
        children: <Widget>[
          Text("Face Image:"),
          Image.memory(
            Base64Decoder().convert(_blinkIdService.faceImageBase64),
            height: 150,
            width: 100,
          )
        ],
      );
    }

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
            _buildPageTitle(title: 'ID Card Scan'),
            SizedBox(height: 30),
            _buildBody(width, height, context)
          ],
        ),
      ),
    );
  }

  _getCurrentPage(BuildContext context) {
    final _blinkIdService = Provider.of<BlinkIdService>(context);
    if (_blinkIdService.faceImageBase64 != null && _blinkIdService.faceImageBase64 != "")
      setState(() {
        _currentPage = 1;
      });
  }

  _buildBody(width, height, context) {
    switch (_currentPage) {
      case 0:
        return _buildScanCardPage(width, height, context);
        break;
      case 1:
        return _buildAboutMePage(width, height, context);
        break;
      case 2:
        return Container();
        break;
      default:
        return Container();
        break;
    }
  }

  Expanded _buildAboutMePage(double width, double height, BuildContext context) {
    final _blinkIdService = Provider.of<BlinkIdService>(context);
    return Expanded(
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppMargins.xxxLarge),
          child: Column(
            children: [
              // SizedBox(height: AppMargins.xxxLarge),
              Container(
                width: width,
                height: height * 0.2,
                decoration: BoxDecoration(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(AppRadius.radiusCircular))),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.memory(
                      Base64Decoder().convert(_blinkIdService.faceImageBase64),
                      height: 150,
                      width: 100,
                    ),
                  ),
                  SizedBox(width: AppMargins.xxLarge),
                  Column(children: [
                    AutoSizeText(_blinkIdService.resultString),
                  ])
                ]),
              ),
              SizedBox(height: 2 * AppMargins.medium),
              GradientButton(
                onPressed: () {
                  setState(() {
                    _currentPage = 2;
                  });
                },
              )
            ],
          ),
        ),
        Positioned(
          width: width,
          bottom: 50,
          child: ProgressDot(
            isCurrentIndex: true,
          ),
        ),
      ],
    ));
  }

  Expanded _buildScanCardPage(double width, double height, BuildContext context) {
    return Expanded(
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppMargins.xxxLarge),
          child: Column(
            children: [
              SizedBox(height: AppMargins.xxxLarge),
              Container(
                width: width,
                height: height * 0.3,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(AppRadius.radiusCircular))),
                child: Lottie.asset('assets/scan_card.json'),
              ),
              SizedBox(height: 2 * AppMargins.medium),
              GradientButton(
                onPressed: () => Provider.of<BlinkIdService>(context, listen: false).scan(context),
              )
            ],
          ),
        ),
        Positioned(
          width: width,
          bottom: 50,
          child: ProgressDot(
            isCurrentIndex: true,
          ),
        ),
      ],
    ));
  }

  Container _buildPageTitle({@required String title}) {
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
}

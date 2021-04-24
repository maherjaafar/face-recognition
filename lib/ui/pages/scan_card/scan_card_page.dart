import 'package:auto_size_text/auto_size_text.dart';
import 'package:facerecognition/ui/configuration/configuration.dart';
import 'package:facerecognition/ui/widgets/gradient_button.dart';
import 'package:facerecognition/ui/widgets/progress_dots.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ScanCardPage extends StatefulWidget {
  @override
  _ScanCardPageState createState() => _ScanCardPageState();
}

class _ScanCardPageState extends State<ScanCardPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(AppRadius.radiusCircular))),
                        child: Lottie.asset('assets/scan_card.json'),
                      ),
                      SizedBox(height: 2 * AppMargins.medium),
                      GradientButton(
                        onPressed: () {},
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
            ))
          ],
        ),
      ),
    );
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

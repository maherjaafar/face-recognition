import 'package:camera/camera.dart';
import 'package:facerecognition/core/services/blink_id_service.dart';
import 'package:facerecognition/core/services/facenet.service.dart';
import 'package:facerecognition/core/services/ml_vision_service.dart';
import 'package:facerecognition/ui/configuration/configuration.dart';
import 'package:facerecognition/ui/pages/scan_card_flow/about_me_page.dart';
import 'package:facerecognition/ui/widgets/gradient_button.dart';
import 'package:facerecognition/ui/widgets/page_title.dart';
import 'package:facerecognition/ui/widgets/progress_dots.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ScanCardPage extends StatefulWidget {
  @override
  _ScanCardPageState createState() => _ScanCardPageState();
}

class _ScanCardPageState extends State<ScanCardPage> {
  // Services injection
  FaceNetService _faceNetService = FaceNetService();
  MLVisionService _mlVisionService = MLVisionService();

  CameraDescription cameraDescription;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _startUp();
  }

  /// 1 Obtain a list of the available cameras on the device.
  /// 2 loads the face net model
  _startUp() async {
    _setLoading(true);

    List<CameraDescription> cameras = await availableCameras();

    /// takes the front camera
    cameraDescription = cameras.firstWhere(
      (CameraDescription camera) => camera.lensDirection == CameraLensDirection.front,
    );

    // start the services
    await _faceNetService.loadModel();
    _mlVisionService.initialize();

    _setLoading(false);
  }

// shows or hides the circular progress indicator
  _setLoading(bool value) {
    setState(() {
      loading = value;
    });
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
      body: !loading
          ? Container(
              height: height,
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  buildPageTitle(title: 'ID Card Scan'),
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
                        _buildScanCardPage(width, height, context),
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
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildScanCardPage(
    double width,
    double height,
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppMargins.xxxLarge),
      child: Column(
        children: [
          SizedBox(height: AppMargins.xxxLarge),
          Container(
            width: width,
            height: height * 0.3,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppRadius.radiusCircular),
                )),
            child: Lottie.asset('assets/scan_card.json'),
          ),
          SizedBox(height: 2 * AppMargins.medium),
          GradientButton(onPressed: () async {
            await Provider.of<BlinkIdService>(
              context,
              listen: false,
            ).scan(context).then(
                  (response) => response == false
                      ? print('Failed recognizing Id')
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutMePage(cameraDescription: cameraDescription),
                          )),
                );
          }),
        ],
      ),
    );
  }
}

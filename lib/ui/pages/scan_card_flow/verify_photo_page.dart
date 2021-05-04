import 'dart:io';

import 'package:camera/camera.dart';
import 'package:facerecognition/core/services/blink_id_service.dart';
import 'package:facerecognition/core/services/camera.service.dart';
import 'package:facerecognition/core/services/facenet.service.dart';
import 'package:facerecognition/core/services/ml_vision_service.dart';
import 'package:facerecognition/ui/configuration/configuration.dart';
import 'package:facerecognition/ui/pages/scan_card_flow/widgets/camera_page.dart';
import 'package:facerecognition/ui/widgets/FacePainter.dart';
import 'package:facerecognition/ui/widgets/app_text.dart';
import 'package:facerecognition/ui/widgets/auth_action_button.dart';
import 'package:facerecognition/ui/widgets/gradient_button.dart';
import 'package:facerecognition/ui/widgets/page_title.dart';
import 'package:facerecognition/ui/widgets/progress_dots.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class VerifyPhotoPage extends StatefulWidget {
  final CameraDescription cameraDescription;

  const VerifyPhotoPage({
    Key key,
    @required this.cameraDescription,
  }) : super(key: key);

  @override
  VerifyPhotoPageState createState() => VerifyPhotoPageState();
}

class VerifyPhotoPageState extends State<VerifyPhotoPage> {
  /// Service injection
  CameraService _cameraService = CameraService();
  MLVisionService _mlVisionService = MLVisionService();
  FaceNetService _faceNetService = FaceNetService();

  Future _initializeControllerFuture;

  bool cameraInitializated = false;
  bool _detectingFaces = false;
  bool isPictureTaken = false;
  bool _isTakingSelfie = false;

  // switchs when the user press the camera
  bool _saving = false;

  String imagePath;
  Size imageSize;
  Face faceDetected;
  bool isFaceDetected = false;

  @override
  void initState() {
    super.initState();

    /// starts the camera & start framing faces
    _start();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraService.dispose();
    super.dispose();
  }

  /// starts the camera & start framing faces
  _start() async {
    _initializeControllerFuture = _cameraService.startService(widget.cameraDescription);
    await _initializeControllerFuture;

    setState(() {
      cameraInitializated = true;
    });

    _frameFaces();
  }

  /// draws rectangles when detects faces
  _frameFaces() {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController.startImageStream((image) async {
      if (_cameraService.cameraController != null) {
        // if its currently busy, avoids overprocessing
        if (_detectingFaces) return;

        _detectingFaces = true;

        try {
          List<Face> faces = await _mlVisionService.getFacesFromImage(image);

          if (faces != null) {
            if (faces.length > 0) {
              // preprocessing the image
              setState(() {
                faceDetected = faces[0];
              });

              if (_saving) {
                _saving = false;
                _faceNetService.setCurrentPrediction(image, faceDetected);
              }
            } else {
              setState(() {
                faceDetected = null;
              });
            }
          }

          _detectingFaces = false;
        } catch (e) {
          print(e);
          _detectingFaces = false;
        }
      }
    });
  }

  /// handles the button pressed event
  Future<void> onShot() async {
    if (faceDetected == null) {
      print('No face detected!');
    } else {
      imagePath = join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');

      _saving = true;
      print('saving');

      await Future.delayed(Duration(milliseconds: 500));
      await _cameraService.cameraController.stopImageStream();
      await Future.delayed(Duration(milliseconds: 200));
      await _cameraService.takePicture(imagePath);

      setState(() {
        isPictureTaken = true;
        isFaceDetected = true;
        _isTakingSelfie = false;
        print('face detected');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
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
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildTakeSelfiePage(context, width, height);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  _buildTakeSelfiePage(
    BuildContext context,
    double width,
    double height,
  ) {
    return Container(
      height: height,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          buildPageTitle(title: 'Verify photo'),
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
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppRadius.radiusCircular),
                            )),
                        child: Lottie.asset('assets/take_selfie.json'),
                      ),
                      SizedBox(height: 2 * AppMargins.medium),
                      GradientButton(
                          text: !isPictureTaken ? 'Take selfie' : 'Next',
                          onPressed: () async {
                            if (isPictureTaken) {
                              debugPrint("next button pressed");
                              debugPrint(
                                  "Final distance is ${Provider.of<BlinkIdService>(context, listen: false).comparisonResult}");
                            } else {
                              final double distanceResult = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CameraPage(
                                            cameraDescription: widget.cameraDescription,
                                          )));

                              if (distanceResult.round() < 1.1) {
                                await _showAlert(context);
                              }
                            }
                          }),
                      SizedBox(height: AppMargins.xxxLarge),
                      if (imagePath != null)
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: FileImage(File(imagePath)),
                            ),
                          ),
                        ),
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
            ),
          )
        ],
      ),
    );
  }

  // set up the AlertDialog
  Future<void> _showAlert(BuildContext context) async {
    final dialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
      content: new Container(
        width: 260.0,
        height: 230.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Lottie.asset('assets/scan_successful.json'),
              ),
            ),

            // dialog centre
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: AppTextWidget('Scan Successful'),
                  ),
                ],
              ),
              flex: 2,
            ),

            // dialog bottom
            GradientButton(
                text: "Next",
                onPressed: () {
                  print("Next");
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }
}

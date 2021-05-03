import 'dart:io';

import 'package:camera/camera.dart';
import 'package:facerecognition/core/services/camera.service.dart';
import 'package:facerecognition/core/services/facenet.service.dart';
import 'package:facerecognition/core/services/ml_vision_service.dart';
import 'package:facerecognition/ui/configuration/configuration.dart';
import 'package:facerecognition/ui/widgets/FacePainter.dart';
import 'package:facerecognition/ui/widgets/auth_action_button.dart';
import 'package:facerecognition/ui/widgets/gradient_button.dart';
import 'package:facerecognition/ui/widgets/page_title.dart';
import 'package:facerecognition/ui/widgets/progress_dots.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
            if (isPictureTaken) {
              return _buildTakeSelfiePage(context, width, height);
            } else {
              return _isTakingSelfie
                  ? _buildCameraWidget(context, width, height)
                  : _buildTakeSelfiePage(context, width, height);
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isTakingSelfie
          ? AuthActionButton(
              _initializeControllerFuture,
              onPressed: onShot,
              isLogin: true,
            )
          : null,
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
                        onPressed: () {
                          if (isPictureTaken)
                            debugPrint("next button pressed");
                          else
                            setState(() {
                              _isTakingSelfie = true;
                            });
                        },
                      ),
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

  _buildCameraWidget(
    BuildContext context,
    double width,
    double height,
  ) {
    return Transform.scale(
      scale: 1.0,
      child: AspectRatio(
        aspectRatio: MediaQuery.of(context).size.aspectRatio,
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
              width: width,
              height: width / _cameraService.cameraController.value.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CameraPreview(_cameraService.cameraController),
                  CustomPaint(
                    painter: FacePainter(face: faceDetected, imageSize: imageSize),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

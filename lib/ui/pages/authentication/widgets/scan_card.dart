import 'dart:io';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:facerecognition/core/database/database.dart';
import 'package:facerecognition/core/services/camera.service.dart';
import 'package:facerecognition/core/services/facenet.service.dart';
import 'package:facerecognition/core/services/ml_vision_service.dart';
import 'package:facerecognition/ui/configuration/configuration.dart';
import 'package:facerecognition/ui/pages/authentication/widgets/scan_button.dart';
import 'package:facerecognition/ui/widgets/FacePainter.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';


class AppScanCard extends StatefulWidget {
  AppScanCard({this.cameraDescription});

  final CameraDescription cameraDescription;

  @override
  _AppScanCardState createState() => _AppScanCardState();
}

class _AppScanCardState extends State<AppScanCard> {
  String imagePath;

  Face faceDetected;

  Size imageSize;

  bool _detectingFaces = false;

  bool pictureTaken = false;

  Future _initializeControllerFuture;

  bool cameraInitializated = false;

  bool _saving = false;

  bool _bottomSheetVisible = false;

  MLVisionService _mlVisionService = MLVisionService();

  CameraService _cameraService = CameraService();

  FaceNetService _faceNetService = FaceNetService();

  DataBaseService _dataBaseService = DataBaseService();

  bool loading = false;

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

  /// handles the button pressed event
  onShot() async {
    print('onShot performed');

    if (faceDetected == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('No face detected!'),
            );
          });

      return false;
    } else {
      _saving = true;

      await Future.delayed(Duration(milliseconds: 500));
      await _cameraService.cameraController.stopImageStream();
      await Future.delayed(Duration(milliseconds: 200));
      final file = await _cameraService.takePicture();

      setState(() {
        imagePath = file.path;
        _bottomSheetVisible = true;
        pictureTaken = true;
      });

      return true;
    }
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

          if (faces.length > 0) {
            setState(() {
              faceDetected = faces[0];
            });

            if (_saving) {
              _faceNetService.setCurrentPrediction(image, faceDetected);
              setState(() {
                _saving = false;
              });
            }
          } else {
            setState(() {
              faceDetected = null;
            });
          }

          _detectingFaces = false;
        } catch (e) {
          print(e);
          _detectingFaces = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double mirror = math.pi;

    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;
    return Scaffold(
      appBar: AppBar(),
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
                      SizedBox(height: 2 * AppMargins.xxxLarge),
                      _buildCameraPreview(height, width, mirror),
                      SizedBox(height: AppMargins.xxxLarge),
                      ScanButton(
                        _initializeControllerFuture,
                        isScanId: true,
                        onPressed: onShot,
                      )
                    ],
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }

  FutureBuilder<void> _buildCameraPreview(double height, double width, double mirror) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (pictureTaken) {
            return Container(
              width: width,
              height: height * 0.4,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.radiusCircular))),
              child: Transform(
                  alignment: Alignment.center,
                  child: Image.file(File(imagePath)),
                  transform: Matrix4.rotationY(mirror)),
            );
          } else {
            return Container(
              width: width,
              height: height * 0.4,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.radiusCircular))),
              child: Transform.scale(
                scale: 0.4,
                child: AspectRatio(
                  aspectRatio: MediaQuery.of(context).size.aspectRatio,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(
                      width: height * 0.3 / _cameraService.cameraController.value.aspectRatio,
                      height: height * 0.3,
                      padding: EdgeInsets.all(AppMargins.xxLarge),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          CameraPreview(_cameraService.cameraController),
                          CustomPaint(
                            painter: FacePainter(face: faceDetected, imageSize: imageSize),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
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

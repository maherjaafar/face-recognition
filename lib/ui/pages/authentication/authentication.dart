import 'package:camera/camera.dart';
import 'package:facerecognition/core/database/database.dart';
import 'package:facerecognition/core/services/facenet.service.dart';
import 'package:facerecognition/core/services/ml_vision_service.dart';
import 'package:facerecognition/ui/configuration/app_colors.dart';
import 'package:facerecognition/ui/pages/authentication/scan_card.dart';
import 'package:flutter/material.dart';

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  // Services injection
  FaceNetService _faceNetService = FaceNetService();
  MLVisionService _mlVisionService = MLVisionService();
  DataBaseService _dataBaseService = DataBaseService();

  CameraDescription cameraDescription;
  bool loading = false;

  initState() {
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
    await _dataBaseService.loadDB();
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
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.transparent,
          automaticallyImplyLeading: true,
        ),
        body: ElevatedButton(
          child: Text('tap here'),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AppScanCard(
                          cameraDescription: cameraDescription,
                        )));
          },
        ));
  }
}

import 'dart:io';

import 'package:facerecognition/core/services/image_file_database.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class FacePage extends StatefulWidget {
  @override
  _FacePageState createState() => _FacePageState();
}

class _FacePageState extends State<FacePage> {
  File _imageFile;
  List<Face> _faces;

  ImageFileDatabase _imageFileDatabase = ImageFileDatabase();

  _getImageAndDetectFaces() async {
    final imageFile = await _imageFileDatabase.readFile();

    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(mode: FaceDetectorMode.accurate),
    );
    final faces = await faceDetector.processImage(image);
    if (mounted) {
      setState(() {
        _imageFile = imageFile;
        _faces = faces;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face detector')),
      body: Container(
        child: _imageFile != null
            ? ImageAndFaces(
                faces: _faces,
                imageFile: _imageFile,
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectFaces,
        child: Icon(Icons.image),
      ),
    );
  }
}

class ImageAndFaces extends StatelessWidget {
  const ImageAndFaces({Key key, this.imageFile, this.faces}) : super(key: key);

  final File imageFile;
  final List<Face> faces;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(child: Image.file(imageFile, fit: BoxFit.cover)),
        Flexible(
          flex: 1,
          child: ListView(
            children: faces.map((f) => FaceCoordinates(face: f)).toList(),
          ),
        ),
      ],
    );
  }
}

class FaceCoordinates extends StatelessWidget {
  final Face face;

  const FaceCoordinates({Key key, this.face}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pos = face.boundingBox;
    return ListTile(title: Text('(${pos.top}, ${pos.left}, ${pos.bottom}, ${pos.right})'));
  }
}

import 'package:facerecognition/core/services/blink_id_service.dart';
import 'package:flutter/material.dart';
import "dart:convert";

import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BlinkIdService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final BlinkIdService _blinkIdService = Provider.of<BlinkIdService>(context);

    Widget fullDocumentFrontImage = Container();
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

    Widget fullDocumentBackImage = Container();
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

    Widget faceImage = Container();
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

    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text("BlinkID Sample"),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Padding(
                  child: ElevatedButton(
                    child: Text("Scan"),
                    onPressed: () =>
                        Provider.of<BlinkIdService>(context, listen: false).scan(context),
                  ),
                  padding: EdgeInsets.only(bottom: 16.0)),
              Text(_blinkIdService.resultString),
              fullDocumentFrontImage,
              fullDocumentBackImage,
              faceImage,
            ],
          )),
    ));
  }
}

import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageFileDatabase {
  Future<String> _getImageFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String imageFilePath = '$appDocumentsPath/imagefile.jpg'; // 3

    return imageFilePath;
  }

  Future<void> saveImageFile(String frontImage) async {
    File imageFile = File(await _getImageFilePath()); // 1
    final base64Image = Base64Decoder().convert(frontImage);
    await imageFile.writeAsBytes(base64Image); // 2
  }

  Future<String> readImageFile() async {
    File imageFile = File(await _getImageFilePath()); // 1
    final imageBytes = await imageFile.readAsBytes();
    print(imageBytes);
    String imageFileContent = base64Encode(imageBytes);
    print('File Content: $imageFileContent');

    return imageFileContent;
  }

  Future<File> readFile() async {
    File imageFile = File(await _getImageFilePath()); // 1
    return imageFile;
  }
}

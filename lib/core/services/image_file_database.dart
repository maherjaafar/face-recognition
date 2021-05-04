import 'dart:convert';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageFileDatabase {
  Future<String> _getImageFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String imageFilePath = '$appDocumentsPath/imagefile.jpg'; // 3

    return imageFilePath;
  }

  Future<void> saveImageFile(String base64String, String frontImage, String backImage) async {
    File imageFile = File(await _getImageFilePath()); // 1
    final base64Image = Base64Decoder().convert(base64String);
    await imageFile.writeAsBytes(base64Image); // 2

    final result = await ImageGallerySaver.saveImage(base64Image, quality: 100, name: "CIN");
    print(result);

    if (frontImage != null && frontImage != "")
      await ImageGallerySaver.saveImage(Base64Decoder().convert(frontImage),
          quality: 100, name: "front");

    if (backImage != null && backImage != "")
      await ImageGallerySaver.saveImage(Base64Decoder().convert(backImage),
          quality: 100, name: "back");
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

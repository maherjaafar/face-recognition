import 'package:blinkid_flutter/microblink_scanner.dart';
import 'package:blinkid_flutter/recognizers/blink_id_combined_recognizer.dart';
import 'package:facerecognition/core/models/scan_result.dart';
import 'package:facerecognition/core/services/image_file_database.dart';
import 'package:flutter/material.dart';

class BlinkIdService with ChangeNotifier {
  String resultString = "";
  String fullDocumentFrontImageBase64 = "";
  String fullDocumentBackImageBase64 = "";
  String faceImageBase64 = "";
  bool isDetected = false;

  double comparisonResult;

  ImageFileDatabase _imageFileDatabase = ImageFileDatabase();

  ScanResult scanResult;

  Future<void> scan(BuildContext context) async {
    String license = _getSpecificPlatformLicense(context);

    var idRecognizer = BlinkIdCombinedRecognizer();
    idRecognizer.returnFullDocumentImage = true;
    idRecognizer.returnFaceImage = true;

    BlinkIdOverlaySettings settings = BlinkIdOverlaySettings();

    var results = await MicroblinkScanner.scanWithCamera(
        RecognizerCollection([idRecognizer]), settings, license);

    if (results.length == 0) return;
    for (var result in results) {
      if (result is BlinkIdCombinedRecognizerResult) {
        if (result.mrzResult.documentType == MrtdDocumentType.Passport) {
          getPassportResult(result);
        } else {
          getIdResult(result);
        }

        fullDocumentFrontImageBase64 = result.fullDocumentFrontImage;
        fullDocumentBackImageBase64 = result.fullDocumentBackImage;
        faceImageBase64 = result.faceImage;

        if (result.fullDocumentFrontImage != null && result.fullDocumentFrontImage != "") {
          scanResult.faceImageBase64 = result.fullDocumentFrontImage;
          scanResult.aboutMeImage = result.faceImage;

          await _imageFileDatabase.saveImageFile(result.fullDocumentFrontImage,
              fullDocumentFrontImageBase64, fullDocumentBackImageBase64);

          await _imageFileDatabase.readImageFile();

          await _imageFileDatabase.readFile().then((imageFile) {
            scanResult.imageFromFile = imageFile;
            notifyListeners();
          });
        }

        return;
      }
    }
  }

  _getSpecificPlatformLicense(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return "sRwAAAEaY29tLnlvdW5lcy5mYWNlcmVjb2duaXRpb27j0CkE8HK25Y46ih8gV3Ok61BqbqzlN2RqyMS6BVS9wxYbhof9G7gB7Jb0H210LejjjJHmC9j0KcZSe20TOOND2A3/zBUoIQvw0r0FoKBjqSNCT/UsdKpCydhFf1SYvLhOnja3/a3T5+F9gJ6dAqC0lKv3r6YL09kwgz1hSWYixBqpg3X/oamtmXbcotyphgWTIm8h7qsbEnh/MN1XJ/LUV51/8vVvVjwFtMY1M3hM73+wX4QXoJuDMB7WjX8Hz++WK5d9EKYKFA3OU4QaZfLbyGdtOwT31R+mvYgGSIYukDJLINvBolOqBuDB+Ne9+ZxtyfAg5A5orKMM7cquvUqJ+Mk=";
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      return "sRwAAAAaY29tLnlvdW5lcy5mYWNlcmVjb2duaXRpb262G2JbCmXLARjeYi2rK2l6jyiArPDroYt3ZVJCz2Txgf19SD1vwIOUzIiVKV1lWc2FQUWRgkGA7/BbP+yo70sbxg2f1RAqgSzLj1ZcZ5SLgtif3GrjRuJLpo7sjpsmU5JWOoCJbsjFZo5B+lKZvwliTNaArTc1DWMfnQeDXYQNgmef2VeEfNroNMHJvuKx1DC5MOeTkd8fy+A6qbhgZNvCz/kM8RqGGr7EEaz2gs/iqrEU9Pb25WnbFHg6yXl8CqQ4Z9qgenelCmb81qAE84iP9tWCt9KqX+8yR5+Jexd6HAQnni2plt5fm4W5CZ3uz2D7ySU2f7ptkAZG1SAXPc7fgNg=";
    }
  }

  String _getDateFormat(Date date) {
    return date != null ? "${date.day}/${date.month}/${date.year}" : "N/A";
  }

  void getIdResult(BlinkIdCombinedRecognizerResult result) {
    scanResult = ScanResult(
      firstName: result.firstName,
      lastName: result.lastName,
      fullName: result.fullName,
      documentNumber: result.documentNumber,
      personalIdNumber: result.personalIdNumber,
      nationality: result.nationality,
      dateOfBirth: _getDateFormat(result.dateOfBirth),
      dateOfExpiry: _getDateFormat(result.dateOfExpiry),
    );

    isDetected = true;
    notifyListeners();
  }

  void getPassportResult(BlinkIdCombinedRecognizerResult result) {
    scanResult = ScanResult(
      firstName: result.firstName ?? "N/A",
      lastName: result.lastName ?? "N/A",
      fullName: result.fullName ?? "N/A",
      documentNumber: result.documentNumber ?? "N/A",
      personalIdNumber: result.personalIdNumber ?? "N/A",
      nationality: result.nationality ?? "N/A",
      dateOfBirth: _getDateFormat(result.dateOfBirth) ?? "N/A",
      dateOfExpiry: _getDateFormat(result.dateOfExpiry) ?? "N/A",
    );

    isDetected = true;
    notifyListeners();
  }
}

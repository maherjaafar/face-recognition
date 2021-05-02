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

  int currentPage = 0;

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

        if (result.faceImage != null && result.faceImage != "") {
          scanResult.faceImageBase64 = result.faceImage;

          await _imageFileDatabase.saveImageFile(result.faceImage);
          await _imageFileDatabase.readImageFile();

          await _imageFileDatabase.readFile().then((imageFile) {
            scanResult.imageFromFile = imageFile;
            notifyListeners();
          });
        }

        if (isDetected) currentPage = 1;
        notifyListeners();

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
    var dateOfBirth = "";
    if (result.mrzResult.dateOfBirth != null) {
      dateOfBirth = _getDateFormat(result.mrzResult.dateOfBirth);
    }

    var dateOfExpiry = "";
    if (result.mrzResult.dateOfExpiry != null) {
      dateOfExpiry = _getDateFormat(result.mrzResult.dateOfExpiry);
    }
    scanResult = ScanResult(
      firstName: result.mrzResult.secondaryId,
      lastName: result.mrzResult.primaryId,
      documentNumber: result.mrzResult.documentNumber,
      nationality: result.mrzResult.nationality,
      dateOfBirth: dateOfBirth,
      dateOfExpiry: dateOfExpiry,
    );

    isDetected = true;
    notifyListeners();
  }
}

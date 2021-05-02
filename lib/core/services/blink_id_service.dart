import 'dart:io';

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
  //File imageFromFile;

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
          resultString = getPassportResultString(result);
        } else {
          resultString = getIdResultString(result);
        }

        resultString = resultString;
        fullDocumentFrontImageBase64 = result.fullDocumentFrontImage;
        fullDocumentBackImageBase64 = result.fullDocumentBackImage;
        faceImageBase64 = result.faceImage;

        if (result.faceImage != null && result.faceImage != "") {
          scanResult.faceImageBase64 = result.faceImage;

          await _imageFileDatabase.saveImageFile(result.faceImage);
          await _imageFileDatabase.readImageFile();

          await _imageFileDatabase.readFile().then((imageFile) {
            scanResult.imageFromFile = imageFile;
            print('success');
            notifyListeners();
          });
        }

        if (resultString != null) currentPage = 1;
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

  String getIdResultString(BlinkIdCombinedRecognizerResult result) {
    scanResult = ScanResult(
      firstName: result.firstName,
      lastName: result.lastName,
      fullName: result.fullName,
      documentNumber: result.documentNumber,
      personalIdNumber: result.personalIdNumber,
      nationality: result.nationality,
      dateOfBirth:
          "${result.dateOfBirth.day}/${result.dateOfBirth.month}/${result.dateOfBirth.year}",
      dateOfExpiry:
          "${result.dateOfExpiry.day}/${result.dateOfExpiry.month}/${result.dateOfExpiry.year}",
    );
    notifyListeners();

    return buildResult(result.firstName, "First name") +
        buildResult(result.lastName, "Last name") +
        buildResult(result.fullName, "Full name") +
        buildResult(result.localizedName, "Localized name") +
        buildResult(result.additionalNameInformation, "Additional name info") +
        buildResult(result.address, "Address") +
        buildResult(result.additionalAddressInformation, "Additional address info") +
        buildResult(result.documentNumber, "Document number") +
        buildResult(result.documentAdditionalNumber, "Additional document number") +
        buildResult(result.sex, "Sex") +
        buildResult(result.issuingAuthority, "Issuing authority") +
        buildResult(result.nationality, "Nationality") +
        buildDateResult(result.dateOfBirth, "Date of birth") +
        buildIntResult(result.age, "Age") +
        buildDateResult(result.dateOfIssue, "Date of issue") +
        buildDateResult(result.dateOfExpiry, "Date of expiry") +
        buildResult(result.dateOfExpiryPermanent.toString(), "Date of expiry permanent") +
        buildResult(result.maritalStatus, "Martial status") +
        buildResult(result.personalIdNumber, "Personal Id Number") +
        buildResult(result.profession, "Profession") +
        buildResult(result.race, "Race") +
        buildResult(result.religion, "Religion") +
        buildResult(result.residentialStatus, "Residential Status") +
        buildDriverLicenceResult(result.driverLicenseDetailedInfo);
  }

  String buildResult(String result, String propertyName) {
    if (result == null || result.isEmpty) {
      return "";
    }

    return propertyName + ": " + result + "\n";
  }

  String buildDateResult(Date result, String propertyName) {
    if (result == null || result.year == 0) {
      return "";
    }

    return buildResult("${result.day}.${result.month}.${result.year}", propertyName);
  }

  String buildIntResult(int result, String propertyName) {
    if (result < 0) {
      return "";
    }

    return buildResult(result.toString(), propertyName);
  }

  String buildDriverLicenceResult(DriverLicenseDetailedInfo result) {
    if (result == null) {
      return "";
    }

    return buildResult(result.restrictions, "Restrictions") +
        buildResult(result.endorsements, "Endorsements") +
        buildResult(result.vehicleClass, "Vehicle class") +
        buildResult(result.conditions, "Conditions");
  }

  String getPassportResultString(BlinkIdCombinedRecognizerResult result) {
    var dateOfBirth = "";
    if (result.mrzResult.dateOfBirth != null) {
      dateOfBirth = "${result.mrzResult.dateOfBirth.day}/"
          "${result.mrzResult.dateOfBirth.month}/"
          "${result.mrzResult.dateOfBirth.year}";
    }

    var dateOfExpiry = "";
    if (result.mrzResult.dateOfExpiry != null) {
      dateOfExpiry = "${result.mrzResult.dateOfExpiry.day}/"
          "${result.mrzResult.dateOfExpiry.month}/"
          "${result.mrzResult.dateOfExpiry.year}";
    }
    scanResult = ScanResult(
      firstName: result.mrzResult.secondaryId,
      lastName: result.mrzResult.primaryId,
      documentNumber: result.mrzResult.documentNumber,
      nationality: result.mrzResult.nationality,
      dateOfBirth: dateOfBirth,
      dateOfExpiry: dateOfExpiry,
    );
    return "First name: ${result.mrzResult.secondaryId}\n"
        "Last name: ${result.mrzResult.primaryId}\n"
        "Document number: ${result.mrzResult.documentNumber}\n"
        "Sex: ${result.mrzResult.gender}\n"
        "$dateOfBirth"
        "$dateOfExpiry"
        "${result.mrzResult.nationality}";
  }
}

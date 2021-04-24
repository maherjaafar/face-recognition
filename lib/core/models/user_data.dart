import 'dart:typed_data';

class UserData {
  UserData({
    this.userData,
    this.fullname,
    this.personalNumber,
    this.nationality,
    this.expirationDate,
    this.password,
  });

  final Uint8List userData;
  final String fullname;
  final String personalNumber;
  final String nationality;
  final String expirationDate;
  final String password;
}

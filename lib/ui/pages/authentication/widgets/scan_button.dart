// import 'package:facerecognition/core/database/database.dart';
// import 'package:facerecognition/core/models/user.dart';
// import 'package:facerecognition/core/services/facenet.service.dart';
// import 'package:facerecognition/ui/configuration/configuration.dart';
// import 'package:facerecognition/ui/widgets/app_text.dart';
// import 'package:flutter/material.dart';

// class ScanButton extends StatefulWidget {
//   ScanButton(
//     this._initializeControllerFuture, {
//     Key key,
//     this.isScanId,
//     this.onPressed,
//   }) : super(key: key);

//   final bool isScanId;
//   final onPressed;
//   final Future _initializeControllerFuture;

//   @override
//   _ScanButtonState createState() => _ScanButtonState();
// }

// class _ScanButtonState extends State<ScanButton> {
//   /// service injection
//   final FaceNetService _faceNetService = FaceNetService();

//   final DataBaseService _dataBaseService = DataBaseService();

//   User predictedUser;

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;

//     return GestureDetector(
//       onTap: () async {
//         try {
//           // Ensure that the camera is initialized.
//           await widget._initializeControllerFuture;
//           // onShot event (takes the image and predict output)
//           bool faceDetected = await widget.onPressed();

//           if (faceDetected) {
//             if (!widget.isScanId) {
//               var userAndPass = _predictUser();
//               if (userAndPass != null) {
//                 this.predictedUser = User.fromDB(userAndPass);
//               }
//             }
//             Scaffold.of(context).showBottomSheet((context) => signSheet(context));
//           }
//         } catch (e) {
//           // If an error occurs, log the error to the console.
//           print(e);
//         }
//       },
//       child: Container(
//         alignment: Alignment.center,
//         height: 60,
//         width: width,
//         padding: EdgeInsets.all(AppMargins.large),
//         decoration: BoxDecoration(
//             gradient: new LinearGradient(
//                 colors: [
//                   const Color(0xFF20B9D6),
//                   const Color(0xFF28CDCC),
//                 ],
//                 begin: const FractionalOffset(0.0, 0.0),
//                 end: const FractionalOffset(1.0, 0.0),
//                 stops: [0.0, 1.0],
//                 tileMode: TileMode.clamp),
//             borderRadius: BorderRadius.all(Radius.circular(36))),
//         child: AppTextWidget(
//           'Scan',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }

//   Future _scanId(context) async {
//     /// gets predicted data from facenet service (user face detected)
//     List predictedData = _faceNetService.predictedData;

//     /// creates a new user in the 'database'
//     await _dataBaseService.saveData('Maher1', 'Maher1', predictedData);

//     /// resets the face stored in the face net sevice
//     this._faceNetService.setPredictedData(null);
//   }

//   String _predictUser() {
//     String userAndPass = _faceNetService.predict(context);
//     return userAndPass ?? null;
//   }

//   signSheet(context) {
//     return Container(
//       padding: EdgeInsets.all(20),
//       height: 300,
//       child: Column(
//         children: [
//           widget.isScanId
//               ? ElevatedButton(
//                   child: Text('Sign Up!'),
//                   onPressed: () async {
//                     await _scanId(context);
//                   },
//                 )
//               : Container(),
//         ],
//       ),
//     );
//   }
// }

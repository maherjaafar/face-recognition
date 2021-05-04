import 'package:facerecognition/core/services/blink_id_service.dart';
import 'package:facerecognition/core/services/facenet.service.dart';
import 'package:facerecognition/ui/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthActionButton extends StatefulWidget {
  AuthActionButton(this._initializeControllerFuture,
      {@required this.onPressed, @required this.isLogin});
  final Future _initializeControllerFuture;
  final Function onPressed;
  final bool isLogin;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  /// service injection
  final FaceNetService _faceNetService = FaceNetService();

  bool predictedUser;

  Future<double> _predictUser() async {
    return await _faceNetService.predict();
  }

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      text: 'Take picture',
      // Provide an onPressed callback.
      onPressed: () async {
        try {
          // Ensure that the camera is initialized.
          await widget._initializeControllerFuture;
          // onShot event (takes the image and predict output)
          await widget.onPressed();

          if (widget.isLogin) {
            final distance = await _predictUser();
            Provider.of<BlinkIdService>(context, listen: false).comparisonResult = distance;
          }
        } catch (e) {
          // If an error occurs, log the error to the console.
          print(e);
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

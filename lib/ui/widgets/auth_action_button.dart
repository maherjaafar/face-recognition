import 'package:facerecognition/core/database/database.dart';
import 'package:facerecognition/core/services/facenet.service.dart';
import 'package:flutter/material.dart';

class User {
  String user;
  String password;

  User({@required this.user, @required this.password});

  static User fromDB(String dbuser) {
    return new User(user: dbuser.split(':')[0], password: dbuser.split(':')[1]);
  }
}

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

  _signIn(context) {
    // if (this.predictedUser) {
    // } else {
    //   print(" WRONG PASSWORD!");
    // }
  }

  Future<bool> _predictUser(BuildContext context) async {
    bool isEqual = await _faceNetService.predict(context);
    return isEqual;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      label: widget.isLogin ? Text('Sign in') : Text('Sign up'),
      icon: Icon(Icons.camera_alt),
      // Provide an onPressed callback.
      onPressed: () async {
        try {
          // Ensure that the camera is initialized.
          await widget._initializeControllerFuture;
          // onShot event (takes the image and predict output)
          bool faceDetected = await widget.onPressed();

          if (faceDetected) {
            if (widget.isLogin) {
              bool userAndPass = await _predictUser(context);
              if (userAndPass != null) {
                if (mounted)
                  setState(() {
                    this.predictedUser = userAndPass;
                  });
              }
            }
            Scaffold.of(context).showBottomSheet((context) => signSheet(context));
          }
        } catch (e) {
          // If an error occurs, log the error to the console.
          print(e);
        }
      },
    );
  }

  signSheet(context) {
    return Container(
      padding: EdgeInsets.all(20),
      height: 300,
      child: Column(
        children: [
          widget.isLogin && predictedUser == true
              ? Container(
                  child: Text(
                    'Welcome back, ' + 'Si chbeeb' + '! 😄',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : widget.isLogin
                  ? Container(
                      child: Text(
                      'User not found 😞',
                      style: TextStyle(fontSize: 20),
                    ))
                  : Container(),
          widget.isLogin && predictedUser != null
              ? RaisedButton(
                  child: Text('Login'),
                  onPressed: () async {
                    await _signIn(context);
                  },
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

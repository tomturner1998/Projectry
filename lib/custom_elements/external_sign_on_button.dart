import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_finder/authentication/auth.dart';

class ExternalSignOnButton extends StatefulWidget {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final AssetImage image;
  final String text;
  final Function loginFunction;

  ExternalSignOnButton({Key key, this.image, this.text, this.loginFunction})
      : super(key: key);

  _ExternalSignOnButtonState createState() => _ExternalSignOnButtonState();
}

class _ExternalSignOnButtonState extends State<ExternalSignOnButton> {
  bool _isLoggingIn = false;

  @override
  Widget build(BuildContext context) {
    return _isLoggingIn
        ? CircularProgressIndicator()
        : OutlineButton(
            splashColor: Theme.of(context).splashColor,
            onPressed: () async {
              setState(() {
                _isLoggingIn = true;
              });
              final user = await widget.loginFunction(
                  widget.googleSignIn, widget.firebaseAuth);

              setState(() {
                _isLoggingIn = false;
              });

              if (user != null) {
                AuthImpl.INSTANCE.logIn(context, user);
              }
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            highlightElevation: 0.0,
            borderSide: BorderSide(color: Theme.of(context).splashColor),
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: widget.image,
                    height: 35.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      widget.text,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  )
                ],
              ),
            ),
          );
  }
}

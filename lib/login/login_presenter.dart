import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/login/login_view.dart';
import 'package:project_finder/navigation/paths.dart';

class LoginPresenter {
  final Auth auth;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  FToast _fToast;

  BuildContext _context;

  LoginView _loginView;

  LoginPresenter(this.auth);

  void view(LoginView view, BuildContext context, FToast fToast) {
    this._loginView = view;
    this._context = context;
    this._fToast = fToast;
    _updateView(false);
  }

  void _updateView(bool isLoggingIn) async {
    if (_loginView == null) {
      return;
    }

    _loginView.update(isLoggingIn);
  }

  void handlePasswordReset() {
    if (emailController.text.isEmpty) {
      _showToast("Please Enter an E-Mail", Icon(Icons.block, color: rosewood));
      return;
    }
    auth.sendPasswordResetEmail(emailController.text);
    _showToast(
        "Password Reset E-Mail Sent",
        Icon(
          Icons.done,
          color: rosewood,
        ));
  }

  Future<User> handleSignInWithGoogle(
      GoogleSignIn googleSignIn, FirebaseAuth firebaseAuth) {
    return auth.signInWithGoogle(googleSignIn, firebaseAuth);
  }

  void handleSignIn() async {
    _updateView(true);

    final user =
        await auth.emailSignIn(emailController.text, passwordController.text);

    _updateView(false);

    if (user != null) {
      auth.logIn(_context, user);
      emailController.clear();
      passwordController.clear();
    } else {
      _showToast("Entered Credentials are Invalid",
          Icon(Icons.block, color: rosewood));
    }
  }

  void _showToast(String text, Icon icon) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: currentTheme.isDark ? mediumChampagne : indianYellow,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(
            width: 12.0,
          ),
          Text(text,
              style:
                  GoogleFonts.lato().copyWith(fontSize: 18, color: rosewood)),
        ],
      ),
    );

    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
    );
  }
}

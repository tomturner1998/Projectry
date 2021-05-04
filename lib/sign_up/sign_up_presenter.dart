import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/navigation/paths.dart';
import 'package:project_finder/sign_up/sign_up_view.dart';

class SignUpPresenter {
  final Auth _auth;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FToast _fToast = FToast();

  BuildContext _context;

  SignUpView _signUpView;

  String _currentScreen = "email";

  SignUpPresenter(this._auth);

  Future<void> view(SignUpView view, BuildContext context) async {
    this._signUpView = view;
    this._context = context;
    this._fToast.init(context);
    _updateView();
    return;
  }

  void _updateView() async {
    if (_signUpView == null) {
      return;
    }

    _signUpView.update(_currentScreen);
  }

  void handleNextButtonPressed() {
    if (emailController.text.isEmpty) {
      _showToast("E-Mail Cannot Be Empty");
      return;
    }

    _currentScreen = "password";
    _updateView();
  }

  void handleBackButtonPressed() {
    _currentScreen = "email";
    _updateView();
  }

  void handleSignUpButtonPressed() async {
    FocusScope.of(_context).unfocus();

    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showToast("Password Cannot Be Blank");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showToast("Passwords Do Not Match");
      return;
    }

    if (invalidPassword(passwordController.text)) {
      _showToast("Password is Invalid");
      return;
    }

    User user = await _auth.emailSignUp(
        emailController.text, passwordController.text, _showToast);

    if (user != null) {
      Navigator.pop(_context);
      Navigator.pushNamed(_context, new_user);
    }
  }

  bool invalidPassword(String password) {
    bool hasCaptial = false;
    bool hasNumber = false;
    for (int i = 0; i < password.length; i++) {
      if (!isNumber(password.characters.characterAt(i).toString()) &&
          (password.characters.characterAt(i) ==
              password.characters.characterAt(i).toUpperCase())) {
        hasCaptial = true;
      }

      if (isNumber(password.characters.characterAt(i).toString())) {
        hasNumber = true;
      }

      if (hasCaptial && hasNumber) {
        break;
      }
    }

    return !hasNumber || !hasCaptial;
  }

  bool isNumber(String i) {
    return "0".compareTo(i) <= 0 && "9".compareTo(i) >= 0;
  }

  void _showToast(String text) {
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
          Icon(
            Icons.block,
            color: rosewood,
          ),
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

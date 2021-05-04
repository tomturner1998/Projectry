import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/custom_elements/login_clipper.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/custom_elements/external_sign_on_button.dart';
import 'package:project_finder/custom_elements/text_divider.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/login/login_presenter.dart';
import 'package:project_finder/navigation/paths.dart';

class LoginView {
  void update(bool userIsLoggingIn) {}
}

class Login extends StatefulWidget {
  final LoginPresenter presenter;

  Login(this.presenter, {Key key}) : super(key: key);

  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> implements LoginView {
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    FToast fToast = FToast();
    fToast.init(context);
    widget.presenter.view(this, context, fToast);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(),
    );
  }

  @override
  void update(bool userIsLoggingIn) {
    setState(() {
      _isLoggingIn = userIsLoggingIn;
    });
  }

  Widget _buildContent() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTitle(),
                SizedBox(
                  height: MediaQuery.of(context).size.height > 800 ? 48 : 8,
                ),
                _buildEmailField(),
                SizedBox(
                  height: 8,
                ),
                _buildPasswordField(),
                SizedBox(
                  height: 8,
                ),
                _buildForgottenPasswordButton(),
                SizedBox(
                  height: 8,
                ),
                _buildButtons(),
                SizedBox(
                  height: MediaQuery.of(context).size.height > 800 ? 16 : 8,
                ),
                TextDivider(
                  text: 'OR',
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height > 800 ? 16 : 8,
                ),
                _buildGoogleButton()
              ],
            ),
          ),
          _buildClipPath()
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Projectry",
            style: GoogleFonts.indieFlower().copyWith(fontSize: 64),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "The University of Exeter",
            style: Theme.of(context).textTheme.headline6,
          ),
        )
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      key: Key("EmailField"),
      controller: widget.presenter.emailController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        filled: true,
        hintStyle: Theme.of(context).textTheme.headline6,
        hintText: "E-Mail",
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      key: Key("PasswordField"),
      controller: widget.presenter.passwordController,
      obscureText: true,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          filled: true,
          hintStyle: Theme.of(context).textTheme.headline6,
          hintText: "Password"),
    );
  }

  Widget _buildForgottenPasswordButton() {
    return ButtonBar(
      children: [
        Text("Forgotten", style: Theme.of(context).textTheme.subtitle2),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return _buildPasswordResetModal();
                });
          },
          child: Text(
            "Password?",
            style: Theme.of(context).textTheme.subtitle2.copyWith(
                color: currentTheme.isDark ? mediumChampagne : indianYellow),
          ),
        )
      ],
    );
  }

  Widget _buildPasswordResetModal() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.presenter.emailController,
            decoration: InputDecoration(
                hintText: "E-Mail",
                hintStyle: GoogleFonts.lato().copyWith(fontSize: 24),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.grey)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.grey))),
          ),
          SizedBox(
            height: 16,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: currentTheme.isDark ? indianYellow : deepSpaceSparkle,
                padding: EdgeInsets.fromLTRB(15, 10, 15, 10)),
            onPressed: () {
              widget.presenter.handlePasswordReset();
              Navigator.pop(context);
            },
            child: Text(
              "Send Password Reset E-Mail",
              style: GoogleFonts.lato().copyWith(
                  fontSize: 24,
                  color: currentTheme.isDark ? rosewood : Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        _buildSignUpButton(),
        SizedBox(
          width: MediaQuery.of(context).size.height > 800 ? 24 : 0,
        ),
        _buildSignInButton()
      ],
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      width: 140,
      child: ElevatedButton(
        child: Text(
          "Sign Up",
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(color: Colors.black.withOpacity(0.8)),
        ),
        onPressed: () => Navigator.pushNamed(context, sign_up),
        style: ElevatedButton.styleFrom(
            primary: Colors.grey,
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            )),
      ),
    );
  }

  Widget _buildSignInButton() {
    return _isLoggingIn
        ? CircularProgressIndicator()
        : Container(
            width: 140,
            child: ElevatedButton(
              key: Key("SignInButton"),
              child: Text(
                "Sign In",
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(color: rosewood),
              ),
              onPressed: () => widget.presenter.handleSignIn(),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  primary: currentTheme.isDark ? mediumChampagne : indianYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )),
            ),
          );
  }

  Widget _buildGoogleButton() {
    return ExternalSignOnButton(
      image: AssetImage("assets/google_logo.png"),
      text: "Sign in with Google",
      loginFunction: widget.presenter.handleSignInWithGoogle,
    );
  }

  Widget _buildClipPath() {
    return ClipPath(
      clipper: LoginClipper(),
      child: Container(
        color: MediaQuery.of(context).size.height > 800
            ? deepSpaceSparkle
            : Colors.transparent,
      ),
    );
  }
}

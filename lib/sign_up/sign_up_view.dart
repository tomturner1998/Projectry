import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/sign_up/sign_up_presenter.dart';

class SignUpView {
  void update(String currentScreen) {}
}

class SignUp extends StatefulWidget {
  final SignUpPresenter presenter;

  SignUp(this.presenter, {Key key}) : super(key: key);

  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> implements SignUpView {
  String _currentScreen;

  @override
  void initState() {
    super.initState();
    initView();
  }

  void initView() async {
    await widget.presenter.view(this, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: _buildContent(),
    );
  }

  void update(String currentScreen) {
    setState(() {
      _currentScreen = currentScreen;
    });
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: deepSpaceSparkle,
      title: Text("Sign Up"),
    );
  }

  Widget _buildContent() {
    switch (_currentScreen) {
      case "email":
        return _buildEmailInput();
        break;
      case "password":
        return _buildPasswordInput();
        break;
      default:
        return Text("Error Encountered, Please Return to Login Page");
    }
  }

  Widget _buildEmailInput() {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("What Is Your E-Mail?",
              key: Key("SignUpEmailInputHeader"),
              style: GoogleFonts.lato().copyWith(
                  fontSize: 32,
                  color:
                      currentTheme.isDark ? indianYellow : deepSpaceSparkle)),
          SizedBox(
            height: 16,
          ),
          TextField(
            key: Key("SignUpEmailInputField"),
            controller: widget.presenter.emailController,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                        color: currentTheme.isDark
                            ? mediumChampagne
                            : deepSpaceSparkle)),
                hintText: "E-Mail",
                hintStyle: GoogleFonts.lato().copyWith(fontSize: 24),
                border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 32,
          ),
          Row(
            key: Key("SignUpEmailInputButtonRow"),
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildNextButton()],
          )
        ],
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Please Enter and Confirm a Password",
              key: Key("SignUpPasswordInputHeader"),
              style: GoogleFonts.lato()
                  .copyWith(fontSize: 32, color: indianYellow)),
          SizedBox(
            height: MediaQuery.of(context).size.height > 800 ? 16 : 8,
          ),
          TextField(
            key: Key("SignUpPasswordInput"),
            obscureText: true,
            controller: widget.presenter.passwordController,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                        color: currentTheme.isDark
                            ? mediumChampagne
                            : deepSpaceSparkle)),
                hintText: "Password",
                hintStyle: GoogleFonts.lato().copyWith(fontSize: 24),
                border: OutlineInputBorder()),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height > 800 ? 16 : 8,
          ),
          TextField(
            key: Key("SignUpConfirmPasswordInput"),
            obscureText: true,
            controller: widget.presenter.confirmPasswordController,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                        color: currentTheme.isDark
                            ? mediumChampagne
                            : deepSpaceSparkle)),
                hintText: "Confirm Password",
                hintStyle: GoogleFonts.lato().copyWith(fontSize: 24)),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height > 800 ? 32 : 8,
          ),
          Wrap(
            key: Key("SignUpPasswordButtonsRow"),
            alignment: WrapAlignment.end,
            children: [
              _buildBackButton(),
              SizedBox(
                height: MediaQuery.of(context).size.height > 800 ? 8 : 0,
                width: 0.001,
              ),
              _buildSignUpButton()
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height > 800 ? 32 : 8,
          ),
          MediaQuery.of(context).size.height > 800 ? Wrap(
            children: [
              Text("• 6 Characters Long",
                  style: GoogleFonts.lato().copyWith(fontSize: 18)),
              SizedBox(
                height: 4,
              ),
              Text(
                "• Contains a Capital Letter",
                style: GoogleFonts.lato().copyWith(fontSize: 18),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                "• Contains a Number",
                style: GoogleFonts.lato().copyWith(fontSize: 18),
              )
            ],
          ) : Container()
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
              key: Key("SignUpNextButton"),
              onPressed: () => widget.presenter.handleNextButtonPressed(),
              icon: Icon(
                Icons.arrow_back,
                color: rosewood,
              ),
              label: Text(
                "Next",
                style:
                    GoogleFonts.lato().copyWith(fontSize: 24, color: rosewood),
              ),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  primary: currentTheme.isDark ? mediumChampagne : indianYellow,
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10))),
        ));
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
          key: Key("SignUpPasswordBackButton"),
          onPressed: () => widget.presenter.handleBackButtonPressed(),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          label: Text(
            "Back",
            style:
                GoogleFonts.lato().copyWith(fontSize: 24, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              primary: deepSpaceSparkle,
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10))),
    );
  }

  Widget _buildSignUpButton() {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
              key: Key("SignUpSignUpButton"),
              onPressed: () async =>
                  widget.presenter.handleSignUpButtonPressed(),
              icon: Icon(
                Icons.arrow_upward,
                color: rosewood,
              ),
              label: Text(
                "Sign Up",
                style:
                    GoogleFonts.lato().copyWith(fontSize: 24, color: rosewood),
              ),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  primary: currentTheme.isDark ? mediumChampagne : indianYellow,
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10))),
        ));
  }
}

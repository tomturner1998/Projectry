import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/sign_up/sign_up_presenter.dart';
import 'package:project_finder/sign_up/sign_up_view.dart';

import '../../cloud_firestore_mocks.dart';

void main() async {
  setupCloudFirestoreMocks();

  Auth auth;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    auth = AuthImpl();
  });
  
  SignUpPresenter signUpPresenter = SignUpPresenter(auth);

  _widgetTests(signUpPresenter);
}

void _widgetTests(SignUpPresenter signUpPresenter) {
  Widget testWidget = MediaQuery(
      data: MediaQueryData(),
      child: MaterialApp(home: SignUp(signUpPresenter)));

  _hasEmailPage(testWidget);
  _hasPasswordPage(testWidget);
}

void _hasEmailPage(Widget testWidget) {
  testWidgets(
    "Sign Up Widget Has Email Input Page",
    (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      expect(find.byKey(Key("SignUpEmailInputHeader")), findsOneWidget);
      expect(find.byKey(Key("SignUpEmailInputField")), findsOneWidget);
      expect(find.byKey(Key("SignUpEmailInputButtonRow")), findsOneWidget);
      expect(find.byKey(Key("SignUpNextButton")), findsOneWidget);
    },
  );
}

void _hasPasswordPage(Widget testWidget) {
  testWidgets("Sign Up Widget Has Password Input", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.enterText(find.byKey(Key("SignUpEmailInputField")), "E-Mail");
    await tester.tap(find.byKey(Key("SignUpNextButton")));
    await tester.pumpWidget(testWidget);

    expect(find.byKey(Key("SignUpPasswordInputHeader")), findsOneWidget);
    expect(find.byKey(Key("SignUpPasswordInput")), findsOneWidget);
    expect(find.byKey(Key("SignUpConfirmPasswordInput")), findsOneWidget);
    expect(find.byKey(Key("SignUpPasswordButtonsRow")), findsOneWidget);
    expect(find.byKey(Key("SignUpPasswordBackButton")), findsOneWidget);
    expect(find.byKey(Key("SignUpSignUpButton")), findsOneWidget);
  });
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/custom_elements/external_sign_on_button.dart';
import 'package:project_finder/custom_elements/text_divider.dart';
import 'package:project_finder/login/login_presenter.dart';
import 'package:project_finder/login/login_view.dart';

import '../../cloud_firestore_mocks.dart';

void main() async {
  setupCloudFirestoreMocks();

  Auth auth;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    auth = AuthImpl();
  });

  LoginPresenter loginPresenter = LoginPresenter(auth);

  _widgetTests(loginPresenter);
}

void _widgetTests(LoginPresenter loginPresenter) {
  Widget testWidget = MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      home: Login(loginPresenter),
    ),
  );

  _hasTitle(testWidget);
  _hasDetailsFields(testWidget);
  _hasForgottenPasswordButton(testWidget);
  _forgottenPasswordButtonDisplaysModal(testWidget);
  _forgottenPasswordModalCanBeDismissed(testWidget);
  _hasSignUpAndSignInButtons(testWidget);
  _hasTextDivider(testWidget);
  _hasGoogleSignInButton(testWidget);
  _hasBottomClipper(testWidget);
}

void _hasTitle(Widget testWidget) {
  testWidgets("Login Screen has a Title", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    expect(find.text("Projectry"), findsOneWidget);
    expect(find.text("The University of Exeter"), findsOneWidget);
  });
}

void _hasDetailsFields(Widget testWidget) {
  testWidgets("Login Screen has Details Fields", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    expect(find.widgetWithText(TextField, "E-Mail"), findsOneWidget);
    expect(find.widgetWithText(TextField, "Password"), findsOneWidget);
  });
}

void _hasForgottenPasswordButton(Widget testWidget) {
  testWidgets("Login Screen has Forgotten Password Button",
      (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    expect(find.text("Forgotten"), findsOneWidget);
    expect(find.widgetWithText(GestureDetector, "Password?"), findsOneWidget);
  });
}

void _forgottenPasswordButtonDisplaysModal(Widget testWidget) {
  testWidgets("Login Screen Forgotten Password Button Displays Modal",
      (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.tap(find.widgetWithText(GestureDetector, "Password?"));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, "E-Mail"), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, "Send Password Reset E-Mail"),
        findsOneWidget);
  });
}

void _forgottenPasswordModalCanBeDismissed(Widget testWidget) {
  testWidgets("Login Screen Forgotten Password Modal Can Be Dismissed",
      (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.tap(find.widgetWithText(GestureDetector, "Password?"));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, "E-Mail"), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, "Send Password Reset E-Mail"),
        findsOneWidget);

    await tester.tap(find.text("Projectry"));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, "E-Mail"), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, "Send Password Reset E-Mail"),
        findsNothing);
  });
}

void _hasSignUpAndSignInButtons(Widget testWidget) {
  testWidgets("Login Screen has Sign Up and Sign In Buttons",
      (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    expect(find.widgetWithText(ElevatedButton, "Sign Up"), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, "Sign In"), findsOneWidget);
  });
}

void _hasTextDivider(Widget testWidget) {
  testWidgets("Login Screen has Text Divider", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    expect(find.widgetWithText(TextDivider, "OR"), findsOneWidget);
  });
}

void _hasGoogleSignInButton(Widget testWidget) {
  testWidgets("Login Screen has Google Sign In Button",
      (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    expect(find.widgetWithText(ExternalSignOnButton, "Sign in with Google"),
        findsOneWidget);
  });
}

void _hasBottomClipper(Widget testWidget) {
  testWidgets("Login Screen has Bottom Clipper", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    expect(find.byType(ClipPath), findsOneWidget);
  });
}

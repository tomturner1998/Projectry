import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/login/login_presenter.dart';
import 'package:project_finder/login/login_view.dart';

import '../../cloud_firestore_mocks.dart';

class MockAuth extends Mock implements Auth {}

class MockBuildContext extends Mock implements BuildContext {}

class MockLoginView extends Mock implements LoginView {}

class MockFToast extends Mock implements FToast {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  setupCloudFirestoreMocks();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  _runTests();
}

void _runTests() {
  _shouldSetView();
  _shouldHandlePasswordReset();
  _shouldHandleSignInWithGooglePressed();
  _shouldHandleSignIn();
}

void _shouldSetView() {
  test("Should set view", () async {
    Auth auth = MockAuth();
    BuildContext buildContext = MockBuildContext();
    LoginView loginView = MockLoginView();
    FToast fToast = MockFToast();

    LoginPresenter presenter = LoginPresenter(auth);

    presenter.view(loginView, buildContext, fToast);

    verify(loginView.update(false)).called(1);
  });
}

void _shouldHandlePasswordReset() {
  test("Should handle password reset", () async {
    Auth auth = MockAuth();
    BuildContext buildContext = MockBuildContext();
    LoginView loginView = MockLoginView();
    FToast fToast = MockFToast();

    LoginPresenter presenter = LoginPresenter(auth);

    presenter.view(loginView, buildContext, fToast);

    verify(loginView.update(false)).called(1);

    presenter.emailController.text = "email_Test";

    presenter.handlePasswordReset();

    verify(auth.sendPasswordResetEmail("email_Test")).called(1);
    verify(fToast.showToast(
            child: anyNamed("child"),
            gravity: anyNamed("gravity"),
            toastDuration: anyNamed("toastDuration")))
        .called(1);

    presenter.emailController.text = "";

    presenter.handlePasswordReset();

    verifyNever(auth.sendPasswordResetEmail(""));
    verify(fToast.showToast(
            child: anyNamed("child"),
            gravity: anyNamed("gravity"),
            toastDuration: anyNamed("toastDuration")))
        .called(1);
  });
}

void _shouldHandleSignInWithGooglePressed() {
  test("Should handle sign in with google pressed", () async {
    Auth auth = MockAuth();
    BuildContext buildContext = MockBuildContext();
    LoginView loginView = MockLoginView();
    FToast fToast = MockFToast();
    GoogleSignIn googleSignIn = MockGoogleSignIn();
    FirebaseAuth firebaseAuth = MockFirebaseAuth();

    LoginPresenter presenter = LoginPresenter(auth);

    presenter.view(loginView, buildContext, fToast);

    verify(loginView.update(false)).called(1);

    presenter.handleSignInWithGoogle(googleSignIn, firebaseAuth);

    verify(auth.signInWithGoogle(googleSignIn, firebaseAuth));
  });
}

void _shouldHandleSignIn() {
  test("Should handle sign in", () async {
    Auth auth = MockAuth();
    BuildContext buildContext = MockBuildContext();
    LoginView loginView = MockLoginView();
    FToast fToast = MockFToast();
    User user = MockUser();

    when(auth.emailSignIn(any, any)).thenAnswer((_) async => user);

    LoginPresenter presenter = LoginPresenter(auth);

    presenter.emailController.text = "email";
    presenter.passwordController.text = "password";

    presenter.view(loginView, buildContext, fToast);

    verify(loginView.update(false)).called(1);

    await presenter.handleSignIn();

    verify(loginView.update(true)).called(1);
    verify(loginView.update(false)).called(1);
    verify(auth.logIn(buildContext, user));

    when(auth.emailSignIn(any, any)).thenAnswer((_) async => null);

    presenter = LoginPresenter(auth);

    presenter.emailController.text = "email";
    presenter.passwordController.text = "password";

    presenter.view(loginView, buildContext, fToast);

    verify(loginView.update(false)).called(1);

    await presenter.handleSignIn();

    verify(loginView.update(true)).called(1);
    verify(loginView.update(false)).called(1);
    verifyNever(auth.logIn(buildContext, user));
    verify(fToast.showToast(
            child: anyNamed("child"),
            gravity: anyNamed("gravity"),
            toastDuration: anyNamed("toastDuration")))
        .called(1);
  });
}

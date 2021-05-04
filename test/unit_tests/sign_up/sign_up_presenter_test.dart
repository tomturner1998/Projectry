import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/sign_up/sign_up_presenter.dart';
import 'package:project_finder/sign_up/sign_up_view.dart';

import '../../cloud_firestore_mocks.dart';

class MockAuth extends Mock implements Auth {}

class MockView extends Mock implements SignUpView {}

class MockContext extends Mock implements BuildContext {}

void main() {
  setupCloudFirestoreMocks();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  runTests();
}

void runTests() {
  shouldSetView();
  shouldHandleNextPressed();
  shouldHandleBackPressed();
  shouldVerifyPassword();
}

void shouldSetView() {
  test("Presenter Can Set View Correctly", () async {
    Auth mockAuth = MockAuth();

    SignUpPresenter presenter = SignUpPresenter(mockAuth);

    SignUpView mockView = MockView();
    BuildContext mockContext = MockContext();

    presenter.view(mockView, mockContext);

    verify(mockView.update(any)).called(1);
  });
}

void shouldHandleNextPressed() {
  test("Should Handle Next Pressed", () async {
    Auth mockAuth = MockAuth();

    SignUpPresenter presenter = SignUpPresenter(mockAuth);

    SignUpView mockView = MockView();
    BuildContext mockContext = MockContext();

    presenter.view(mockView, mockContext);

    verify(mockView.update("email")).called(1);

    presenter.emailController.text = "Email@email.email";

    presenter.handleNextButtonPressed();

    verify(mockView.update("password")).called(1);
  });
}

void shouldHandleBackPressed() {
  test("Should Handle Back Pressed", () async {
    Auth mockAuth = MockAuth();

    SignUpPresenter presenter = SignUpPresenter(mockAuth);

    SignUpView mockView = MockView();
    BuildContext mockContext = MockContext();

    presenter.view(mockView, mockContext);

    verify(mockView.update("email")).called(1);

    presenter.emailController.text = "Email@email.email";

    presenter.handleNextButtonPressed();

    verify(mockView.update("password")).called(1);

    presenter.handleBackButtonPressed();

    verify(mockView.update("email")).called(1);
  });
}

void shouldVerifyPassword() {
  test("Should Verify Password", () async {
    Auth mockAuth = MockAuth();

    SignUpPresenter presenter = SignUpPresenter(mockAuth);
    
    expect(presenter.invalidPassword("password"), true);
    expect(presenter.invalidPassword("password1"), true);
    expect(presenter.invalidPassword("Password1"), false);
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/profile/profile_presenter.dart';
import 'package:project_finder/profile/profile_view.dart';

import '../../cloud_firestore_mocks.dart';

class MockAuth extends Mock implements Auth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockView extends Mock implements ProfileView {}

void main() {
  setupCloudFirestoreMocks();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  _runTests();
}

void _runTests() {
  _shouldSetView();
}

void _shouldSetView() {
  test("Should Set View", () async {
    FirebaseFirestore mockFirebaseFirestore = MockFirebaseFirestore();
    Auth mockAuth = MockAuth();

    ProfilePresenter presenter =
        ProfilePresenter(mockFirebaseFirestore, mockAuth);

    ProfileView mockView = MockView();

    presenter.view = mockView;

    verify(mockView.update(any, any, any, any, any, any)).called(1);
  });
}
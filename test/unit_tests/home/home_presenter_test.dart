import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/home/home_presenter.dart';
import 'package:project_finder/home/home_view.dart';
import 'package:project_finder/model/firestore_user.dart';

import '../../cloud_firestore_mocks.dart';

class MockFirestoreUser extends Mock implements FirestoreUser {}

class MockAuth extends Mock implements Auth {}

class MockView extends Mock implements HomeView {}

void main() {
  setupCloudFirestoreMocks();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  runTests();
}

void runTests() {
  shouldSetView();
  shouldLoadModel();
}

void shouldSetView() {
  test("Presenter Can Set View Correctly", () async {
    FirestoreUser mockFirestoreUser = MockFirestoreUser();
    Auth mockAuth = MockAuth();

    HomePresenter presenter = HomePresenter.test(mockFirestoreUser, mockAuth);

    HomeView mockView = MockView();

    presenter.view(mockView);

    verify(mockView.update(any)).called(1);
  });
}

void shouldLoadModel() {
  test("Loads Model", () async {
    FirestoreUser mockFirestoreUser = MockFirestoreUser();
    Auth mockAuth = MockAuth();

    when(mockAuth.getCurrentFirestoreUser())
        .thenAnswer((_) async => mockFirestoreUser);

    HomePresenter presenter = HomePresenter.test(mockFirestoreUser, mockAuth);

    HomeView mockView = MockView();

    presenter.view(mockView);

    presenter.loadModel();

    Future(expectAsync0(() {
      verify(mockView.update(any)).called(2);
    }));
  });
}
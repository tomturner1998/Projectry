import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/home/home_presenter.dart';
import 'package:project_finder/home/home_view.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/model/roles.dart';

import '../../cloud_firestore_mocks.dart';

class MockFirestoreUser extends Mock implements FirestoreUser {}

void main() async {
  setupCloudFirestoreMocks();

  Auth auth;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    auth = AuthImpl();
  });

  _widgetTests(auth);
}

void _widgetTests(Auth auth) {
  _loadsStudentHomePage(auth);
  _loadsSupervisorHomePage(auth);
  _canOpenSettings(auth);
}

void _loadsStudentHomePage(Auth auth) {
  FirestoreUser mockUser = MockFirestoreUser();
  when(mockUser.role).thenReturn(Role.Student);

  HomePresenter homePresenter = HomePresenter.test(mockUser, auth);

  Widget testWidget = MediaQuery(
      data: MediaQueryData(), child: MaterialApp(home: Home(homePresenter)));

  testWidgets("Loads Student Home Page", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    expect(find.byKey(Key("BrowseProjectsButton")), findsOneWidget);
  });
}

void _loadsSupervisorHomePage(Auth auth) {
  FirestoreUser mockUser = MockFirestoreUser();
  when(mockUser.role).thenReturn(Role.Supervisor);

  HomePresenter homePresenter = HomePresenter.test(mockUser, auth);

  Widget testWidget = MediaQuery(
      data: MediaQueryData(), child: MaterialApp(home: Home(homePresenter)));

  testWidgets("Loads Supervisor Home Page", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    expect(find.byKey(Key("ProjectsForApprovalButton")), findsOneWidget);
    expect(find.byKey(Key("SupervisionOverviewButton")), findsOneWidget);
  });
}

void _canOpenSettings(Auth auth) {
  FirestoreUser mockUser = MockFirestoreUser();
  when(mockUser.role).thenReturn(Role.Supervisor);

  HomePresenter homePresenter = HomePresenter.test(mockUser, auth);

  Widget testWidget = MediaQuery(
      data: MediaQueryData(), child: MaterialApp(home: Home(homePresenter)));

  testWidgets("Can Switch Theme", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    expect(find.byKey(Key("HomeSettingsButton")), findsOneWidget);

    await tester.tap(find.byKey(Key("HomeSettingsButton")));
    await tester.pumpAndSettle();

    expect(find.byKey(Key("ThemeSwitch")), findsOneWidget);
  });
}

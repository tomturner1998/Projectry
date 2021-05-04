import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/model/project.dart';
import 'package:project_finder/model/roles.dart';
import 'package:project_finder/model/user_with_provisional.dart';
import 'package:project_finder/supervision_overview/supervision_overview.view.dart';
import 'package:project_finder/supervision_overview/supervision_overview_presenter.dart';

import '../../cloud_firestore_mocks.dart';

class MockAuth extends Mock implements Auth {}

class MockUser extends Mock implements User {}

class MockDatabaseReference extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {}

void main() async {
  setupCloudFirestoreMocks();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  Auth auth = MockAuth();
  User user = MockUser();

  when(user.uid).thenReturn("test-user-id");
  when(auth.getCurrentUser()).thenReturn(user);

  FirebaseFirestore databaseReference = MockDatabaseReference();
  CollectionReference projectsCollectionReference = MockCollectionReference();
  QuerySnapshot projectQuerySnapshot = MockQuerySnapshot();
  QueryDocumentSnapshot projectDocumentSnapshot = MockQueryDocumentSnapshot();

  when(projectDocumentSnapshot.data()).thenReturn(Project(
      title: "Test Project",
      submitter: "test-user-id",
      claimedBy: [
        UserWithProvisional(userId: "claimer-id", provisional: false)
      ]).toMap());

  List<QueryDocumentSnapshot> projectDocumentSnapshots = [
    projectDocumentSnapshot
  ];

  when(projectQuerySnapshot.docs).thenReturn(projectDocumentSnapshots);
  when(projectsCollectionReference.snapshots())
      .thenAnswer((_) => Stream.value(projectQuerySnapshot));
  when(databaseReference.collection("projects"))
      .thenReturn(projectsCollectionReference);

  CollectionReference usersCollectionReference = MockCollectionReference();
  QuerySnapshot usersQuerySnapshot = MockQuerySnapshot();
  QueryDocumentSnapshot usersDocumentSnapshot = MockQueryDocumentSnapshot();

  when(usersDocumentSnapshot.id).thenReturn("claimer-id");
  when(usersDocumentSnapshot.data()).thenReturn(FirestoreUser(
          id: "claimer-id",
          fullName: "Test User",
          email: "test@email.eu",
          preferences: [],
          role: Role.Student)
      .toMap());

  List<QueryDocumentSnapshot> usersDocumentSnapshots = [usersDocumentSnapshot];

  when(usersQuerySnapshot.docs).thenReturn(usersDocumentSnapshots);
  when(usersCollectionReference.snapshots())
      .thenAnswer((_) => Stream.value(usersQuerySnapshot));
  when(databaseReference.collection("users"))
      .thenReturn(usersCollectionReference);

  SupervisionOverviewPresenter presenter =
      SupervisionOverviewPresenter(auth, databaseReference);

  _widgetTests(presenter);
}

void _widgetTests(SupervisionOverviewPresenter presenter) {
  Widget testWidget = MediaQuery(
      data: MediaQueryData(),
      child: MaterialApp(
        home: SupervisionOverview(presenter),
      ));

  _shouldHaveTitle(testWidget);
  _shouldHaveStudent(testWidget);
  _shouldOpenStudentModal(testWidget);
}

void _shouldHaveTitle(Widget testWidget) {
  testWidgets("Should render title correctly", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.idle();
    await tester.pumpAndSettle();
    expect(find.text("Supervision Overview"), findsOneWidget);
    expect(find.text("Students:"), findsOneWidget);
  });
}

void _shouldHaveStudent(Widget testWidget) {
  testWidgets("Should have student and project name rendered",
      (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.idle();
    await tester.pumpAndSettle();
    expect(find.text("Test User"), findsOneWidget);
    expect(find.text("• Test Project"), findsOneWidget);
  });
}

void _shouldOpenStudentModal(Widget testWidget) {
  testWidgets("Should open student modal", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.idle();
    await tester.pumpAndSettle();

    await tester.tap(find.text("Test User"));
    await tester.pumpAndSettle();
    await tester.idle();

    expect(find.text("Overview"), findsOneWidget);
    expect(find.text("test@email.eu"), findsOneWidget);
  });
}

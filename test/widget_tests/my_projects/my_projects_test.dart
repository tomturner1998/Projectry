import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/model/project.dart';
import 'package:project_finder/model/roles.dart';
import 'package:project_finder/model/user_with_provisional.dart';
import 'package:project_finder/my_projects/my_projects_presenter.dart';
import 'package:project_finder/my_projects/my_projects_view.dart';

import '../../cloud_firestore_mocks.dart';

class MockAuth extends Mock implements Auth {}

class MockDatabaseReference extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockUser extends Mock implements User {}

void main() async {
  setupCloudFirestoreMocks();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  Auth auth = MockAuth();
  User currentUser = MockUser();

  when(currentUser.uid).thenReturn("test-user-id");
  when(auth.getCurrentUser()).thenReturn(currentUser);

  FirebaseFirestore databaseReference = MockDatabaseReference();
  CollectionReference usersCollectionReference = MockCollectionReference();
  DocumentReference userDocumentReference = MockDocumentReference();
  DocumentSnapshot userDocumentSnapshot = MockDocumentSnapshot();

  when(userDocumentSnapshot.data())
      .thenReturn(FirestoreUser(role: Role.Student).toMap());
  when(userDocumentReference.get())
      .thenAnswer((_) async => userDocumentSnapshot);
  when(usersCollectionReference.doc(any)).thenReturn(userDocumentReference);

  QuerySnapshot usersQuerySnapshot = MockQuerySnapshot();
  QueryDocumentSnapshot userQueryDocumentSnapshot = MockQueryDocumentSnapshot();

  when(userQueryDocumentSnapshot.get("role"))
      .thenReturn(Role.Student.toString());
  when(userQueryDocumentSnapshot.data()).thenReturn(FirestoreUser(
          fullName: "Test Supervisor",
          email: "supervisor@email.test",
          role: Role.Supervisor,
          preferences: [],
          id: "supervisor-id")
      .toMap());
  when(usersQuerySnapshot.docs).thenReturn([userQueryDocumentSnapshot]);
  when(usersCollectionReference.get())
      .thenAnswer((_) async => usersQuerySnapshot);
  when(databaseReference.collection("users"))
      .thenReturn(usersCollectionReference);

  CollectionReference topicsCollectionReference = MockCollectionReference();
  QuerySnapshot topicsQuerySnapshot = MockQuerySnapshot();
  QueryDocumentSnapshot topicQueryDocumentSnapshot =
      MockQueryDocumentSnapshot();

  when(topicQueryDocumentSnapshot.get("name")).thenReturn("Test Topic");
  when(topicsQuerySnapshot.docs).thenReturn([topicQueryDocumentSnapshot]);
  when(topicsCollectionReference.get())
      .thenAnswer((_) async => topicsQuerySnapshot);
  when(databaseReference.collection("topics"))
      .thenReturn(topicsCollectionReference);

  CollectionReference projectsCollectionReference = MockCollectionReference();
  QuerySnapshot projectsQuerySnapshot = MockQuerySnapshot();
  QueryDocumentSnapshot projectQueryDocumentSnapshot =
      MockQueryDocumentSnapshot();
  QueryDocumentSnapshot projectQueryDocumentSnapshotA =
      MockQueryDocumentSnapshot();
  DocumentReference topicDocumentReference = MockDocumentReference();
  DocumentSnapshot topicDocumentSnapshot = MockDocumentSnapshot();

  when(topicDocumentSnapshot.data()).thenReturn({"name": "Test Topic"});
  when(topicDocumentReference.get())
      .thenAnswer((_) async => topicDocumentSnapshot);
  when(projectQueryDocumentSnapshot.data()).thenReturn(Project(
          title: "Test Project",
          briefDescription: "Test Project Description",
          submitter: "test-user-id",
          supervisor: "supervisor-id",
          approved: true,
          claimedBy: [],
          field: topicDocumentReference)
      .toMap());
  when(projectQueryDocumentSnapshotA.data()).thenReturn(Project(
          title: "Test Supervisor Project",
          briefDescription: "Test Supervisor Project Description",
          submitter: "supervisor-id",
          claimedBy: [
            UserWithProvisional(userId: "test-user-id", provisional: false)
          ],
          field: topicDocumentReference)
      .toMap());
  when(projectsQuerySnapshot.docs).thenReturn(
      [projectQueryDocumentSnapshot, projectQueryDocumentSnapshotA]);
  when(projectsCollectionReference.snapshots())
      .thenAnswer((_) => Stream.value(projectsQuerySnapshot));
  when(databaseReference.collection("projects"))
      .thenReturn(projectsCollectionReference);

  MyProjectsPresenter presenter = MyProjectsPresenter(auth, databaseReference);

  _widgetTests(presenter);
}

void _widgetTests(MyProjectsPresenter presenter) {
  Widget testWidget = MediaQuery(
      data: MediaQueryData(),
      child: MaterialApp(
        home: MyProjects(presenter),
      ));

  _shouldRender(testWidget);
  _shouldNavigateProjectCreation(testWidget);
}

void _shouldRender(Widget testWidget) {
  testWidgets("Should render my projects", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.idle();
    await tester.pumpAndSettle();

    expect(find.text("Test Project"), findsOneWidget);
    expect(find.text("Test Project Description"), findsOneWidget);
    expect(find.text("Test Supervisor Project"), findsOneWidget);
    expect(find.text("Test Supervisor Project Description"), findsOneWidget);
  });
}

void _shouldNavigateProjectCreation(Widget testWidget) {
  testWidgets("Should navigate project creation", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.idle();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("CreateProjectButton")));
    await tester.pumpAndSettle();

    expect(find.text("What is the Title of Your Project?"), findsOneWidget);

    await tester.tap(find.byKey(Key("CreateProjectTitleInput")));
    await tester.enterText(
        find.byKey(Key("CreateProjectTitleInput")), "Test Project Title");
    await tester.tap(find.text("Next"));
    await tester.pumpAndSettle();

    expect(find.text("Please Describe Your Project"), findsOneWidget);

    await tester.tap(find.byKey(Key("CreateProjectDescriptionInput")));
    await tester.enterText(find.byKey(Key("CreateProjectDescriptionInput")),
        "Test Project Description");
    await tester.tap(find.text("Next"));
    await tester.pumpAndSettle();

    expect(
        find.text("Please Select The Topic Of Your Project:"), findsOneWidget);

    await tester.tap(find.text("Test Topic"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Next"));
    await tester.pumpAndSettle();

    expect(
        find.text(
            "Who is Your Prefered Supervisor for this Project? (Optional)"),
        findsOneWidget);
    expect(find.text("Create Project"), findsOneWidget);
  });
}

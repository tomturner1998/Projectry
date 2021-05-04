import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/model/project.dart';
import 'package:project_finder/model/roles.dart';
import 'package:project_finder/projects_for_approval/projects_for_approval_presenter.dart';
import 'package:project_finder/projects_for_approval/projects_for_approval_view.dart';

import '../../cloud_firestore_mocks.dart';

class MockAuth extends Mock implements Auth {}

class MockDatabaseReference extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() async {
  setupCloudFirestoreMocks();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  Auth auth = MockAuth();

  FirebaseFirestore databaseReference = MockDatabaseReference();
  CollectionReference projectsCollectionReference = MockCollectionReference();
  QuerySnapshot projectQuerySnapshot = MockQuerySnapshot();
  QueryDocumentSnapshot projectDocumentSnapshot = MockQueryDocumentSnapshot();
  DocumentSnapshot topicSnapshot = MockDocumentSnapshot();

  when(topicSnapshot.data()).thenReturn({"name": "Test Topic"});

  DocumentReference topicReference = MockDocumentReference();

  when(topicReference.get()).thenAnswer((_) async => topicSnapshot);
  when(projectDocumentSnapshot.data()).thenReturn(Project(
      title: "Test Project",
      briefDescription: "Test Project Description",
      submitter: "submitter-id",
      preferredSupervisor: "test-user-id",
      field: topicReference,
      approved: false,
      claimedBy: []).toMap());

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

  FirestoreUser firestoreUser = FirestoreUser(
      id: "submitter-id",
      fullName: "Test User",
      preferences: [topicReference],
      role: Role.Student);

  when(usersDocumentSnapshot.id).thenReturn("submitter-id");
  when(usersDocumentSnapshot.data()).thenReturn(firestoreUser.toMap());
  when(auth.getCurrentFirestoreUser()).thenAnswer((_) async => firestoreUser);

  List<QueryDocumentSnapshot> usersDocumentSnapshots = [usersDocumentSnapshot];

  when(usersQuerySnapshot.docs).thenReturn(usersDocumentSnapshots);
  when(usersCollectionReference.snapshots())
      .thenAnswer((_) => Stream.value(usersQuerySnapshot));

  DocumentReference submitterDocRef = MockDocumentReference();
  DocumentSnapshot submitterDocSnapshot = MockDocumentSnapshot();
  
  when(submitterDocSnapshot.data()).thenReturn(firestoreUser.toMap());
  when(submitterDocRef.snapshots()).thenAnswer((_) => Stream.value(submitterDocSnapshot));
  when(usersCollectionReference.doc("submitter-id")).thenReturn(submitterDocRef);
  when(databaseReference.collection("users"))
      .thenReturn(usersCollectionReference);

  ProjectsForApprovalPresenter presenter =
      ProjectsForApprovalPresenter(databaseReference, auth);

  _widgetTests(presenter);
}

void _widgetTests(ProjectsForApprovalPresenter presenter) {
  Widget testWidget = MediaQuery(
      data: MediaQueryData(),
      child: MaterialApp(home: ProjectsForApproval(presenter)));

  _shouldHaveTitle(testWidget);
  _shouldRenderProjectsForApproval(testWidget);
  _shouldTapOnProject(testWidget);
  _shouldTapOnHelpModal(testWidget);
}

void _shouldHaveTitle(Widget testWidget) {
  testWidgets("Should render title", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.idle();
    await tester.pumpAndSettle();
    expect(find.text("Projects:"), findsOneWidget);
  });
}

void _shouldRenderProjectsForApproval(Widget testWidget) {
  testWidgets("Should render projects", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.idle();
    await tester.pumpAndSettle();
    expect(find.text("Test Project"), findsOneWidget);
    expect(find.text("Test User"), findsOneWidget);
  });
}

void _shouldTapOnProject(Widget testWidget) {
  testWidgets("Should tap on project", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.idle();
    await tester.pumpAndSettle();

    expect(find.text("Test Project"), findsOneWidget);
    expect(find.text("Test User"), findsOneWidget);

    await tester.tap(find.text("Test User"));
    await tester.pumpAndSettle();
    await tester.idle();

    expect(find.text("Overview"), findsOneWidget);
  });
}

void _shouldTapOnHelpModal(Widget testWidget) {
  testWidgets("should open help modal", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.idle();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key("ProjectsForApprovalHelpButton")));
    await tester.pumpAndSettle();
    await tester.idle();

    expect(find.text("Help"), findsOneWidget);
  });
}

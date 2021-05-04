import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/model/roles.dart';
import 'package:project_finder/profile/profile_presenter.dart';
import 'package:project_finder/profile/profile_view.dart';

import '../../cloud_firestore_mocks.dart';

class MockAuth extends Mock implements Auth {}

class MockDatabaseReference extends Mock implements FirebaseFirestore {}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

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

  DocumentSnapshot topicSnapshot = MockDocumentSnapshot();

  when(topicSnapshot.data()).thenReturn({"name": "Test Topic"});

  DocumentReference topicReference = MockDocumentReference();

  when(topicReference.get()).thenAnswer((_) async => topicSnapshot);

  FirestoreUser firestoreUser = FirestoreUser(
      id: "submitter-id",
      fullName: "Test User",
      email: "test@email.org.uk",
      preferences: [topicReference],
      role: Role.Student);

  when(auth.getCurrentFirestoreUser()).thenAnswer((_) async => firestoreUser);

  FirebaseFirestore databaseReference = MockDatabaseReference();

  CollectionReference topicCollectionReference = MockCollectionReference();
  QuerySnapshot topicQuerySnapshot = MockQuerySnapshot();
  QueryDocumentSnapshot topicDocumentSnapshot = MockQueryDocumentSnapshot();

  when(topicDocumentSnapshot.data()).thenReturn({"name": "Test Topic"});
  when(topicQuerySnapshot.docs).thenReturn([topicDocumentSnapshot]);
  when(topicCollectionReference.snapshots())
      .thenAnswer((_) => Stream.value(topicQuerySnapshot));
  when(databaseReference.collection("topics"))
      .thenReturn(topicCollectionReference);

  ProfilePresenter presenter = ProfilePresenter(databaseReference, auth);

  _widgetTests(presenter);
}

void _widgetTests(ProfilePresenter presenter) {
  Widget testWidget = MediaQuery(
      data: MediaQueryData(), child: MaterialApp(home: Profile(presenter)));

  _shouldRenderHeader(testWidget);
}

void _shouldRenderHeader(Widget testWidget) {
  testWidgets("Should render header", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.idle();
    await tester.pumpAndSettle();

    expect(find.text("Test User"), findsOneWidget);
    expect(find.text("test@email.org.uk"), findsOneWidget);
    expect(find.text("Student"), findsOneWidget);
  });
}

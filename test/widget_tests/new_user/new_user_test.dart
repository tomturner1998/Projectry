import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/new_user/new_user_presenter.dart';
import 'package:project_finder/new_user/new_user_view.dart';

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
  FirebaseFirestore databaseReference = MockDatabaseReference();
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

  User currentUser = MockUser();

  when(currentUser.uid).thenReturn("test-user-id");
  when(currentUser.email).thenReturn("test-user@email.test");
  when(auth.getCurrentUser()).thenReturn(currentUser);

  CollectionReference usersCollectionReference = MockCollectionReference();
  DocumentReference userDocumentReference = MockDocumentReference();

  when(usersCollectionReference.doc(any)).thenReturn(userDocumentReference);
  when(databaseReference.collection("users"))
      .thenReturn(usersCollectionReference);

  NewUserPresenter presenter = NewUserPresenter(databaseReference, auth);

  _widgetTests(presenter);
}

void _widgetTests(NewUserPresenter presenter) {
  Widget testWidget = MediaQuery(
      data: MediaQueryData(),
      child: MaterialApp(
        home: NewUser(presenter),
        onUnknownRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) => Container());
        },
      ));

  _shouldNavigateSections(testWidget);
}

void _shouldNavigateSections(Widget testWidget) {
  testWidgets("Should navigate sections", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    expect(find.text("Please Enter Your Name:"), findsOneWidget);

    await tester.tap(find.byKey(Key("NewUserNameField")));
    await tester.enterText(find.byKey(Key("NewUserNameField")), "Test Name");
    await tester.tap(find.byKey(Key("NewUserNameNextButton")));
    await tester.pumpAndSettle();

    expect(find.text("Please Selector Your Role:"), findsOneWidget);

    await tester.tap(find.text("Next"));
    await tester.pumpAndSettle();

    expect(find.text("Please Select Your Topic Specialities / Preferences:"),
        findsOneWidget);
    expect(find.text("Test Topic"), findsOneWidget);

    await tester.tap(find.text("Test Topic"));
    await tester.tap(find.text("Confirm"));
    await tester.pumpAndSettle();
  });
}

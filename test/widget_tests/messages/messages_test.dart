import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/messages/message_presenter.dart';
import 'package:project_finder/messages/message_view.dart';

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

  MessagePresenter presenter = MessagePresenter(databaseReference, auth);

  _widgetTests(presenter);
}

void _widgetTests(MessagePresenter presenter) {
  Widget testWidget = MediaQuery(
      data: MediaQueryData(), child: MaterialApp(home: Messages(presenter)));

  _shouldRenderMessages(testWidget);
}

void _shouldRenderMessages(Widget testWidget) {
  testWidgets("Should render messages", (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
  });
}

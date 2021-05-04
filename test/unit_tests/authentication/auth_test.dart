import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:project_finder/authentication/auth.dart';

import '../../cloud_firestore_mocks.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  setupCloudFirestoreMocks();
  
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  runTests();
}

void runTests() {
  _googleSignInTest();
}

void _googleSignInTest() {
  test("Google Sign In Succeeds", () async {
    final Auth auth = AuthImpl();
    
    final googleSignIn = MockGoogleSignIn();
    final googleSignInAccount = MockGoogleSignInAccount();
    final googleSignInAuthentication = MockGoogleSignInAuthentication();

    final firebaseAuth = MockFirebaseAuth();

    final userCredential = MockUserCredential();
    final user = MockUser();

    final accessToken = "test";
    final idToken = "test";

    when(googleSignInAuthentication.accessToken).thenReturn(accessToken);
    when(googleSignInAuthentication.idToken).thenReturn(idToken);
    when(googleSignInAccount.authentication)
        .thenAnswer((_) async => googleSignInAuthentication);
    when(googleSignIn.signIn()).thenAnswer((_) async => googleSignInAccount);

    when(firebaseAuth.signInWithCredential(any))
        .thenAnswer((_) async => userCredential);
    when(firebaseAuth.currentUser).thenReturn(user);

    when(user.isAnonymous).thenReturn(false);
    when(user.uid).thenReturn("testUID");
    when(user.getIdToken()).thenAnswer((_) async => accessToken);
    when(userCredential.user).thenReturn(user);

    expect(await auth.signInWithGoogle(googleSignIn, firebaseAuth), isNotNull);
  });

  test("Google Sign In Returns Null If No User", () async {
    final Auth auth = AuthImpl();

    final googleSignIn = MockGoogleSignIn();
    final googleSignInAccount = MockGoogleSignInAccount();
    final googleSignInAuthentication = MockGoogleSignInAuthentication();

    final firebaseAuth = MockFirebaseAuth();

    final userCredential = MockUserCredential();
    final user = MockUser();

    final accessToken = "test";
    final idToken = "test";

    when(googleSignInAuthentication.accessToken).thenReturn(accessToken);
    when(googleSignInAuthentication.idToken).thenReturn(idToken);
    when(googleSignInAccount.authentication)
        .thenAnswer((_) async => googleSignInAuthentication);
    when(googleSignIn.signIn()).thenAnswer((_) async => googleSignInAccount);

    when(firebaseAuth.signInWithCredential(any))
        .thenAnswer((_) async => userCredential);
    when(firebaseAuth.currentUser).thenReturn(user);

    when(user.isAnonymous).thenReturn(false);
    when(user.uid).thenReturn("testUID");
    when(user.getIdToken()).thenAnswer((_) async => accessToken);

    expect(await auth.signInWithGoogle(googleSignIn, firebaseAuth), isNull);
  });

  test("Google Sign In Fails if User is Anonymous", () {
    final Auth auth = AuthImpl();

    final googleSignIn = MockGoogleSignIn();
    final googleSignInAccount = MockGoogleSignInAccount();
    final googleSignInAuthentication = MockGoogleSignInAuthentication();

    final firebaseAuth = MockFirebaseAuth();

    final userCredential = MockUserCredential();
    final user = MockUser();

    final accessToken = "test";
    final idToken = "test";

    when(googleSignInAuthentication.accessToken).thenReturn(accessToken);
    when(googleSignInAuthentication.idToken).thenReturn(idToken);
    when(googleSignInAccount.authentication)
        .thenAnswer((_) async => googleSignInAuthentication);
    when(googleSignIn.signIn()).thenAnswer((_) async => googleSignInAccount);

    when(firebaseAuth.signInWithCredential(any))
        .thenAnswer((_) async => userCredential);
    when(firebaseAuth.currentUser).thenReturn(user);

    when(user.isAnonymous).thenReturn(true);
    when(user.uid).thenReturn("testUID");
    when(user.getIdToken()).thenAnswer((_) async => accessToken);
    when(userCredential.user).thenReturn(user);

    expect(() async => await auth.signInWithGoogle(googleSignIn, firebaseAuth), throwsAssertionError);
  });

  test("Google Sign In Fails if User Doesn't Have Access Token", () {
    final Auth auth = AuthImpl();

    final googleSignIn = MockGoogleSignIn();
    final googleSignInAccount = MockGoogleSignInAccount();
    final googleSignInAuthentication = MockGoogleSignInAuthentication();

    final firebaseAuth = MockFirebaseAuth();

    final userCredential = MockUserCredential();
    final user = MockUser();

    final accessToken = "test";
    final idToken = "test";

    when(googleSignInAuthentication.accessToken).thenReturn(accessToken);
    when(googleSignInAuthentication.idToken).thenReturn(idToken);
    when(googleSignInAccount.authentication)
        .thenAnswer((_) async => googleSignInAuthentication);
    when(googleSignIn.signIn()).thenAnswer((_) async => googleSignInAccount);

    when(firebaseAuth.signInWithCredential(any))
        .thenAnswer((_) async => userCredential);
    when(firebaseAuth.currentUser).thenReturn(user);

    when(user.isAnonymous).thenReturn(false);
    when(user.uid).thenReturn("testUID");
    when(user.getIdToken()).thenAnswer((_) async => null);
    when(userCredential.user).thenReturn(user);

    expect(() async => await auth.signInWithGoogle(googleSignIn, firebaseAuth), throwsAssertionError);
  });

  test("Google Sign In Fails if IDs Do Not Match", () {
    final Auth auth = AuthImpl();

    final googleSignIn = MockGoogleSignIn();
    final googleSignInAccount = MockGoogleSignInAccount();
    final googleSignInAuthentication = MockGoogleSignInAuthentication();

    final firebaseAuth = MockFirebaseAuth();

    final userCredential = MockUserCredential();
    final user = MockUser();
    final differentUser = MockUser();

    final accessToken = "test";
    final idToken = "test";

    when(googleSignInAuthentication.accessToken).thenReturn(accessToken);
    when(googleSignInAuthentication.idToken).thenReturn(idToken);
    when(googleSignInAccount.authentication)
        .thenAnswer((_) async => googleSignInAuthentication);
    when(googleSignIn.signIn()).thenAnswer((_) async => googleSignInAccount);

    when(firebaseAuth.signInWithCredential(any))
        .thenAnswer((_) async => userCredential);
    when(differentUser.uid).thenReturn("notTheSame");
    when(firebaseAuth.currentUser).thenReturn(differentUser);

    when(user.isAnonymous).thenReturn(false);
    when(user.uid).thenReturn("testUID");
    when(user.getIdToken()).thenAnswer((_) async => accessToken);
    when(userCredential.user).thenReturn(user);

    expect(() async => await auth.signInWithGoogle(googleSignIn, firebaseAuth),
        throwsAssertionError);
  });
}

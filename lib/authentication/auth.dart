import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_finder/model/firestore_user.dart';

import 'package:project_finder/navigation/paths.dart';

class Auth {
  Future<User> signInWithGoogle(GoogleSignIn googleSignIn, FirebaseAuth auth) {}
  Future<User> emailSignIn(String email, String password) {}
  Future<User> emailSignUp(
      String email, String password, Function toastCallback) {}
  Future<void> signOut(GoogleSignIn googleSignIn) {}
  void sendPasswordResetEmail(String email) {}
  User getCurrentUser() {}
  Future<FirestoreUser> getCurrentFirestoreUser() {}
  Future<bool> userExists(String id) {}
  Future<void> logIn(BuildContext context, User user) {}
}

class AuthImpl implements Auth {
  static Auth INSTANCE = AuthImpl();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User> signInWithGoogle(
      GoogleSignIn googleSignIn, FirebaseAuth auth) async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = auth.currentUser;
      assert(user.uid == currentUser.uid);

      print('signInWithGoogle succeeded: $user');

      return user;
    }

    return null;
  }

  Future<User> emailSignIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return null;
      } else if (e.code == 'wrong-password') {
        return null;
      }
    }

    return null;
  }

  Future<User> emailSignUp(
      String email, String password, Function toastCallback) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        toastCallback("E-Mail is Invalid");
      } else if (e.code == 'weak-password') {
        toastCallback("Password Must Be At Least 6 Chars");
      } else if (e.code == 'email-already-in-use') {
        toastCallback("E-Mail Already In Use");
      }

      return null;
    }
  }

  Future<void> signOut(GoogleSignIn googleSignIn) async {
    await googleSignIn.signOut();
    await _auth.signOut();

    print("User Signed Out");
  }

  void sendPasswordResetEmail(String email) {
    _auth.sendPasswordResetEmail(email: email);
  }

  User getCurrentUser() {
    User user = FirebaseAuth.instance.currentUser;
    return user;
  }

  Future<FirestoreUser> getCurrentFirestoreUser() async {
    final FirebaseFirestore databaseReference = FirebaseFirestore.instance;
    final User user = getCurrentUser();

    if (user == null) {
      return null;
    }

    DocumentReference ref = databaseReference.collection("users").doc(user.uid);
    DocumentSnapshot firestoreUser = await ref.get();

    return FirestoreUser.fromSnapshot(firestoreUser);
  }

  Future<bool> userExists(String id) async {
    final databaseReference = FirebaseFirestore.instance;

    DocumentReference ref = databaseReference.collection('users').doc(id);
    DocumentSnapshot user = await ref.get();

    return user.exists;
  }

  Future<void> logIn(BuildContext context, User user) async {
    bool exists = await userExists(user.uid);
    if (exists) {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(home);
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(new_user);
    }
  }
}

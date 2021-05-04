import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_finder/model/firestore_user.dart';

class MyProjectsModel {
  User currentUser;
  bool userIsStudent;
  List<String> topics;
  List<String> topicsSearched;
  List<FirestoreUser> supervisors;
}

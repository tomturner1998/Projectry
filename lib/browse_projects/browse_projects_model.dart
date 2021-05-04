import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/model/project.dart';

class BrowseProjectsModel {
  String searchTerm;
  String supervisorFilterValue;
  DocumentReference projectFilterValue;
  List<Project> projects;
  FirestoreUser currentUser;
}
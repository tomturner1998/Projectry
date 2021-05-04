import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/model/project.dart';
import 'package:project_finder/model/user_with_provisional.dart';
import 'package:project_finder/supervision_overview/supervision_overview.view.dart';

class UserIdWithProjectTitle {
  final UserWithProvisional user;
  final String projectTitle;

  UserIdWithProjectTitle({this.user, this.projectTitle});
}

class SupervisionOverviewPresenter {
  FirebaseFirestore databaseReference;
  SupervisionOverviewView supervisionOverviewView;
  Auth auth;

  SupervisionOverviewPresenter(Auth auth, FirebaseFirestore databaseReference) {
    this.auth = auth;
    this.databaseReference = databaseReference;
  }

  set view(SupervisionOverviewView view) {
    this.supervisionOverviewView = view;
    updateView();
  }

  void updateView() {
    if (supervisionOverviewView == null) {
      return;
    }

    supervisionOverviewView.update();
  }

  void openStudentModal(BuildContext context, FirestoreUser user) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return supervisionOverviewView.buildStudentOverviewModal(user);
        });
  }

  List<UserIdWithProjectTitle> getReleventUsers(
      AsyncSnapshot<QuerySnapshot> snapshot) {
    User currentUser = auth.getCurrentUser();

    List<Project> releventProjects = snapshot.data.docs
        .map((doc) => Project.fromSnapshot(doc))
        .where((project) =>
            project.submitter == currentUser.uid ||
            project.supervisor == currentUser.uid)
        .toList()
        .cast<Project>();

    return releventProjects
        .map((project) {
          if (project.submitter == currentUser.uid) {
            return project.claimedBy
                .map((user) => UserIdWithProjectTitle(
                    user: user, projectTitle: project.title))
                .toList()
                .cast<UserIdWithProjectTitle>();
          } else if (project.supervisor == currentUser.uid) {
            return [
              UserIdWithProjectTitle(
                  user: UserWithProvisional(
                      userId: project.submitter, provisional: false),
                  projectTitle: project.title)
            ];
          }

          return [];
        })
        .expand((element) => element)
        .toList()
        .cast<UserIdWithProjectTitle>();
  }
}

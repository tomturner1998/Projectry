import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/conversation/conversation_presenter.dart';
import 'package:project_finder/conversation/conversation_view.dart';
import 'package:project_finder/messaging_utils/message_models.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/model/project.dart';
import 'package:project_finder/projects_for_approval/projects_for_approval_model.dart';
import 'package:project_finder/projects_for_approval/projects_for_approval_view.dart';

class ProjectsForApprovalPresenter {
  FirebaseFirestore databaseReference;
  Auth auth;
  ProjectsForApprovalModel projectsForApprovalModel;
  ProjectsForApprovalView projectsForApprovalView;

  ProjectsForApprovalPresenter(FirebaseFirestore databaseReference, Auth auth) {
    this.databaseReference = databaseReference;
    this.auth = auth;
    this.projectsForApprovalModel = ProjectsForApprovalModel();
    loadModel();
  }

  void loadModel() async {
    projectsForApprovalModel.currentUser = await auth.getCurrentFirestoreUser();
    updateView();
  }

  set view(ProjectsForApprovalView view) {
    this.projectsForApprovalView = view;
    updateView();
  }

  void updateView() {
    if (projectsForApprovalModel == null || projectsForApprovalView == null) {
      return;
    }

    if (projectsForApprovalModel.currentUser == null) {
      return;
    }

    projectsForApprovalView.update(projectsForApprovalModel.currentUser);
  }

  void approveProject(FirestoreUser currentUser, Project project) {
    databaseReference
        .collection("projects")
        .where("title", isEqualTo: project.title)
        .where("submitter", isEqualTo: project.submitter)
        .get()
        .then((snapshot) {
      if (snapshot.docs.length != 1) {
        return;
      }

      project.approved = true;
      project.supervisor = currentUser.id;

      snapshot.docs[0].reference.set(project.toMap());
    });
  }

  void contactStudent(
      BuildContext context, FirestoreUser _currentUser, Project project) {
    DocumentReference conversationDoc =
        databaseReference.collection("conversations").doc();
    conversationDoc.set(ConversationDataModel(
        participantOne: _currentUser.id,
        participantTwo: project.submitter,
        messages: []).toMap());

    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StreamBuilder(
                stream: databaseReference
                    .collection("users")
                    .doc(project.submitter)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  return Conversation(ConversationPresenter(
                      auth, conversationDoc.id, snapshot.data["full_name"]));
                })));
  }
}

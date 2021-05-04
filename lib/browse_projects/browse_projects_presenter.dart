import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/browse_projects/browse_projects_model.dart';
import 'package:project_finder/browse_projects/browse_projects_view.dart';
import 'package:project_finder/conversation/conversation_presenter.dart';
import 'package:project_finder/conversation/conversation_view.dart';
import 'package:project_finder/messaging_utils/message_models.dart';
import 'package:project_finder/model/project.dart';
import 'package:project_finder/model/user_with_provisional.dart';

class BrowseProjectsPresenter {
  FirebaseFirestore databaseReference;
  Auth auth;
  BrowseProjectsModel browseProjectsModel;
  BrowseProjectsView browseProjectsView;

  BrowseProjectsPresenter(FirebaseFirestore databaseReference, Auth auth) {
    browseProjectsModel = BrowseProjectsModel();
    assignResources(databaseReference, auth);
    loadModel();
  }

  void assignResources(FirebaseFirestore databaseReference, Auth auth) async {
    this.databaseReference = databaseReference;
    this.auth = auth;
    return;
  }

  void loadModel() async {
    browseProjectsModel.currentUser = await auth.getCurrentFirestoreUser();
    await _loadProjects();
    updateView();
    return;
  }

  set view(BrowseProjectsView view) {
    if (view == null) {
      return;
    }

    browseProjectsView = view;

    updateView();
  }

  void updateView() {
    if (browseProjectsModel == null || browseProjectsView == null) {
      return;
    }

    if (browseProjectsModel.projects?.isEmpty ?? true) {
      return;
    }

    browseProjectsView.update(
        browseProjectsModel.searchTerm,
        browseProjectsModel.supervisorFilterValue,
        browseProjectsModel.projectFilterValue,
        browseProjectsModel.projects);
  }

  void searchBarOnSubmit(String value) {
    browseProjectsModel.searchTerm = value;
    updateView();
  }

  Future<void> _loadProjects() async {
    List<Project> projects = [];
    await databaseReference.collection("projects").get().then((snapshot) {
      snapshot.docs.forEach((projectDoc) {
        projects.add(Project.fromSnapshot(projectDoc));
      });
    });

    browseProjectsModel.projects = projects;
    return;
  }

  bool projectIsRelevent(Project project) {
    bool projectWasNotSubmittedByUser =
        project.submitter != browseProjectsModel.currentUser.id;
    bool projectIsNotClaimedByUser = !project.claimedBy
        .map((e) => e.userId)
        .contains(browseProjectsModel.currentUser.id);
    bool projectIsNotFull = project.claims < project.maxClaims;
    bool projectIsToUsersPreference =
        browseProjectsModel.currentUser.preferences.contains(project.field);

    if (browseProjectsModel.searchTerm != null &&
        browseProjectsModel.searchTerm.isNotEmpty) {
      bool projectIsSearchedFor = project.title
          .toLowerCase()
          .contains(browseProjectsModel.searchTerm.toLowerCase());

      return projectWasNotSubmittedByUser &&
          projectIsNotClaimedByUser &&
          projectIsNotFull &&
          projectIsSearchedFor;
    } else if (browseProjectsModel.projectFilterValue != null) {
      bool projectIsFilteredFor =
          project.field == browseProjectsModel.projectFilterValue;

      return projectWasNotSubmittedByUser &&
          projectIsNotClaimedByUser &&
          projectIsNotFull &&
          projectIsFilteredFor;
    } else if (browseProjectsModel.supervisorFilterValue != null) {
      bool projectIsFilteredFor =
          project.supervisor == browseProjectsModel.supervisorFilterValue;

      return projectWasNotSubmittedByUser &&
          projectIsNotClaimedByUser &&
          projectIsNotFull &&
          projectIsFilteredFor;
    }

    return projectWasNotSubmittedByUser &&
        projectIsNotClaimedByUser &&
        projectIsNotFull &&
        projectIsToUsersPreference;
  }

  void claimProject(Project project) {
    databaseReference
        .collection("projects")
        .where("title", isEqualTo: project.title)
        .where("submitter", isEqualTo: project.supervisor)
        .get()
        .then((projectDoc) {
      if (projectDoc.size != 1) {
        return;
      }

      Project project = Project.fromSnapshot(projectDoc.docs[0]);
      project.claimedBy.add(UserWithProvisional(
          userId: browseProjectsModel.currentUser.id, provisional: false));
      project.claims = project.claims + 1;

      projectDoc.docs[0].reference.set(project.toMap());
    });
  }

  void messageSupervisor(BuildContext context, Project project) {
    DocumentReference conversationDoc =
        databaseReference.collection("conversations").doc();
    conversationDoc.set(ConversationDataModel(
        participantOne: browseProjectsModel.currentUser.id,
        participantTwo: project.supervisor,
        messages: []).toMap());

    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StreamBuilder(
                stream: databaseReference
                    .collection("users")
                    .doc(project.supervisor)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  return Conversation(ConversationPresenter(AuthImpl.INSTANCE,
                      conversationDoc.id, snapshot.data["full_name"]));
                })));
  }

  void onTopicFilterChange(dynamic newValue) {
    browseProjectsModel.projectFilterValue = newValue;
    updateView();
  }

  void onSupervisorFilterChange(dynamic newValue) {
    browseProjectsModel.supervisorFilterValue = newValue;
    updateView();
  }

  void onCloseSearchPressed() {
    browseProjectsModel.projectFilterValue = null;
    browseProjectsModel.searchTerm = null;
    browseProjectsModel.supervisorFilterValue = null;
    updateView();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/model/project.dart';
import 'package:project_finder/my_projects/my_projects_model.dart';
import 'package:project_finder/my_projects/my_projects_view.dart';

class MyProjectsPresenter {
  final FirebaseFirestore _firebaseFirestore;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController preferedSupervisorController =
      TextEditingController();
  final TextEditingController maxClaimsController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController addTopicController = TextEditingController();
  final FToast _fToast = FToast();

  Auth _auth;

  BuildContext _context;

  MyProjectsModel _myProjectsModel;
  MyProjectsView _myProjectsView;

  int _selectedTopic;

  String selectedSupervisorId;

  String currentPage = "main";

  MyProjectsPresenter(Auth auth, this._firebaseFirestore) {
    this._auth = auth;
    this._myProjectsModel = MyProjectsModel();
    init();
  }

  void init() async {
    await initModel();
    await _loadTopics();
    await _loadSupervisors();
    _updateView();
  }

  Future<void> initModel() async {
    _myProjectsModel.currentUser = _auth.getCurrentUser();
    _myProjectsModel.userIsStudent =
        await isUserStudent(_myProjectsModel.currentUser.uid);
    return;
  }

  Future<void> _loadTopics() async {
    List<String> _loadedTopics = [];
    await _firebaseFirestore.collection("topics").get().then((snapshot) {
      snapshot.docs.forEach((doc) {
        _loadedTopics.add(doc.get("name"));
      });
    });

    _myProjectsModel.topics = _loadedTopics;
    _myProjectsModel.topicsSearched = _loadedTopics;
    return;
  }

  Future<void> _loadSupervisors() async {
    List<FirestoreUser> _loadedSupervisors = [];
    await _firebaseFirestore.collection("users").get().then((snapshot) {
      snapshot.docs
          .where((element) => (element.get("role") as String)
              .toLowerCase()
              .contains("supervisor"))
          .forEach((doc) {
        _loadedSupervisors.add(FirestoreUser.fromSnapshot(doc));
      });
    });

    _myProjectsModel.supervisors = _loadedSupervisors;

    return;
  }

  Future<bool> isUserStudent(String uid) async {
    bool userIsStudent;
    await _firebaseFirestore.collection("users").doc(uid).get().then((value) {
      userIsStudent =
          (value.data()["role"] as String).toLowerCase().contains("student");
    });

    return userIsStudent;
  }

  void view(MyProjectsView view, BuildContext context) {
    _myProjectsView = view;
    _context = context;
    _fToast.init(context);
    _updateView();
  }

  void _updateView() {
    if (_myProjectsView == null) {
      return;
    }

    if (_myProjectsModel == null ||
        _myProjectsModel.currentUser == null ||
        _myProjectsModel.userIsStudent == null) {
      return;
    }

    _myProjectsView.update(
        _myProjectsModel.currentUser,
        _myProjectsModel.userIsStudent,
        _firebaseFirestore.collection("projects"),
        _myProjectsModel.topics,
        _myProjectsModel.topicsSearched,
        _myProjectsModel.supervisors);
  }

  void handlePageChange(String newPage) {
    currentPage = newPage;
    _updateView();
  }

  void handleCreateProjectClicked(BuildContext context) async {
    _context = context;
    _fToast.init(context);

    bool success = await _createProject();
    if (success) {
      currentPage = "main";
      _updateView();
    }
  }

  void handleSearch() {
    _myProjectsModel.topicsSearched = _myProjectsModel.topics
        .where((String topic) =>
            topic.toLowerCase().contains(searchController.text.toLowerCase()))
        .toList()
        .cast<String>();

    _updateView();
  }

  void handleAddPreferencePressed(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Add A Topic",
                  style: GoogleFonts.lato().copyWith(
                      fontSize: 32,
                      color: currentTheme.isDark
                          ? mediumChampagne
                          : deepSpaceSparkle),
                ),
                SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: addTopicController,
                  decoration: InputDecoration(
                      hintText: "New Topic",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: deepSpaceSparkle),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: deepSpaceSparkle),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: deepSpaceSparkle),
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                ),
                SizedBox(
                  height: 16,
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: RaisedButton.icon(
                      color: indianYellow,
                      onPressed: () async {
                        await _addTopic();
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.add,
                        color: rosewood,
                      ),
                      label: Text(
                        "Add",
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: rosewood),
                      ),
                      padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                )
              ],
            ),
          );
        });
  }

  Future<void> _addTopic() async {
    if (_myProjectsModel.topics.any((element) =>
        element.toLowerCase() == addTopicController.text.toLowerCase())) {
      return;
    }

    String newTopicName = addTopicController.text
        .split(" ")
        .map(
            (String str) => str[0].toUpperCase() + str.substring(1, str.length))
        .join(" ");

    _myProjectsModel.topics.add(newTopicName);
    _selectedTopic = _myProjectsModel.topics.indexOf(newTopicName);

    await _firebaseFirestore.collection("topics").add({"name": newTopicName});

    _updateView();
    return;
  }

  Future<DocumentReference> _getTopicChoice() async {
    if (_selectedTopic == null) {
      return null;
    }

    String selectedTopicName = _myProjectsModel.topics[_selectedTopic];

    DocumentReference topicRef;
    await _firebaseFirestore.collection("topics").get().then((snapshot) {
      topicRef = snapshot.docs
          .singleWhere((doc) => selectedTopicName.contains(doc.get("name")))
          .reference;
    });

    return topicRef;
  }

  bool isTopicSelected(int index) {
    return _selectedTopic == index;
  }

  void handleTopicTapped(bool selected, int index) {
    if (selected) {
      _selectedTopic = null;
    } else {
      _selectedTopic = index;
    }

    _updateView();
  }

  Future<bool> _createProject() async {
    if (titleController.text.isEmpty) {
      _showToast("You must enter a project title");
      return false;
    }

    bool projectAlreadyExists =
        await _projectWithTitleAndSubmitterAlreadyExists(
            titleController.text, _myProjectsModel.currentUser.uid);
    if (projectAlreadyExists) {
      _showToast("You already have a project with that title");
      return false;
    }

    if (descriptionController.text.isEmpty) {
      _showToast("You must enter a description");
      return false;
    }

    DocumentReference field = await _getTopicChoice();
    if (field == null) {
      _showToast("You must choose a field");
      return false;
    }

    bool supervisorWithSpeciality = await _supervisorExistsWithField(field);
    if (_myProjectsModel.userIsStudent &&
        !supervisorWithSpeciality &&
        selectedSupervisorId == null) {
      _showToast("Please pick a supervisor");
      return false;
    }

    if (!_myProjectsModel.userIsStudent && maxClaimsController.text.isEmpty) {
      _showToast("Please enter the maximum claims");
      return false;
    }

    final Project project = Project(
        title: titleController.text,
        briefDescription: descriptionController.text,
        field: field,
        submitter: _myProjectsModel.currentUser.uid,
        supervisor: _myProjectsModel.userIsStudent
            ? ""
            : _myProjectsModel.currentUser.uid,
        preferredSupervisor:
            _myProjectsModel.userIsStudent && selectedSupervisorId != null
                ? selectedSupervisorId
                : "",
        claimedBy: [],
        approved: !_myProjectsModel.userIsStudent,
        maxClaims: _myProjectsModel.userIsStudent
            ? 1
            : int.parse(maxClaimsController.text),
        claims: _myProjectsModel.userIsStudent ? 1 : 0);

    _firebaseFirestore.collection("projects").add(project.toMap());

    titleController.clear();
    descriptionController.clear();
    maxClaimsController.clear();
    _selectedTopic = null;

    _updateView();

    return true;
  }

  Future<bool> _projectWithTitleAndSubmitterAlreadyExists(
      String title, String submitter) {
    return _firebaseFirestore
        .collection("projects")
        .where("title", isEqualTo: title)
        .where("submitter", isEqualTo: submitter)
        .get()
        .then((value) => value.docs.isNotEmpty);
  }

  Future<bool> _supervisorExistsWithField(DocumentReference field) {
    return _firebaseFirestore
        .collection("users")
        .where("role", isEqualTo: "Role.Supervisor")
        .where("preferences", arrayContains: field)
        .get()
        .then((value) => value.docs.isNotEmpty);
  }

  void deleteProject(Project project) {
    _firebaseFirestore.collection("projects").get().then((snapshot) => snapshot
        .docs
        .where((element) =>
            element["title"] == project.title &&
            element["submitter"] == _myProjectsModel.currentUser.uid)
        .first
        .reference
        .delete());
  }

  DocumentReference getSupervisorReference(String uid) {
    return _firebaseFirestore.collection("users").doc(uid);
  }

  void unclaimProject(Project project) {
    project.claimedBy
        .removeWhere((user) => user.userId == _myProjectsModel.currentUser.uid);

    _firebaseFirestore.collection("projects").get().then((snapshot) {
      snapshot.docs
          .where((documentSnapshot) {
            Project foundProject = Project.fromSnapshot(documentSnapshot);
            return foundProject.title == project.title &&
                foundProject.submitter == project.submitter;
          })
          .first
          .reference
          .set(project.toMap());
    });
  }

  void _showToast(String text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: currentTheme.isDark ? mediumChampagne : indianYellow,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Icon(
            Icons.block,
            color: rosewood,
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(text,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato().copyWith(fontSize: 18, color: rosewood))
        ],
      ),
    );

    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
    );
  }
}

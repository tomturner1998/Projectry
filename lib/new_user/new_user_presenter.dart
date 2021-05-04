import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/model/roles.dart';
import 'package:project_finder/navigation/paths.dart';
import 'package:project_finder/new_user/new_user_model.dart';
import 'package:project_finder/new_user/new_user_view.dart';

class NewUserPresenter {
  FirebaseFirestore _firebaseFirestore;
  Auth _auth;

  NewUserView _newUserView;
  NewUserModel _newUserModel;

  List<int> _selectedTopics = [];
  List<DocumentReference> _selectedTopicRefs = [];

  String currentPage = "name";

  bool roleSelectorValue = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController addTopicController = TextEditingController();

  NewUserPresenter(FirebaseFirestore firebaseFirestore, Auth auth) {
    this._firebaseFirestore = firebaseFirestore;
    this._auth = auth;
    this._newUserModel = NewUserModel();
    load();
  }

  void load() async {
    await _loadTopics();
    _updateView();
  }

  Future<void> _loadTopics() async {
    List<String> _loadedTopics = [];
    await _firebaseFirestore.collection("topics").get().then((snapshot) {
      snapshot.docs.forEach((doc) {
        _loadedTopics.add(doc.get("name"));
      });
    });

    _newUserModel.topics = _loadedTopics;
    _newUserModel.topicsSearched = _loadedTopics;
    return;
  }

  set view(NewUserView view) {
    _newUserView = view;
    _updateView();
  }

  void _updateView() {
    if (_newUserView == null) {
      return;
    }

    if (_newUserModel == null ||
        _newUserModel.topics == null ||
        _newUserModel.topicsSearched == null) {
      _newUserView.update([], []);
      return;
    }

    _newUserView.update(_newUserModel.topics, _newUserModel.topicsSearched);
  }

  void handleNameNextPressed() {
    currentPage = "role";
    _updateView();
  }

  void handleRoleNextPressed() {
    currentPage = "preferences";
    _updateView();
  }

  void handleBackPressed(String previousPage) {
    currentPage = previousPage;
    _updateView();
  }

  void handleRoleSelectorChanged(bool value) {
    roleSelectorValue = value;
    _updateView();
  }

  bool isTopicSelected(int index) {
    return _selectedTopics.contains(index);
  }

  void handleTopicTapped(bool selected, int index) {
    if (selected) {
      _selectedTopics.remove(index);
    } else {
      _selectedTopics.add(index);
    }
    _updateView();
  }

  void confirm(BuildContext context) async {
    await _getTopicChoices();

    User currentUser = _auth.getCurrentUser();

    _firebaseFirestore.collection('users').doc(currentUser.uid).set({
      "email": currentUser.email,
      "full_name": nameController.text,
      "role": roleSelectorValue
          ? Role.Supervisor.toString()
          : Role.Student.toString(),
      "preferences": _selectedTopicRefs
    });
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(home);
  }

  Future<void> _getTopicChoices() async {
    List<String> selectedTopicNames =
        _selectedTopics.map((index) => _newUserModel.topics[index]).toList();

    List<DocumentReference> topicRefs = [];
    await _firebaseFirestore.collection("topics").get().then((snapshot) {
      topicRefs.addAll(snapshot.docs
          .where((doc) => selectedTopicNames.contains(doc.get("name")))
          .map((querySnapshot) => querySnapshot.reference));
    });

    _selectedTopicRefs = topicRefs;

    return;
  }

  void handleSearch() {
    _newUserModel.topicsSearched = _newUserModel.topics
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
                      onPressed: () {
                        _addTopic();
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

  void _addTopic() async {
    if (_newUserModel.topics.any((element) =>
        element.toLowerCase() == addTopicController.text.toLowerCase())) {
      return;
    }

    String newTopicName = addTopicController.text
        .split(" ")
        .map(
            (String str) => str[0].toUpperCase() + str.substring(1, str.length))
        .join(" ");

    _newUserModel.topics.add(newTopicName);
    _selectedTopics.add(_newUserModel.topics.indexOf(newTopicName));

    await _firebaseFirestore.collection("topics").add({"name": newTopicName});

    _updateView();
  }
}

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/home/home_model.dart';
import 'package:project_finder/home/home_view.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/navigation/paths.dart';

class HomePresenter {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Auth _auth;
  HomeModel _homeModel;
  HomeView _homeView;

  HomePresenter(Auth auth) {
    this._auth = auth;
    this._homeModel = HomeModel();
    loadModel();
  }

  // Constructor to aid testing
  HomePresenter.test(FirestoreUser firestoreUser, Auth auth) {
    this._auth = auth;
    this._homeModel = HomeModel();
    this._homeModel.firestoreUser = firestoreUser;
  }

  Future<void> view(HomeView view) async {
    this._homeView = view;
    _updateView();
    return;
  }

  void loadModel() async {
    _homeModel.firestoreUser = await _auth.getCurrentFirestoreUser();
    _updateView();
  }

  void _updateView() {
    if (_homeView == null) {
      return;
    }

    if (_homeModel == null || _homeModel.firestoreUser == null) {
      return;
    }

    _homeView.update(_homeModel.firestoreUser);
  }

  void handleSignOutPressed(BuildContext context) {
    _auth.signOut(_googleSignIn);
    Navigator.pop(context);
    Navigator.pushNamed(context, login);
  }

  void handleSettingsPressed(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            padding: EdgeInsets.all(32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Light Theme"),
                Switch(
                    key: Key("ThemeSwitch"),
                    value: currentTheme.isDark,
                    onChanged: (val) => currentTheme.switchTheme()),
                Text("Dark Theme")
              ],
            ),
          );
        });
  }
}

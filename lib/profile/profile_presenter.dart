import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/profile/profile_model.dart';
import 'package:project_finder/profile/profile_view.dart';

class ProfilePresenter {
  FirebaseFirestore _firebaseFirestore;
  Auth _auth;
  ProfileModel _profileModel;
  ProfileView _profileView;

  ProfilePresenter(FirebaseFirestore firebaseFirestore, Auth auth) {
    this._firebaseFirestore = firebaseFirestore;
    this._auth = auth;
    this._profileModel = ProfileModel();
    _loadModel();
  }

  set view(ProfileView profileView) {
    _profileView = profileView;
    _updateView();
  }

  void _loadModel() async {
    _profileModel.firestoreUser = await _auth.getCurrentFirestoreUser();
    _updateView();
  }

  void _updateView() async {
    if (_profileView == null) {
      return;
    }

    if (_profileModel == null || _profileModel.firestoreUser == null) {
      _profileView.update("", "", Stream.empty(), null, Stream.empty(), []);
      return;
    }

    _profileView.update(
        _profileModel.firestoreUser.fullName,
        _profileModel.firestoreUser.email,
        _streamPreferenceNames(),
        _profileModel.firestoreUser.role,
        _firebaseFirestore.collection("topics").snapshots(),
        _profileModel.firestoreUser.preferences);
  }

  Stream<List<String>> _streamPreferenceNames() async* {
    List<String> preferenceNames = [];
    _profileModel.firestoreUser.preferences.forEach((preferenceRef) {
      preferenceRef.get().then((preferenceDoc) {
        preferenceNames.add(preferenceDoc.data()["name"]);

        // Tell the view to update when the last preference reference is evaluated
        if (_profileModel.firestoreUser.preferences.indexOf(preferenceRef) ==
            _profileModel.firestoreUser.preferences.length - 1) {
          _profileView.emptyUpdate();
        }
      });
    });

    yield preferenceNames;
  }

  void handlePreferenceChange(DocumentReference reference) async {
    if (_profileModel.firestoreUser.preferences.contains(reference)) {
      _profileModel.firestoreUser.preferences.remove(reference);
    } else {
      _profileModel.firestoreUser.preferences.add(reference);
    }

    await _changePreferences();

    _updateView();
  }

  Future<void> _changePreferences() async {
    await _firebaseFirestore
        .collection("users")
        .doc(_profileModel.firestoreUser.id)
        .set(_profileModel.firestoreUser.toMap());

    return;
  }
}

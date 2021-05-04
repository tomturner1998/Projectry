import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/model/roles.dart';
import 'package:project_finder/profile/profile_presenter.dart';

class ProfileView {
  void update(
      String fullName,
      String email,
      Stream<List<String>> preferences,
      Role role,
      Stream<QuerySnapshot> allTopics,
      List<DocumentReference> preferenceReferences) {}

  void emptyUpdate() {}
}

class Profile extends StatefulWidget {
  final ProfilePresenter presenter;

  Profile(this.presenter, {Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> implements ProfileView {
  String _fullName;
  String _email;
  Role _role;
  Stream<QuerySnapshot> _allTopics;
  Stream<List<String>> _preferences;
  List<DocumentReference> _preferenceReferences;

  @override
  void initState() {
    super.initState();
    this.widget.presenter.view = this;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildContent(),
    );
  }

  @override
  void update(
      String fullName,
      String email,
      Stream<List<String>> preferences,
      Role role,
      Stream<QuerySnapshot> allTopics,
      List<DocumentReference> preferenceReferences) {
    setState(() {
      this._fullName = fullName;
      this._email = email;
      this._preferences = preferences;
      this._role = role;
      this._allTopics = allTopics;
      this._preferenceReferences = preferenceReferences;
    });
  }

  @override
  void emptyUpdate() {
    setState(() {});
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text("Profile"),
      backgroundColor: deepSpaceSparkle,
    );
  }

  Widget _buildContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 80),
      child: ListView(
        children: [
          _buildHeader(),
          SizedBox(
            height: 16,
          ),
          _buildContactCard(),
          SizedBox(
            height: 16,
          ),
          _buildRoleCard(),
          SizedBox(
            height: 16,
          ),
          _buildPreferencesCard()
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.person,
            size: 80,
          ),
          SizedBox(
            height: 8,
          ),
          Text(_fullName,
              style: GoogleFonts.lato().copyWith(
                fontSize: 28,
              ))
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 8.0,
      child: Container(
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: Container(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.email_sharp,
              size: 35,
            ),
          ),
          title: Text(
            "E-MAIL",
            style: GoogleFonts.lato().copyWith(
                fontSize: 20,
                color: currentTheme.isDark ? Colors.white38 : Colors.black45),
          ),
          subtitle: Text(
            _email,
            style: GoogleFonts.lato().copyWith(
                fontSize: 18,
                color: currentTheme.isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard() {
    return Card(
      elevation: 8.0,
      child: Container(
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: Container(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.person,
              size: 35,
            ),
          ),
          title: Text(
            "ROLE",
            style: GoogleFonts.lato().copyWith(
              fontSize: 20,
              color: currentTheme.isDark ? Colors.white38 : Colors.black45,
            ),
          ),
          subtitle: Text(
            _role == null ? "" : _role.toString().split(".")[1],
            style: GoogleFonts.lato().copyWith(
                fontSize: 18,
                color: currentTheme.isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return GestureDetector(
      key: Key("ProfilePrefsCards"),
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return _buildChangePreferencesModal();
            });
      },
      child: Card(
        elevation: 8.0,
        child: Container(
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: Container(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.school,
                size: 35,
              ),
            ),
            title: Text(
              "PREFERENCES",
              style: GoogleFonts.lato().copyWith(
                fontSize: 20,
                color: currentTheme.isDark ? Colors.white38 : Colors.black45,
              ),
            ),
            subtitle: StreamBuilder(
                initialData: List.filled(0, ""),
                stream: _preferences,
                builder: (BuildContext context,
                    AsyncSnapshot<List<String>> snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  List<String> preferenceNames = snapshot.data;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: preferenceNames
                        .map((preference) => Text(
                              "•  " + preference,
                              style: GoogleFonts.lato().copyWith(
                                  fontSize: 18,
                                  color: currentTheme.isDark
                                      ? Colors.white
                                      : Colors.black),
                            ))
                        .toList(),
                  );
                }),
            trailing: Icon(Icons.keyboard_arrow_right),
          ),
        ),
      ),
    );
  }

  Widget _buildChangePreferencesModal() {
    return StreamBuilder(
      stream: _allTopics,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        List<Widget> listViewContent = [
          Card(
            color: Colors.transparent,
            elevation: 0.0,
            child: Container(
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                title: Text(
                  "Change Your Preferences:",
                  style: GoogleFonts.lato().copyWith(
                      fontSize: 28,
                      color:
                          currentTheme.isDark ? mediumChampagne : indianYellow),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          )
        ];

        listViewContent.addAll(snapshot.data.docs
            .map((doc) => GestureDetector(
                  onTap: () {
                    widget.presenter.handlePreferenceChange(doc.reference);
                    Navigator.pop(context);
                  },
                  child: Card(
                      elevation: 4.0,
                      child: Container(
                          child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        title: Text(
                          doc["name"],
                          style: GoogleFonts.lato().copyWith(fontSize: 18),
                        ),
                        trailing: _preferenceReferences.contains(doc.reference)
                            ? Icon(Icons.remove)
                            : Icon(Icons.add),
                      ))),
                ))
            .toList());

        return Container(
          padding: EdgeInsets.all(15),
          child: ListView(
            key: Key("ChangePrefsListView"),
            children: listViewContent,
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:project_finder/custom_elements/menu_card.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/home/home_presenter.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/model/roles.dart';
import 'package:project_finder/navigation/paths.dart';

class HomeView {
  void update(FirestoreUser firestoreUser) {}
}

class Home extends StatefulWidget {
  final HomePresenter presenter;

  Home(this.presenter, {Key key}) : super(key: key);

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> implements HomeView {
  FirestoreUser _firestoreUser;

  @override
  void initState() {
    super.initState();
    initView();
  }

  void initView() async {
    await widget.presenter.view(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _firestoreUser == null
          ? CircularProgressIndicator()
          : _buildCardList(_firestoreUser.role == Role.Student),
    );
  }

  @override
  void update(FirestoreUser firestoreUser) {
    setState(() {
      _firestoreUser = firestoreUser;
    });
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text("Projectry"),
      backgroundColor: deepSpaceSparkle,
      leading: IconButton(
        key: Key("SignOutButton"),
        icon: Icon(Icons.logout),
        onPressed: () => widget.presenter.handleSignOutPressed(context),
      ),
      actions: [_buildSettingsButton()],
    );
  }

  Widget _buildSettingsButton() {
    return IconButton(
        key: Key("HomeSettingsButton"),
        icon: Icon(Icons.settings),
        onPressed: () => widget.presenter.handleSettingsPressed(context));
  }

  Widget _buildCardList(bool isStudent) {
    return Center(
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: _buildCards(isStudent),
        ),
      ),
    );
  }

  List<Widget> _buildCards(bool isStudent) {
    List<Widget> cards = [
      MenuCard(
        key: isStudent
            ? Key("BrowseProjectsButton")
            : Key("SupervisionOverviewButton"),
        icon: Icons.search,
        text: isStudent ? 'Browse Projects' : 'Supervision Overview',
        path: isStudent ? browseProjects : supervisionOverview,
      ),
      MenuCard(
        key: Key("MyProjectsPageButton"),
        icon: Icons.lightbulb_outline,
        text: 'My Projects',
        path: myProjects,
        isStudent: isStudent,
      ),
      MenuCard(
        key: Key("MessagesHomeButton"),
        icon: Icons.message,
        text: 'Messages',
        path: messages,
      ),
      MenuCard(
        key: Key("ProfilePageButton"),
        icon: Icons.person,
        text: 'Profile',
        path: profile,
      ),
    ];

    if (!isStudent) {
      cards.add(MenuCard(
          key: Key("ProjectsForApprovalButton"),
          icon: Icons.done,
          text: "Projects for Approval",
          path: projectsForApproval));
    }

    return cards;
  }
}

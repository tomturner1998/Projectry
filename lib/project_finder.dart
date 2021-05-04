import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/browse_projects/browse_projects_presenter.dart';
import 'package:project_finder/browse_projects/browse_projects_view.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/home/home_presenter.dart';
import 'package:project_finder/home/home_view.dart';
import 'package:project_finder/login/login_presenter.dart';
import 'package:project_finder/login/login_view.dart';

import 'package:project_finder/graphics/light_theme.dart';
import 'package:project_finder/graphics/dark_theme.dart';
import 'package:project_finder/messages/message_presenter.dart';
import 'package:project_finder/messages/message_view.dart';
import 'package:project_finder/my_projects/my_projects_presenter.dart';
import 'package:project_finder/my_projects/my_projects_view.dart';
import 'package:project_finder/navigation/paths.dart';
import 'package:project_finder/new_user/new_user_presenter.dart';
import 'package:project_finder/new_user/new_user_view.dart';
import 'package:project_finder/profile/profile_presenter.dart';
import 'package:project_finder/profile/profile_view.dart';
import 'package:project_finder/projects_for_approval/projects_for_approval_presenter.dart';
import 'package:project_finder/projects_for_approval/projects_for_approval_view.dart';
import 'package:project_finder/sign_up/sign_up_presenter.dart';
import 'package:project_finder/sign_up/sign_up_view.dart';
import 'package:project_finder/supervision_overview/supervision_overview.view.dart';
import 'package:project_finder/supervision_overview/supervision_overview_presenter.dart';

class ProjectFinder extends StatefulWidget {
  @override
  _ProjectFinderState createState() => _ProjectFinderState();
}

class _ProjectFinderState extends State<ProjectFinder> {
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    Auth auth = AuthImpl();

    LoginPresenter loginPresenter = LoginPresenter(auth);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: currentTheme.currentTheme(),
      initialRoute: login,
      home: Login(loginPresenter),
      routes: {
        login: (context) => Login(loginPresenter),
        home: (context) => Home(HomePresenter(auth)),
        sign_up: (context) => SignUp(SignUpPresenter(auth)),
        new_user: (context) =>
            NewUser(NewUserPresenter(firebaseFirestore, auth)),
        profile: (context) =>
            Profile(ProfilePresenter(firebaseFirestore, auth)),
        myProjects: (context) => MyProjects(MyProjectsPresenter(auth, firebaseFirestore)),
        messages: (context) =>
            Messages(MessagePresenter(firebaseFirestore, auth)),
        browseProjects: (context) =>
            BrowseProjects(BrowseProjectsPresenter(firebaseFirestore, auth)),
        supervisionOverview: (context) =>
            SupervisionOverview(SupervisionOverviewPresenter(auth, firebaseFirestore)),
        projectsForApproval: (context) => ProjectsForApproval(
            ProjectsForApprovalPresenter(firebaseFirestore, auth))
      },
    );
  }
}

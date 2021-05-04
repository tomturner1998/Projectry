import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/model/project.dart';
import 'package:project_finder/projects_for_approval/projects_for_approval_presenter.dart';

class ProjectsForApprovalView {
  void update(FirestoreUser currentUser) {}
}

class ProjectsForApproval extends StatefulWidget {
  final ProjectsForApprovalPresenter presenter;

  ProjectsForApproval(this.presenter, {Key key}) : super(key: key);

  _ProjectsForApprovalState createState() => _ProjectsForApprovalState();
}

class _ProjectsForApprovalState extends State<ProjectsForApproval>
    implements ProjectsForApprovalView {
  FirestoreUser _currentUser;

  @override
  void initState() {
    super.initState();
    widget.presenter.view = this;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Projects for Approval"),
          backgroundColor: deepSpaceSparkle,
          actions: [
            IconButton(
              key: Key("ProjectsForApprovalHelpButton"),
              icon: Icon(Icons.help_outline),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return _buildHelpModal();
                    });
              },
            )
          ],
        ),
        body: StreamBuilder(
          stream: widget.presenter.databaseReference
              .collection("projects")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            List<Project> releventProjects = snapshot.data.docs
                .map((projectDoc) => Project.fromSnapshot(projectDoc))
                .where((project) =>
                    (!project.approved &&
                        _currentUser.preferences.contains(project.field)) ||
                    (!project.approved &&
                        _currentUser.id == project.preferredSupervisor))
                .toList()
                .cast<Project>();

            List<Widget> content = [
              Text(
                "Projects:",
                style: GoogleFonts.lato().copyWith(
                    fontSize: 42,
                    color: currentTheme.isDark
                        ? mediumChampagne
                        : deepSpaceSparkle),
              )
            ];
            content.addAll(releventProjects.map((project) {
              bool isPreferred = _currentUser.id == project.preferredSupervisor;
              return Card(
                  color: isPreferred
                      ? currentTheme.isDark
                          ? auburn
                          : deepSpaceSparkle
                      : Theme.of(context).cardColor,
                  elevation: 8.0,
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                    decoration: BoxDecoration(),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      onTap: () {
                        showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return _buildProjectModal(
                                  context, project, _currentUser);
                            });
                      },
                      title: Text(
                        project.title,
                        style: GoogleFonts.lato().copyWith(
                            fontSize: 22,
                            color: isPreferred
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyText1.color),
                      ),
                      leading: Container(
                        padding: EdgeInsets.only(right: 12.0),
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: currentTheme.isDark
                                        ? Colors.white24
                                        : Colors.black26))),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: isPreferred
                              ? Colors.white
                              : currentTheme.isDark
                                  ? mediumChampagne
                                  : indianYellow,
                        ),
                      ),
                      subtitle: StreamBuilder(
                          stream: widget.presenter.databaseReference
                              .collection("users")
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            String name = snapshot.data.docs
                                .singleWhere(
                                    (doc) => doc.id == project.submitter)
                                .data()["full_name"];
                            if (name == null) {
                              name = "Name Not Found";
                            }

                            List<Widget> children = [
                              Icon(
                                Icons.linear_scale,
                                color: isPreferred
                                    ? Colors.white
                                    : currentTheme.isDark
                                        ? mediumChampagne
                                        : indianYellow,
                              ),
                              Text(
                                name,
                                style: GoogleFonts.lato().copyWith(
                                    fontSize: 20,
                                    color: isPreferred
                                        ? Colors.white
                                        : Theme.of(context)
                                            .textTheme
                                            .headline1
                                            .color),
                              )
                            ];

                            if (isPreferred) {
                              children.add(Text(
                                "Your are this students preferred Supervisor",
                                style: GoogleFonts.lato().copyWith(
                                    fontSize: 16, color: Colors.white60),
                              ));
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: children,
                            );
                          }),
                      trailing: Icon(
                        Icons.keyboard_arrow_right,
                        color: isPreferred
                            ? Colors.white
                            : currentTheme.isDark
                                ? mediumChampagne
                                : indianYellow,
                      ),
                    ),
                  ));
            }).toList());

            return ListView(
              padding: EdgeInsets.all(10),
              children: content,
            );
          },
        ));
  }

  Widget _buildProjectModal(
      BuildContext context, Project project, FirestoreUser currentUser) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              project.title,
              style: GoogleFonts.lato().copyWith(fontSize: 32),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 24,
            ),
            Row(
              children: [
                Expanded(
                    child: Divider(
                  color: currentTheme.isDark ? Colors.white24 : Colors.black26,
                )),
                SizedBox(
                  width: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: currentTheme.isDark
                              ? Colors.white24
                              : Colors.black26),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      "Overview",
                      style: GoogleFonts.lato().copyWith(
                          color: currentTheme.isDark
                              ? Colors.white54
                              : Colors.black54),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                    child: Divider(
                  color: currentTheme.isDark ? Colors.white24 : Colors.black26,
                ))
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: currentTheme.isDark
                              ? Colors.white54
                              : Colors.black38),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: FutureBuilder(
                        future: project.field.get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }

                          return Row(
                            children: [
                              _getTopicIcon(
                                snapshot.data.data()["name"] != null
                                    ? snapshot.data.data()["name"]
                                    : "",
                                currentTheme.isDark
                                    ? mediumChampagne
                                    : indianYellow,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                snapshot.data.data()["name"] != null
                                    ? snapshot.data.data()["name"]
                                    : "",
                                style: GoogleFonts.lato().copyWith(
                                    fontSize: 18,
                                    color: currentTheme.isDark
                                        ? Colors.white
                                        : Colors.black87),
                              )
                            ],
                          );
                        }),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: currentTheme.isDark
                          ? Colors.white54
                          : Colors.black38),
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Container(
                  constraints: BoxConstraints(maxHeight: 150),
                  child: Scrollbar(
                      radius: Radius.circular(30),
                      child: Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: SingleChildScrollView(
                          child: Text(
                            project.briefDescription,
                            style: GoogleFonts.lato().copyWith(fontSize: 16),
                          ),
                        ),
                      )),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.person,
                  color: currentTheme.isDark ? mediumChampagne : indianYellow,
                ),
                SizedBox(
                  width: 8,
                ),
                StreamBuilder(
                    stream: widget.presenter.databaseReference
                        .collection("users")
                        .doc(project.submitter)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }

                      return Text(
                        snapshot.data.data()["full_name"],
                        style: GoogleFonts.lato().copyWith(fontSize: 16),
                      );
                    }),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      primary:
                          currentTheme.isDark ? mediumChampagne : indianYellow),
                  onPressed: () {
                    widget.presenter
                        .contactStudent(context, currentUser, project);
                  },
                  child: Text(
                    "Contact",
                    style: GoogleFonts.lato().copyWith(fontSize: 18),
                  )),
            ),
            SizedBox(
              height: 32,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary:
                        currentTheme.isDark ? mediumChampagne : indianYellow),
                onPressed: () {
                  widget.presenter.approveProject(currentUser, project);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
                  child: Text("Approve Project",
                      style: GoogleFonts.lato()
                          .copyWith(fontSize: 24, color: rosewood)),
                ))
          ],
        ));
  }

  Widget _getTopicIcon(String topicName, Color color) {
    switch (topicName) {
      case "Machine Learning":
        return Icon(
          Icons.code,
          color: color,
        );
        break;
      case "Network Managment":
        return Icon(Icons.network_cell, color: color);
        break;
      case "Android Application Development":
        return Icon(Icons.android, color: color);
        break;
      default:
        return Icon(Icons.lightbulb, color: color);
        break;
    }
  }

  Widget _buildHelpModal() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Help", style: Theme.of(context).textTheme.headline4),
          SizedBox(
            height: 16,
          ),
          Text(
            "Click a project in the list to view detailed infomation about the project, message the student, or to accept it.",
            style: Theme.of(context).textTheme.headline6,
          )
        ],
      ),
    );
  }

  @override
  void update(FirestoreUser currentUser) {
    setState(() {
      _currentUser = currentUser;
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/model/project.dart';
import 'package:project_finder/my_projects/my_projects_presenter.dart';

class MyProjectsView {
  void update(
      User currentUser,
      bool userIsStudent,
      CollectionReference projects,
      List<String> topicStrings,
      List<String> searchedTopics,
      List<FirestoreUser> supervisors) {}
}

class MyProjects extends StatefulWidget {
  final MyProjectsPresenter presenter;

  MyProjects(this.presenter, {Key key}) : super(key: key);

  _MyProjectsState createState() => _MyProjectsState();
}

class _MyProjectsState extends State<MyProjects> implements MyProjectsView {
  User _currentUser;
  bool _userIsStudent;
  CollectionReference _projects;
  List<String> _topicStrings = [];
  List<String> _topicsSearched = [];
  List<FirestoreUser> _supervisors = [];

  @override
  void initState() {
    super.initState();
    widget.presenter.view(this, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: _userIsStudent == null
          ? CircularProgressIndicator()
          : _buildContent(context),
      floatingActionButton: widget.presenter.currentPage == "main"
          ? _buildFloatingActionButton()
          : null,
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: deepSpaceSparkle,
      title: Text("My Projects"),
    );
  }

  @override
  void update(
      User currentUser,
      bool userIsStudent,
      CollectionReference projects,
      List<String> topicStrings,
      List<String> searchedTopics,
      List<FirestoreUser> supervisors) {
    setState(() {
      _currentUser = currentUser;
      _userIsStudent = userIsStudent;
      _projects = projects;
      _topicStrings = topicStrings;
      _topicsSearched = searchedTopics;
      _supervisors = supervisors;
    });
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.presenter.currentPage) {
      case "main":
        return _buildProjectSections();
        break;
      case "projectTitle":
        return _buildProjectTitleInput();
        break;
      case "projectDescription":
        return _buildProjectDescriptionInput();
        break;
      case "projectField":
        return _buildFieldSelector(context);
        break;
      case "projectSupervisor":
        return _buildProjectSupervisorInput();
        break;
      case "projectMaxClaims":
        return _buildProjectMaxClaimsInput();
        break;
      default:
        return Text("Error Occured, Please Return To Home Page");
    }
  }

  Widget _buildProjectSections() {
    List<Widget> sections = [];
    if (_userIsStudent) {
      sections.add(_buildProjectsSection("Claimed Projects:", false));
    }

    sections.add(_buildProjectsSection("Submitted Projects:", true));

    return Column(
      children: sections,
    );
  }

  Widget _buildProjectsSection(String title, bool ownProjects) {
    return StreamBuilder(
      stream: _projects.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        List<Widget> content =
            _buildSectionContent(title, ownProjects, snapshot);

        return Expanded(
          child: ListView(
            padding: EdgeInsets.all(10),
            children: content,
          ),
        );
      },
    );
  }

  List<Widget> _buildSectionContent(
      String title, bool ownProjects, AsyncSnapshot<QuerySnapshot> snapshot) {
    Widget titleTextWidget = Text(title,
        style: GoogleFonts.lato().copyWith(
            fontSize: 35,
            color: currentTheme.isDark ? mediumChampagne : deepSpaceSparkle));

    List<Widget> content = [titleTextWidget];

    snapshot.data.docs
        .map((projectSnapshot) => Project.fromSnapshot(projectSnapshot))
        .where((project) {
      if (ownProjects) {
        return project.submitter == _currentUser.uid;
      } else {
        bool claimedByUser = false;
        project.claimedBy.forEach((userWithProvisional) {
          if (userWithProvisional.userId == _currentUser.uid) {
            claimedByUser = true;
            return;
          }
        });

        return claimedByUser;
      }
    }).forEach((project) {
      Widget icon = _getTopicIcon(project.field);

      content.add(GestureDetector(
        onTap: () {
          showModalBottomSheet(
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return _buildProjectBottomModal(
                    context, project, ownProjects, icon);
              });
        },
        child: Card(
          elevation: 8.0,
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: BoxDecoration(),
            child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                leading: Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(
                              width: 1.0,
                              color: currentTheme.isDark
                                  ? Colors.white24
                                  : Colors.black26))),
                  child: icon,
                ),
                title: Text(
                  project.title,
                  style:
                      GoogleFonts.lato().copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Container(
                  decoration: BoxDecoration(),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.linear_scale,
                        color: currentTheme.isDark
                            ? mediumChampagne
                            : indianYellow,
                      ),
                      Text(
                        project.briefDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: currentTheme.isDark ? mediumChampagne : indianYellow,
                )),
          ),
        ),
      ));
    });

    return content;
  }

  Widget _getTopicIcon(DocumentReference topicReference) {
    return FutureBuilder(
        future: topicReference.get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          String topicName = snapshot.data["name"];

          switch (topicName) {
            case "Machine Learning":
              return Icon(Icons.code);
              break;
            case "Network Managment":
              return Icon(Icons.network_cell);
              break;
            case "Android Application Development":
              return Icon(Icons.android);
              break;
            default:
              return Icon(Icons.lightbulb);
              break;
          }
        });
  }

  Widget _buildProjectBottomModal(
      BuildContext context, Project project, bool ownProjects, Widget icon) {
    List<Widget> values = [
      Text(
        project.title,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato().copyWith(
            fontSize: 25,
            color: currentTheme.isDark ? mediumChampagne : indianYellow),
      ),
      SizedBox(
        height: 16,
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
                    color:
                        currentTheme.isDark ? Colors.white24 : Colors.black26),
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Text(
                "Overview",
                style: GoogleFonts.lato().copyWith(
                    color:
                        currentTheme.isDark ? Colors.white54 : Colors.black54),
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
                    color:
                        currentTheme.isDark ? Colors.white54 : Colors.black38),
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
                      icon,
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        snapshot.data.data()["name"],
                        style: GoogleFonts.lato().copyWith(
                            fontSize: 18,
                            color: currentTheme.isDark
                                ? Colors.white
                                : Colors.black87),
                      )
                    ],
                  );
                },
              ),
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
                color: currentTheme.isDark ? Colors.white54 : Colors.black38),
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
      )
    ];

    if (_userIsStudent && ownProjects && project.approved) {
      values.add(SizedBox(
        height: 16,
      ));
      values.add(Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.check,
            color: currentTheme.isDark ? mediumChampagne : indianYellow,
          ),
          SizedBox(
            width: 8,
          ),
          StreamBuilder(
              stream: widget.presenter
                  .getSupervisorReference(project.supervisor)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                return Text(
                  snapshot.data["full_name"],
                  style: GoogleFonts.lato().copyWith(fontSize: 16),
                );
              }),
        ],
      ));
    }

    if (!_userIsStudent && ownProjects) {
      values.add(SizedBox(
        height: 16,
      ));
      values.add(Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(
                  color: currentTheme.isDark ? Colors.white54 : Colors.black38),
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.person),
              SizedBox(
                width: 8,
              ),
              Text(
                project.claims.toString(),
                style: GoogleFonts.lato().copyWith(fontSize: 20),
              ),
              Text(" / ", style: GoogleFonts.lato().copyWith(fontSize: 20)),
              Text(project.maxClaims.toString(),
                  style: GoogleFonts.lato().copyWith(fontSize: 20))
            ],
          ),
        ),
      ));
    }

    if (ownProjects) {
      values.addAll([
        SizedBox(
          height: 16,
        ),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            key: Key("MyProjectsDeleteProjectButton"),
            child: Text(
              "Delete Project",
              style: GoogleFonts.lato().copyWith(
                  fontSize: 22,
                  color: currentTheme.isDark ? rosewood : Colors.white),
            ),
            onPressed: () async {
              bool confirm = false;

              await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "Are you sure?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato().copyWith(fontSize: 24),
                      ),
                      content: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.lato().copyWith(fontSize: 22),
                            ),
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                primary: Colors.grey),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          ElevatedButton(
                            key: Key("MyProjectsDeleteProjectButtonConfirm"),
                            onPressed: () {
                              confirm = true;
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Delete Project",
                              style: GoogleFonts.lato().copyWith(
                                  fontSize: 22,
                                  color: currentTheme.isDark
                                      ? rosewood
                                      : Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                primary: currentTheme.isDark
                                    ? mediumChampagne
                                    : deepSpaceSparkle),
                          )
                        ],
                      ),
                    );
                  });

              if (confirm) {
                widget.presenter.deleteProject(project);
              }

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                primary:
                    currentTheme.isDark ? mediumChampagne : deepSpaceSparkle,
                padding: EdgeInsets.fromLTRB(15, 10, 15, 10)),
          ),
        )
      ]);
    } else if (_userIsStudent && !ownProjects) {
      values.addAll([
        SizedBox(
          height: 16,
        ),
        Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              key: Key("MyProjectsDeleteProjectButton"),
              child: Text(
                "Un-Claim Project",
                style: GoogleFonts.lato().copyWith(
                    fontSize: 22,
                    color: currentTheme.isDark ? rosewood : Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  primary:
                      currentTheme.isDark ? mediumChampagne : deepSpaceSparkle,
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10)),
              onPressed: () async {
                bool confirm = false;

                await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          "If You Choose To Un-Claim This Project, Please Update The Supervisor",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato().copyWith(fontSize: 24),
                        ),
                        content: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Cancel",
                                style:
                                    GoogleFonts.lato().copyWith(fontSize: 22),
                              ),
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                  primary: Colors.grey),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            ElevatedButton(
                              key: Key("MyProjectsDeleteProjectButtonConfirm"),
                              onPressed: () {
                                confirm = true;
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Un-Claim Project",
                                style: GoogleFonts.lato().copyWith(
                                    fontSize: 22,
                                    color: currentTheme.isDark
                                        ? rosewood
                                        : Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                  primary: currentTheme.isDark
                                      ? mediumChampagne
                                      : deepSpaceSparkle),
                            )
                          ],
                        ),
                      );
                    });

                if (confirm) {
                  widget.presenter.unclaimProject(project);
                }

                Navigator.pop(context);
              },
            ))
      ]);
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: values,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: FloatingActionButton.extended(
          key: Key("CreateProjectButton"),
          onPressed: () {
            widget.presenter.handlePageChange("projectTitle");
          },
          icon: Icon(
            Icons.add,
            color: rosewood,
          ),
          label: Text("Create Project",
              style:
                  GoogleFonts.lato().copyWith(fontSize: 20, color: rosewood)),
          backgroundColor: currentTheme.isDark ? mediumChampagne : indianYellow,
        ));
  }

  Widget _buildProjectTitleInput() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "What is the Title of Your Project?",
            style:
                GoogleFonts.lato().copyWith(fontSize: 28, color: indianYellow),
          ),
          SizedBox(
            height: 16,
          ),
          TextField(
            key: Key("CreateProjectTitleInput"),
            controller: widget.presenter.titleController,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: currentTheme.isDark
                            ? mediumChampagne
                            : deepSpaceSparkle),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: currentTheme.isDark
                            ? mediumChampagne
                            : deepSpaceSparkle),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                hintText: "Project Title",
                hintStyle: GoogleFonts.lato().copyWith(fontSize: 24)),
          ),
          SizedBox(
            height: 16,
          ),
          _buildButton("Next", () {
            widget.presenter.handlePageChange("projectDescription");
          }, rosewood, currentTheme.isDark ? mediumChampagne : indianYellow)
        ],
      ),
    );
  }

  Widget _buildProjectDescriptionInput() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Please Describe Your Project",
            style:
                GoogleFonts.lato().copyWith(fontSize: 28, color: indianYellow),
          ),
          SizedBox(
            height: 16,
          ),
          TextField(
            key: Key("CreateProjectDescriptionInput"),
            controller: widget.presenter.descriptionController,
            minLines: 5,
            maxLines: 20,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: currentTheme.isDark
                            ? mediumChampagne
                            : deepSpaceSparkle),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: currentTheme.isDark
                            ? mediumChampagne
                            : deepSpaceSparkle),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                hintText: "Project Description",
                hintStyle: GoogleFonts.lato().copyWith(fontSize: 24)),
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildButton("Back", () {
                widget.presenter.handlePageChange("projectTitle");
              }, Colors.white, deepSpaceSparkle),
              SizedBox(
                width: 16,
              ),
              _buildButton("Next", () {
                widget.presenter.handlePageChange("projectField");
              }, rosewood, currentTheme.isDark ? mediumChampagne : indianYellow)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSupervisorInput() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Who is Your Prefered Supervisor for this Project? (Optional)",
            style:
                GoogleFonts.lato().copyWith(fontSize: 28, color: indianYellow),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: DropdownButtonHideUnderline(
                child: DropdownButton(
                    hint: Text("Select a Supervisor",
                        style: GoogleFonts.lato().copyWith(fontSize: 24)),
                    value: widget.presenter.selectedSupervisorId,
                    onChanged: (newValue) {
                      widget.presenter.selectedSupervisorId = newValue;
                      setState(() {});
                    },
                    items: _supervisors
                        .map((e) => DropdownMenuItem(
                              child: Text(
                                e.fullName,
                                style:
                                    GoogleFonts.lato().copyWith(fontSize: 20),
                              ),
                              value: e.id,
                            ))
                        .toList())),
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildButton("Back", () {
                widget.presenter.handlePageChange("projectField");
              }, Colors.white, deepSpaceSparkle),
              SizedBox(
                width: 16,
              ),
              _buildButton(
                  "Create Project",
                  () => widget.presenter.handleCreateProjectClicked(context),
                  rosewood,
                  currentTheme.isDark ? mediumChampagne : indianYellow)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectMaxClaimsInput() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "How Many Students Can Claim This Project?",
            style:
                GoogleFonts.lato().copyWith(fontSize: 28, color: indianYellow),
          ),
          SizedBox(
            height: 16,
          ),
          TextField(
            key: Key("MyProjectsMaxClaimsInput"),
            controller: widget.presenter.maxClaimsController,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: currentTheme.isDark
                            ? mediumChampagne
                            : deepSpaceSparkle),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: currentTheme.isDark
                            ? mediumChampagne
                            : deepSpaceSparkle),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                hintText: "Max Claims",
                hintStyle: GoogleFonts.lato().copyWith(fontSize: 24)),
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildButton("Back", () {
                widget.presenter.handlePageChange("projectField");
              }, Colors.white, deepSpaceSparkle),
              SizedBox(
                width: 16,
              ),
              _buildButton(
                  "Create Project",
                  () => widget.presenter.handleCreateProjectClicked(context),
                  rosewood,
                  currentTheme.isDark ? mediumChampagne : indianYellow)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Function nextFunction, Color textColour,
      Color primaryColour) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        child: Text(
          text,
          style: GoogleFonts.lato().copyWith(fontSize: 24, color: textColour),
        ),
        onPressed: nextFunction,
        style: ElevatedButton.styleFrom(
            primary: primaryColour,
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10)),
      ),
    );
  }

  Widget _buildFieldSelector(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Wrap(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Please Select The Topic Of Your Project:",
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 8,
                ),
                _buildSearchBox(context),
                SizedBox(
                  height: 16,
                ),
                _buildTopicGrid(context),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildButton("Back", () {
                      widget.presenter.handlePageChange("projectDescription");
                    }, Colors.white, deepSpaceSparkle),
                    SizedBox(
                      width: 16,
                    ),
                    _buildButton("Next", () {
                      widget.presenter.handlePageChange(_userIsStudent
                          ? "projectSupervisor"
                          : "projectMaxClaims");
                    }, rosewood,
                        currentTheme.isDark ? mediumChampagne : indianYellow),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.presenter.searchController,
            onChanged: (value) => widget.presenter.handleSearch(),
            cursorColor: indianYellow,
            decoration: InputDecoration(
                hintText: "Search Topics...",
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
        ),
        IconButton(
            icon: Icon(
              Icons.add,
              size: 30,
            ),
            onPressed: () =>
                widget.presenter.handleAddPreferencePressed(context))
      ],
    );
  }

  Widget _buildTopicGrid(BuildContext context) {
    return SizedBox(
      key: Key("CreateProjectTopicGrid"),
      height: MediaQuery.of(context).size.height * 0.5,
      child: ClipRRect(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: _topicsSearched.length,
            itemBuilder: (BuildContext context, int index) {
              int mainIndex = _topicStrings.indexOf(_topicsSearched[index]);

              bool selected = widget.presenter.isTopicSelected(mainIndex);

              return InkWell(
                onTap: () =>
                    widget.presenter.handleTopicTapped(selected, mainIndex),
                child: Card(
                    margin: EdgeInsets.all(6),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb,
                            size: 40,
                            color: selected
                                ? auburn
                                : currentTheme.isDark
                                    ? Colors.white
                                    : deepSpaceSparkle,
                          ),
                          Text(
                            _topicsSearched[index],
                            style: Theme.of(context).textTheme.headline6,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                          )
                        ]),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        side: BorderSide(
                            width: selected ? 4 : 0,
                            color: selected ? auburn : Colors.transparent))),
              );
            },
          )),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/browse_projects/browse_projects_presenter.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/model/project.dart';
import 'package:project_finder/model/roles.dart';
import 'package:project_finder/navigation/paths.dart';

class BrowseProjectsView {
  void update(String searchTerm, String supervisorFilterValue,
      DocumentReference topicFilterValue, List<Project> projects) {}
}

class BrowseProjects extends StatefulWidget {
  final BrowseProjectsPresenter presenter;

  BrowseProjects(this.presenter, {Key key}) : super(key: key);

  _BrowseProjectsState createState() => _BrowseProjectsState();
}

class _BrowseProjectsState extends State<BrowseProjects>
    implements BrowseProjectsView {
  final FirebaseFirestore databaseReference = FirebaseFirestore.instance;

  SearchBar searchBar;

  String _searchTerm;
  String _supervisorFilterValue;

  DocumentReference _topicFilterValue;

  List<Project> _projects;

  @override
  void initState() {
    super.initState();

    widget.presenter.view = this;

    searchBar = SearchBar(
        inBar: false,
        buildDefaultAppBar: _buildAppBar,
        setState: setState,
        onCleared: widget.presenter.onCloseSearchPressed,
        onClosed: widget.presenter.onCloseSearchPressed,
        onChanged: widget.presenter.searchBarOnSubmit,
        onSubmitted: widget.presenter.searchBarOnSubmit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: searchBar.build(context),
      body: _getContent(),
    );
  }

  @override
  void update(String searchTerm, String supervisorFilterValue,
      DocumentReference topicFilterValue, List<Project> projects) {
    setState(() {
      _searchTerm = searchTerm;
      _supervisorFilterValue = supervisorFilterValue;
      _topicFilterValue = topicFilterValue;
      _projects = projects;
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    List<Widget> actions = [
      IconButton(
        key: Key("BrowseProjectsFiltersButton"),
        icon: Icon(Icons.filter_list),
        onPressed: () {
          showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                return _buildFilterModal();
              });
        },
      ),
      Container(
        key: Key("BrowseProjectsSearchButton"),
        child: searchBar.getSearchAction(context),
      )
    ];
    if (_searchTerm != null ||
        _topicFilterValue != null ||
        _supervisorFilterValue != null) {
      actions.add(IconButton(
        icon: Icon(Icons.close),
        onPressed: widget.presenter.onCloseSearchPressed,
      ));
    }

    return AppBar(
      title: Text("Browse Projects"),
      backgroundColor: deepSpaceSparkle,
      actions: actions,
    );
  }

  Widget _buildFilterModal() {
    return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Filter Options",
              style: GoogleFonts.lato().copyWith(fontSize: 32),
            ),
            StreamBuilder(
              stream: databaseReference.collection("topics").snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                List<DropdownMenuItem> items = snapshot.data.docs
                    .map((doc) => DropdownMenuItem(
                          value: doc.reference,
                          child: Text(doc["name"]),
                        ))
                    .toList();

                return DropdownButtonHideUnderline(
                    key: Key("TopicFilterDropdown"),
                    child: DropdownButton(
                      onChanged: (newValue) {
                        widget.presenter.onTopicFilterChange(newValue);
                        Navigator.pop(context);
                      },
                      value: _topicFilterValue,
                      items: items,
                      hint: Text(
                        "Topic",
                        style: GoogleFonts.lato().copyWith(fontSize: 24),
                      ),
                    ));
              },
            ),
            StreamBuilder(
              stream: databaseReference.collection("users").snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                List<DropdownMenuItem> supervisors = snapshot.data.docs
                    .map((userDoc) => FirestoreUser.fromSnapshot(userDoc))
                    .where((user) => user.role == Role.Supervisor)
                    .map((user) => DropdownMenuItem(
                          value: user.id,
                          child: Text(user.fullName),
                        ))
                    .toList();

                return DropdownButtonHideUnderline(
                    child: DropdownButton(
                  onChanged: (newValue) {
                    widget.presenter.onSupervisorFilterChange(newValue);
                    Navigator.pop(context);
                  },
                  value: _supervisorFilterValue,
                  items: supervisors,
                  hint: Text("Supervisor",
                      style: GoogleFonts.lato().copyWith(fontSize: 24)),
                ));
              },
            )
          ],
        ));
  }

  Widget _getContent() {
    return _buildProjectsList();
  }

  Widget _buildProjectsList() {
    List projects = _getProjects();

    if (projects.isEmpty) {
      return Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.priority_high,
              size: 100,
            ),
            Text(
                "No Projects Found Which Match Your Preferences, Please Try To Adjust The Filters",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato().copyWith(fontSize: 32))
          ],
        ),
      );
    }

    return ListView(
      children: projects,
    );
  }

  List<Widget> _getProjects() {
    List<Widget> projects = _projects == null
        ? []
        : _projects
            .where((project) => widget.presenter.projectIsRelevent(project))
            .map((project) => _buildProjectTile(project))
            .toList();

    return projects;
  }

  Widget _buildProjectTile(Project project) {
    Widget icon = _getTopicIcon(project.field);
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) {
              return _buildProjectModal(project, icon);
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
                style: GoogleFonts.lato().copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Container(
                child: Wrap(
                  children: [
                    Icon(
                      Icons.linear_scale,
                      color:
                          currentTheme.isDark ? mediumChampagne : indianYellow,
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
    );
  }

  Widget _buildProjectModal(Project project, Widget icon) {
    return Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 2.5,
              child: icon,
            ),
            SizedBox(
              height: 24,
            ),
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

                        return Text(
                          snapshot.data["name"],
                          style: GoogleFonts.lato().copyWith(
                              fontSize: 18,
                              color: currentTheme.isDark
                                  ? Colors.white
                                  : Colors.black87),
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
                    stream: databaseReference
                        .collection("users")
                        .doc(project.supervisor)
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
                    widget.presenter.messageSupervisor(context, project);
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
                  widget.presenter.claimProject(project);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushNamed(context, myProjects);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
                  child: Text("Claim Project",
                      style: GoogleFonts.lato()
                          .copyWith(fontSize: 24, color: rosewood)),
                ))
          ],
        ));
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
}

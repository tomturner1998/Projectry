import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/model/firestore_user.dart';
import 'package:project_finder/supervision_overview/supervision_overview_presenter.dart';

class SupervisionOverviewView {
  void update() {}
  Widget buildStudentOverviewModal(FirestoreUser user) {
    return null;
  }
}

class SupervisionOverview extends StatefulWidget {
  final SupervisionOverviewPresenter presenter;

  SupervisionOverview(this.presenter, {Key key}) : super(key: key);

  _SupervisionOverviewState createState() => _SupervisionOverviewState();
}

class _SupervisionOverviewState extends State<SupervisionOverview>
    implements SupervisionOverviewView {
  @override
  void initState() {
    super.initState();
    widget.presenter.view = this;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Supervision Overview"),
        backgroundColor: deepSpaceSparkle,
        actions: [
          IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return _buildHelpModal();
                    });
              })
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Students:",
              style: GoogleFonts.lato().copyWith(
                  fontSize: 42,
                  color:
                      currentTheme.isDark ? mediumChampagne : deepSpaceSparkle),
            ),
            StreamBuilder(
              stream: widget.presenter.databaseReference
                  .collection("projects")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                List<UserIdWithProjectTitle> releventUsers =
                    widget.presenter.getReleventUsers(snapshot);

                return StreamBuilder(
                    stream: widget.presenter.databaseReference
                        .collection("users")
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }

                      List<FirestoreUser> users = snapshot.data.docs
                          .where((doc) => releventUsers
                              .map((user) => user.user.userId)
                              .toList()
                              .contains(doc.id))
                          .map((doc) => FirestoreUser.fromSnapshot(doc))
                          .toList()
                          .cast<FirestoreUser>();

                      return Expanded(
                        child: ListView(
                          children: users.map((user) {
                            List<Widget> titles = [
                              Icon(
                                Icons.linear_scale,
                                color: currentTheme.isDark
                                    ? mediumChampagne
                                    : indianYellow,
                              )
                            ];
                            titles.addAll(releventUsers
                                .where((u) => u.user.userId == user.id)
                                .map((u) => Text(
                                      "• " + u.projectTitle,
                                      style: GoogleFonts.lato()
                                          .copyWith(fontSize: 18),
                                    ))
                                .toList());

                            return GestureDetector(
                              onTap: () {
                                widget.presenter
                                    .openStudentModal(context, user);
                              },
                              child: Card(
                                elevation: 8.0,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 6.0),
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
                                    leading: Container(
                                      padding: EdgeInsets.only(right: 12.0),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              right: BorderSide(
                                                  width: 1.0,
                                                  color: currentTheme.isDark
                                                      ? Colors.white24
                                                      : Colors.black26))),
                                      child: Icon(Icons.person, size: 50),
                                    ),
                                    title: Text(
                                      user.fullName,
                                      style: GoogleFonts.lato()
                                          .copyWith(fontSize: 22),
                                    ),
                                    subtitle: Container(
                                      decoration: BoxDecoration(),
                                      clipBehavior: Clip.hardEdge,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: titles,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.keyboard_arrow_right,
                                      color: currentTheme.isDark
                                          ? mediumChampagne
                                          : indianYellow,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    });
              },
            )
          ],
        ));
  }

  Widget buildStudentOverviewModal(FirestoreUser user) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          color: Theme.of(context).canvasColor),
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            user.fullName,
            style: GoogleFonts.lato().copyWith(fontSize: 32),
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
                  child: Text(
                    user.role.toString().split(".")[1],
                    style: GoogleFonts.lato().copyWith(
                        fontSize: 18,
                        color: currentTheme.isDark
                            ? Colors.white
                            : Colors.black87),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Text(user.email, style: GoogleFonts.lato().copyWith(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildHelpModal() {
    return Column(
      children: [
        Text(
            "On this page you can see the students which you are assigned to supervise")
      ],
    );
  }

  @override
  void update() {
    setState(() {});
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/new_user/new_user_presenter.dart';

class NewUserView {
  void update(List<String> topics, List<String> topicsSearched) {}
}

class NewUser extends StatefulWidget {
  final NewUserPresenter presenter;

  NewUser(this.presenter, {Key key}) : super(key: key);

  _NewUserState createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> implements NewUserView {
  List<String> _topics = [];
  List<String> _topicsSearched = [];

  @override
  void initState() {
    super.initState();
    widget.presenter.view = this;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: false, appBar: _buildAppBar(), body: _buildContent());
  }

  @override
  void update(List<String> topics, List<String> topicsSearched) {
    setState(() {
      _topics = topics;
      _topicsSearched = topicsSearched;
    });
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: deepSpaceSparkle,
      title: Text("New User"),
    );
  }

  Widget _buildContent() {
    switch (widget.presenter.currentPage) {
      case "name":
        return _buildNameSelector();
        break;
      case "role":
        return _buildRoleSelector(context);
        break;
      case "preferences":
        return _buildPreferencesSelector(context);
        break;
      default:
        return Text("Error Occured, Please Return to Login Screen");
    }
  }

  Widget _buildNameSelector() {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Please Enter Your Name:",
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.bold, fontSize: 24),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 16,
          ),
          TextField(
            key: Key("NewUserNameField"),
            controller: widget.presenter.nameController,
            decoration: InputDecoration(
                hintText: "Full Name",
                hintStyle: GoogleFonts.lato().copyWith(fontSize: 22),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
          ),
          SizedBox(
            height: 16,
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: RaisedButton.icon(
              key: Key("NewUserNameNextButton"),
              label: Text(
                "Next",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: rosewood),
              ),
              icon: Icon(Icons.arrow_back, color: rosewood),
              padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
              onPressed: () => widget.presenter.handleNameNextPressed(),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              color: indianYellow,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRoleSelector(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Please Selector Your Role:",
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(fontWeight: FontWeight.bold, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Student",
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(
              width: 16,
            ),
            Transform.scale(
                scale: 1.2,
                child: Switch(
                    activeColor: indianYellow,
                    inactiveTrackColor: rosewood,
                    value: widget.presenter.roleSelectorValue,
                    onChanged: (newValue) =>
                        widget.presenter.handleRoleSelectorChanged(newValue))),
            SizedBox(
              width: 16,
            ),
            Text("Supervisor", style: Theme.of(context).textTheme.headline6)
          ],
        ),
        SizedBox(
          height: 16,
        ),
        _buildButtons(
            context, "Next", widget.presenter.handleRoleNextPressed, "name")
      ],
    );
  }

  Widget _buildButtons(BuildContext context, String nextButtonText,
      Function nextFunction, String previousPage) {
    return Wrap(
      children: [
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            OutlineButton.icon(
              onPressed: () => widget.presenter.handleBackPressed(previousPage),
              label: Text(
                "Back",
                style: Theme.of(context).textTheme.headline6,
              ),
              icon: Icon(Icons.arrow_back, color: indianYellow),
              padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: RaisedButton.icon(
                  color: indianYellow,
                  onPressed: () {
                    if (nextButtonText.contains("Confirm")) {
                      nextFunction(context);
                      return;
                    }
                    nextFunction();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: rosewood,
                  ),
                  label: Text(
                    nextButtonText,
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
        )
      ],
    );
  }

  Widget _buildPreferencesSelector(BuildContext context) {
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
                  "Please Select Your Topic Specialities / Preferences:",
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
                  height: 8,
                ),
                _buildButtons(context, "Confirm",
                    widget.presenter.confirm, "role"),
                SizedBox(
                  height: 8,
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
      height: MediaQuery.of(context).size.height * 0.45,
      child: ClipRRect(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: _topicsSearched.length,
            itemBuilder: (BuildContext context, int index) {
              int mainIndex = _topics.indexOf(_topicsSearched[index]);

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

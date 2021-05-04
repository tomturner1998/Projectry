import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/messages/message_presenter.dart';
import 'package:project_finder/messaging_utils/message_models.dart';

class MessageView {
  void update(User currentUser) {}
}

class Messages extends StatefulWidget {
  final MessagePresenter presenter;

  Messages(this.presenter, {Key key}) : super(key: key);

  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> implements MessageView {
  final FirebaseFirestore databaseReference = FirebaseFirestore.instance;

  User _currentUser;

  @override
  void initState() {
    super.initState();
    widget.presenter.view = this;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: databaseReference.collection('conversations').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return Text('These are not the messages you are looking for');

        if (snapshot.connectionState == ConnectionState.waiting)
          return CircularProgressIndicator();

        return Scaffold(
          appBar: AppBar(
            title: Text('Messages'),
            backgroundColor: deepSpaceSparkle,
          ),
          floatingActionButton: Directionality(
            textDirection: TextDirection.rtl,
            child: FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                    context: context, builder: (context) => showListOfUsers());
              },
              icon: Icon(
                Icons.add,
                color: rosewood,
              ),
              label: Text(
                "New Message",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: rosewood),
              ),
              backgroundColor:
                  currentTheme.isDark ? mediumChampagne : indianYellow,
            ),
          ),
          body: Container(
            padding: EdgeInsets.only(top: 10),
            child: ListView(
              children: getMessages(context, snapshot),
            ),
          ),
        );
      },
    );
  }

  getMessages(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs.where((doc) {
      final conversation = ConversationDataModel.fromQuerySnapshot(doc);

      return (conversation.participantOne == _currentUser.uid ||
              conversation.participantTwo == _currentUser.uid) &&
          conversation.messages.length != 0;
    }).map((doc) {
      final conversation = ConversationDataModel.fromQuerySnapshot(doc);

      final previewAndTime =
          widget.presenter.getPreviewMessage(conversation.messages);

      if (previewAndTime.length == 0) {
        return ListTile();
      }

      String receiverId = conversation.participantOne == _currentUser.uid
          ? conversation.participantTwo
          : conversation.participantOne;

      return StreamBuilder(
        stream: databaseReference.collection("users").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Text('These are not the messages you are looking for');

          if (snapshot.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();

          String receiver;
          receiver = snapshot.data.docs
              .singleWhere((element) => element.id == receiverId)
              .data()["full_name"];

          if (receiver == null) {
            receiver = "Name Not Found";
          }

          return ListTile(
            title: Text(
              receiver,
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: indianYellow),
            ),
            leading: Icon(Icons.person, size: 50),
            subtitle: Text(previewAndTime[0],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato().copyWith(fontSize: 16)),
            trailing: Text(
              previewAndTime[1],
              style:
                  Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16),
            ),
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      buildMessageContextPopup(context, doc.id));
            },
            onTap: () =>
                widget.presenter.handleMessagePressed(context, doc, receiver),
          );
        },
      );
    }).toList();
  }

  buildMessageContextPopup(BuildContext context, String conversationId) {
    return AlertDialog(
      title: Text("Options", style: GoogleFonts.lato().copyWith(fontSize: 24)),
      content: ElevatedButton(
        child: Text(
          "Delete Message",
          style: GoogleFonts.lato().copyWith(fontSize: 24),
        ),
        onPressed: () =>
            widget.presenter.handleDeleteMessage(context, conversationId),
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            primary: deepSpaceSparkle),
      ),
    );
  }

  showListOfUsers() {
    return AlertDialog(
      title: Text("Choose the recipient"),
      content: StreamBuilder(
        stream: databaseReference.collection("users").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Text('These are not the messages you are looking for');

          if (snapshot.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();

          return Container(
            height: 500,
            width: 300,
            child: ListView(
              key: Key("MessagesListOfUsers"),
              children: widget.presenter.getUser(context, snapshot),
            ),
          );
        },
      ),
    );
  }

  @override
  void update(User currentUser) {
    setState(() {
      _currentUser = currentUser;
    });
  }
}

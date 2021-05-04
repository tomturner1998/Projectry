import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/conversation/conversation_presenter.dart';
import 'package:project_finder/graphics/colours.dart';

class ConversationView {
  void update(String receiver) {}
}

class Conversation extends StatefulWidget {
  final ConversationPresenter presenter;

  Conversation(this.presenter, {Key key}) : super(key: key);

  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation>
    implements ConversationView {
  final FirebaseFirestore databaseReference = FirebaseFirestore.instance;

  String _receiver;

  @override
  void initState() {
    super.initState();
    widget.presenter.view = this;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: databaseReference.collection("conversations").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return Text('These are not the messages you are looking for');
        if (snapshot.connectionState == ConnectionState.waiting)
          return CircularProgressIndicator();
        return Scaffold(
          appBar: AppBar(
            title: Text(_receiver),
            backgroundColor: deepSpaceSparkle,
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  children: widget.presenter.getMessages(context, snapshot),
                  reverse: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: Key("ConversationMessageInput"),
                        decoration: InputDecoration(
                            labelText: "Type your message",
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                        controller: widget.presenter.messageController,
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    ElevatedButton(
                      key: Key("ConversationSendButton"),
                      onPressed: () {
                        widget.presenter.sendMessage(snapshot);
                      },
                      style: ElevatedButton.styleFrom(
                          primary: currentTheme.isDark
                              ? mediumChampagne
                              : indianYellow,
                          padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      child: Text(
                        "Send",
                        style: GoogleFonts.lato()
                            .copyWith(fontSize: 20, color: rosewood),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void update(String receiver) {
    setState(() {
      _receiver = receiver;
    });
  }
}

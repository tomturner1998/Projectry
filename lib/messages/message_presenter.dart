import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/conversation/conversation_presenter.dart';
import 'package:project_finder/conversation/conversation_view.dart';
import 'package:project_finder/messages/message_model.dart';
import 'package:project_finder/messages/message_view.dart';
import 'package:project_finder/messaging_utils/message_models.dart';

class MessagePresenter {
  FirebaseFirestore databaseReference;
  MessageModel messageModel;
  MessageView messageView;
  Auth auth;

  MessagePresenter(FirebaseFirestore databaseReference, Auth auth) {
    this.databaseReference = databaseReference;
    this.messageModel = MessageModel();
    this.auth = auth;
    this.messageModel.currentUser = auth.getCurrentUser();
    updateView();
  }

  set view(MessageView view) {
    messageView = view;
    updateView();
  }

  void updateView() {
    if (messageModel == null || messageView == null) {
      return;
    }

    messageView.update(messageModel.currentUser);
  }

  List<String> getPreviewMessage(List<dynamic> messages) {
    if (messages.length < 1) {
      return [];
    }

    Timestamp time = messages[messages.length - 1].timestamp;

    int minute = time.toDate().minute;
    String minuteString;
    if (minute < 10) {
      minuteString = "0" + minute.toString();
    } else {
      minuteString = minute.toString();
    }

    return [
      messages[messages.length - 1].content,
      time.toDate().hour.toString() + ":" + minuteString
    ];
  }

  void handleMessagePressed(
      BuildContext context, QueryDocumentSnapshot doc, String receiver) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Conversation(ConversationPresenter(auth, doc.id, receiver))));
  }

  void handleDeleteMessage(BuildContext context, String conversationId) {
    databaseReference.collection("conversations").doc(conversationId).delete();

    Navigator.of(context).pop();
  }

  List<Widget> getUser(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .where((doc) => doc.id != messageModel.currentUser.uid)
        .map((doc) => ListTile(
              title: Text(doc["full_name"]),
              subtitle: Text(doc["email"]),
              onTap: () {
                DocumentReference conversationDoc =
                    databaseReference.collection("conversations").doc();
                conversationDoc.set(ConversationDataModel(
                    participantOne: messageModel.currentUser.uid,
                    participantTwo: doc.id,
                    messages: []).toMap());

                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Conversation(
                            ConversationPresenter(
                                auth, conversationDoc.id, doc["full_name"]))));
              },
            ))
        .toList();
  }
}

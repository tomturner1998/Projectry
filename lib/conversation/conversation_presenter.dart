import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_finder/authentication/auth.dart';
import 'package:project_finder/conversation/conversation_model.dart';
import 'package:project_finder/conversation/conversation_view.dart';
import 'package:project_finder/messaging_utils/message_bubble.dart';
import 'package:project_finder/messaging_utils/message_models.dart';

class ConversationPresenter {
  final TextEditingController messageController = TextEditingController();

  ConversationModel conversationModel;
  ConversationView conversationView;

  ConversationPresenter(Auth auth, String conversationId, String receiver) {
    conversationModel = ConversationModel();
    loadModel(auth, conversationId, receiver);
  }

  void loadModel(Auth auth, String conversationId, String receiver) {
    conversationModel.currentUser = auth.getCurrentUser();
    conversationModel.conversationId = conversationId;
    conversationModel.receiver = receiver;
    updateView();
  }

  set view(ConversationView view) {
    conversationView = view;
    updateView();
  }

  void updateView() {
    if (conversationModel == null || conversationView == null) {
      return;
    }

    conversationView.update(conversationModel.receiver);
  }

  void sendMessage(AsyncSnapshot<QuerySnapshot> snapshot) {
    final conversationSnapshot = snapshot.data.docs.singleWhere(
        (conversation) => conversation.id == conversationModel.conversationId);

    final conversation =
        ConversationDataModel.fromQuerySnapshot(conversationSnapshot);

    conversation.messages.add(MessageDataModel(
        content: messageController.text,
        sender: conversationModel.currentUser.uid,
        timestamp: Timestamp.now()));

    messageController.clear();

    conversationSnapshot.reference.update(conversation.toMap());
  }

  List<MessageBubble> getMessages(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    final conversation = ConversationDataModel.fromQuerySnapshot(snapshot
        .data.docs
        .where((doc) => doc.id == conversationModel.conversationId)
        .toList()[0]);

    List<MessageBubble> tiles = [];
    List<dynamic> messages = conversation.messages;

    messages.sort(compareTimestamps);

    messages = messages.reversed.toList();
    for (int i = 0; i < messages.length; i++) {
      tiles.add(MessageBubble(
        message: messages[i] as MessageDataModel,
        self: conversationModel.currentUser.uid == messages[i].sender,
        previousSelf: i == messages.length - 1
            ? true
            : messages[i].sender == messages[i + 1].sender,
      ));
    }

    return tiles;
  }

  int compareTimestamps(dynamic o1, dynamic o2) {
    return o1.timestamp.compareTo(o2.timestamp);
  }
}

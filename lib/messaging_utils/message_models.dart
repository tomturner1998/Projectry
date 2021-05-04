import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationDataModel {
  final String participantOne;
  final String participantTwo;
  final List<dynamic> messages;

  ConversationDataModel({this.participantOne, this.participantTwo, this.messages});

  toMap() {
    return {
      "participantOne": this.participantOne,
      "participantTwo": this.participantTwo,
      "messages": this.messages.map((message) => message.toMap()).toList()
    };
  }

  static fromQuerySnapshot(QueryDocumentSnapshot snapshot) {
    return fromMap(snapshot.data());
  }

  static fromSnapshot(DocumentSnapshot snapshot) {
    return fromMap(snapshot.data());
  }

  static fromMap(Map<String, dynamic> map) {
    return ConversationDataModel(
        participantOne: map["participantOne"] as String,
        participantTwo: map["participantTwo"] as String,
        messages: (map["messages"] as List<dynamic>)
            .map((message) => MessageDataModel.fromMap(message))
            .toList());
  }
}

class MessageDataModel {
  final String content;
  final String sender;
  final Timestamp timestamp;

  MessageDataModel({this.content, this.sender, this.timestamp});

  toMap() {
    return {
      "content": this.content,
      "sender": this.sender,
      "timestamp": this.timestamp
    };
  }

  static fromMap(Map<String, dynamic> map) {
    return MessageDataModel(
        content: map["content"] as String,
        sender: map["sender"] as String,
        timestamp: map["timestamp"] as Timestamp);
  }
}

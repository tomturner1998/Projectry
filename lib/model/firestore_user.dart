import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_finder/model/roles.dart';

class FirestoreUser {
  final String id;
  String email;
  String fullName;
  final List<DocumentReference> preferences;
  final Role role;

  FirestoreUser(
      {this.id, this.email, this.fullName, this.preferences, this.role});

  toMap() {
    return {
      "email": this.email,
      "full_name": this.fullName,
      "preferences": this.preferences,
      "role": this.role.toString()
    };
  }

  static fromSnapshot(DocumentSnapshot snapshot) {
    return fromMap(snapshot.id, snapshot.data());
  }

  static fromMap(String id, Map<String, dynamic> map) {
    return FirestoreUser(
        id: id,
        email: map["email"],
        fullName: map["full_name"],
        preferences:
            (map["preferences"] as List).cast<DocumentReference>().toList(),
        role: roleFromString(map["role"]));
  }
}

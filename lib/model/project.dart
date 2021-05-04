import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_finder/model/user_with_provisional.dart';

class Project {
  final String title;
  final String briefDescription;
  final DocumentReference field;
  final String submitter;
  List<UserWithProvisional> claimedBy;
  bool approved;
  final int maxClaims;
  String supervisor;
  String preferredSupervisor;
  int claims;

  Project(
      {this.title,
      this.briefDescription,
      this.field,
      this.submitter,
      this.claimedBy,
      this.approved,
      this.supervisor,
      this.preferredSupervisor,
      this.maxClaims,
      this.claims});

  toMap() {
    return {
      "title": this.title,
      "briefDescription": this.briefDescription,
      "field": this.field,
      "submitter": this.submitter,
      "preferredSupervisor": this.preferredSupervisor,
      "claimedBy": this.claimedBy.map((e) => e.toMap()).toList(),
      "approved": this.approved,
      "supervisor": this.supervisor,
      "maxClaims": this.maxClaims,
      "claims": this.claims
    };
  }

  static fromSnapshot(QueryDocumentSnapshot snapshot) {
    return fromMap(snapshot.data());
  }

  static fromMap(Map<String, dynamic> map) {
    List<dynamic> claimedBy = (map["claimedBy"] as List);
    return Project(
        title: map["title"],
        briefDescription: map["briefDescription"],
        claimedBy: claimedBy != null
            ? claimedBy
                .cast<Map<String, dynamic>>()
                .map<UserWithProvisional>(
                    (map) => UserWithProvisional.fromMap(map))
                .toList()
            : [],
        field: map["field"],
        submitter: map["submitter"],
        preferredSupervisor: map["preferredSupervisor"],
        approved: map["approved"],
        supervisor: map["supervisor"],
        maxClaims: map["maxClaims"],
        claims: map["claims"]);
  }
}

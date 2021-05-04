class UserWithProvisional {
  final String userId;
  final bool provisional;

  UserWithProvisional({this.userId, this.provisional});

  toMap() {
    return {"userId": this.userId, "provisional": this.provisional};
  }

  static fromMap(Map<String, dynamic> map) {
    return UserWithProvisional(
      userId: map["userId"],
      provisional: map["provisional"]
    );
  }
}

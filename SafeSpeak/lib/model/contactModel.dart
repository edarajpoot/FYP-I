class ContactModel {
  final String? contactID;
  final String userID;
  final String keywordID;
  final String contactName;
  final String contactNumber;

  ContactModel({
    this.contactID,
    required this.userID,
    required this.keywordID,
    required this.contactName,
    required this.contactNumber,
  });

  Map<String, dynamic> toMap() {
  return {
    "userID": userID, // Make sure Firestore uses the correct case
    "keywordID": keywordID,
    "contactName": contactName,
    "contactNumber": contactNumber,
  };
}


  factory ContactModel.fromMap(String id, Map<String, dynamic> map) {
    return ContactModel(
      contactID: id,
      userID: map["userID"] ?? "",
      keywordID: map["keywordID"] ?? "",
      contactName: map["contactName"] ?? "",
      contactNumber: map["contactNumber"] ?? "",
    );
  }
}

class UserModel {
  final String name;
  final String email;
  final String phoneNo;
  final bool emergencyMode;

  UserModel({
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.emergencyMode,
  });

  // Firebase ke document se UserModel banane ka method
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNo: map['phoneNo'] ?? '',
      emergencyMode: map['emergencyMode'] ?? false,
    );
  }
}

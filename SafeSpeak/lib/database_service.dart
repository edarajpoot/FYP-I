import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/screens/signup.dart';

class DatabaseService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  Future<void> create(AppUser user, String userId) async {
    try {
      await _fire.collection("Users").doc(userId).set(user.toMap()); // Saves as object, not list
    } catch (e) {
      print("Error saving user: $e");
    }
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// Future<void> saveKeyword(String keyword) async {
//   String userId = FirebaseAuth.instance.currentUser!.uid; // Get logged-in user ID
//   await FirebaseFirestore.instance.collection('users').doc(userId).set({
//     'keyword': keyword,
//   }, SetOptions(merge: true));
// }

import 'package:flutter/material.dart';
import 'package:login/screens/signup.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SetKeywordScreen(),
  ));
}

class SetKeywordScreen extends StatelessWidget {
  const SetKeywordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(37, 66, 43, 1)),
                onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                },
                ),
              ),
              
              const SizedBox(height: 10),
              
              Image.asset('assets/images/woman.png', width: 150, height: 150),

              const SizedBox(height: 10),

              const Text(
                "Set your safety Keyword",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromRGBO(37, 66, 43, 1)),
              ),
              const SizedBox(height: 2),

              const Text(
                "Define the keywords that will activate the safety call.",
                style: TextStyle(fontSize: 14, color: Color.fromRGBO(37, 66, 43, 0.8)),
              ),

              const SizedBox(height: 30),
              SizedBox(
                    width: 370,
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Speak to Enter Keyword",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),

              const SizedBox(height: 25),

              // Microphone Button
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color.fromARGB(255, 220, 220, 220),
              child: IconButton(
                icon: const Icon(
                  Icons.mic,
                  color: Color.fromARGB(255, 37, 66, 43),
                  size: 28,
                ),
                onPressed: () {
                  // Add your microphone functionality here
                },
              ),
            ),
              // IconButton(
              //   icon: const Icon(Icons.mic, size: 40),
              //   onPressed: () {
              //     // Implement speech recording functionality later
              //   },
              // ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Implement keyword save logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(37, 66, 43, 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                ),
                child: const Text(
                  "Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              ],
             ),
            ),
          ),
        ],
      ),
    );
  }
}
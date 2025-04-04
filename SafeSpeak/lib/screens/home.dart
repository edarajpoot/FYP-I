import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/model/usermodel.dart';
//import 'package:get/get.dart';
import 'package:login/screens/login.dart';

class HomePage extends StatefulWidget {

  final UserModel user;
  const HomePage({Key? key, required this.user});
  

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<void> signout()async{
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
     context,
     MaterialPageRoute(builder: (context) => LogInScreen()),
    );
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome, ${widget.user.name}")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Name: ${widget.user.name}"), 
            Text("Email: ${widget.user.email}"),
            Text("Phone: ${widget.user.phoneNo}"),
            Text("Emergency Mode: ${widget.user.emergencyMode ? "Enabled" : "Disabled"}"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (()=>signout()),
        child: const Icon(Icons.login_rounded),
        ),
    );
  }
}
 
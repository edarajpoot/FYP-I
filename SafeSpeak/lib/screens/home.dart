import 'dart:math';

import 'package:login/widgets/customappbar.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/model/usermodel.dart';
//import 'package:get/get.dart';
import 'package:login/screens/login.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';


class HomePage extends StatefulWidget {

  final UserModel user;
  const HomePage({Key? key, required this.user});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int qIndex = 0;

  final SpeechToText speechToText = SpeechToText();
  var text = 'hold the button and start speaking';
  var isListening = false;

  Future<void> _makeEmergencyCall() async {
  const emergencyNumber = '1234567890'; // Replace with actual emergency number
  await FlutterPhoneDirectCaller.callNumber(emergencyNumber);
}

  getRandomQuote(){
    Random random = Random();
    setState(() {
      qIndex=random.nextInt(6);
    });
  }

   @override
  void initState() {     
    getRandomQuote();
    super.initState();
  }

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
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: AvatarGlow(
      animate: isListening,
      duration: const Duration(milliseconds: 2000),
      glowColor: Color(0xff00A67E),
      repeat: true,
      child: GestureDetector(
        onTapDown: (details) async {
          if (!isListening) {
            var available = await speechToText.initialize();
            if (available) {
              setState(() {
                isListening = true;
                speechToText.listen(
                  onResult: (result) {
                    setState(() {
                      text = result.recognizedWords;
                    });
                    if (result.recognizedWords.toLowerCase().contains('emergency')) {
                      _makeEmergencyCall();
                    }
                  },
                );
              });
            } else {
              // Show an error message if speech-to-text is not available
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Speech recognition is not available on this device.')),
              );
            }
          }
        },
        onTapUp: (details) {
          setState(() {
            isListening = false;
          });
          speechToText.stop();
        },
        child: CircleAvatar(
          backgroundColor: Color(0xff00A67E),
          radius: 35,
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            color: Colors.white,
          ),
        ),
      ),
    ),
    appBar: AppBar(title: Text("Welcome, ${widget.user.name}")),
    body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomAppBar(
            quoteIndex: qIndex,
            onTap: () {
              getRandomQuote();
            },
          ),
          SizedBox(height: 20), // You can add some space between elements
          Text(
            text, 
            style: TextStyle(fontSize: 24),
          ),
          // Any other widgets you want to display can go here.
        ],
      ),
    ),
  );
}

  }

 
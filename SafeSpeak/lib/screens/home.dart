import 'dart:math';

import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:login/widgets/customappbar.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/model/usermodel.dart';
import 'package:login/screens/login.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  final UserModel user;
  final KeywordModel? keywordData;
  final List<ContactModel> contacts;
  const HomePage({
    Key? key, 
    required this.user,
    required this.keywordData,
    required this.contacts,
    }): super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int qIndex = 0;

  final SpeechToText speechToText = SpeechToText();
  var text = 'Hold the button and start speaking';
  var isListening = false;

  Future<void> _makeEmergencyCall() async {
    const emergencyNumber = '+92 321 7996093'; // Replace with actual emergency number
    await FlutterPhoneDirectCaller.callNumber(emergencyNumber);
  }

  getRandomQuote() {
    Random random = Random();
    setState(() {
      qIndex = random.nextInt(6);
    });
  }

  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
      status = await Permission.microphone.status;  // Re-check after requesting
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required to use speech recognition.')),
        );
      }
    }
  }

  @override
  void initState() {
    getRandomQuote();
    _requestMicrophonePermission();
    super.initState();
  }

  Future<void> signout() async {
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
        glowColor: const Color(0xff00A67E),
        repeat: true,
        child: GestureDetector(
          onTapDown: (details) async {
            if (!isListening) {
              var available = await speechToText.initialize();
              if (available) {
                setState(() {
                  isListening = true;
                  text = "Listening...";  // Indicate the mic is actively listening
                  speechToText.listen(
                    onResult: (result) {
                      setState(() {
                        text = result.recognizedWords;
                      });
                      if (result.recognizedWords.toLowerCase().contains('hello')) {
                        _makeEmergencyCall();
                      }
                    },
                  );
                });
              } else {
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
            backgroundColor: const Color(0xff00A67E),
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
            Text('User: ${widget.user.name}'),
            Text('Email: ${widget.user.email}'),
            Text('Keyword: ${widget.keywordData?.voiceText ?? 'No Keyword'}'),
             // Check if contacts are available and display them
            widget.contacts.isEmpty
                ? const Text('No contacts available.')
                : ListView.builder(
                    shrinkWrap: true, // Prevents ListView from taking up unnecessary space
                    itemCount: widget.contacts.length,
                    itemBuilder: (context, index) {
                      final contact = widget.contacts[index];
                      return ListTile(
                        title: Text(contact.contactName),
                        subtitle: Text(contact.contactNumber),
                      );
                    },
                  ),
            CustomAppBar(
              quoteIndex: qIndex,
              onTap: () {
                getRandomQuote();
              },
            ),
            const SizedBox(height: 20),
            Text(
              text,
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
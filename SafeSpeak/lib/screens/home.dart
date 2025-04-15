import 'dart:math';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:login/screens/backgroungServices.dart';
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


  Future<void> _makeEmergencyCall(String number) async {
  await FlutterPhoneDirectCaller.callNumber(number);
}


  getRandomQuote() {
    Random random = Random();
    setState(() {
      qIndex = random.nextInt(6);
    });
  }

Future<void> _requestMicrophonePermission() async {
  var status = await Permission.microphone.status;

  if (status.isGranted) {
    print('Microphone permission already granted');
    return;
  }

  if (!status.isDenied && !status.isPermanentlyDenied) {
    print('Waiting for previous permission request to complete...');
    return;
  }

  var result = await Permission.microphone.request();
  print('Microphone permission result: $result');
}



  @override
  void initState() {
    getRandomQuote();
    _requestMicrophonePermission();
    super.initState();
    _startBackgroundService();

   if (widget.keywordData != null && widget.contacts.isNotEmpty) {
    print('✅ Sending keyword to background: ${widget.keywordData!.voiceText}');
    print('✅ Contacts to background: ${widget.contacts.length}');
    initializeService(widget.contacts, widget.keywordData!);
  } else {
    print('⚠️ No keyword or contacts provided to service');
  }
  }
   Future<void> _startBackgroundService() async {
    await FlutterBackgroundService().startService();
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
    String keywordText = widget.keywordData?.voiceText ?? 'No Keyword';

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
                      String spokenText = result.recognizedWords.toLowerCase();
                      String keywordText = widget.keywordData?.voiceText.toLowerCase() ?? '';

                      if (spokenText.contains(keywordText)) {
    // Match found, now find all contacts linked to this keywordID
    String matchedKeywordID = widget.keywordData?.keywordID ?? '';

    for (var contact in widget.contacts) {
      if (contact.keywordID == matchedKeywordID) {
        _makeEmergencyCall(contact.contactNumber);
        break; // call only the first one, or remove break if you want multiple
      }
    }
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
           Text('Keyword: $keywordText'),
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
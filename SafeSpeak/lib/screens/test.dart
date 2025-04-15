import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

SpeechToText speech = SpeechToText();

class SpeechTestPage extends StatefulWidget {
  @override
  _SpeechTestPageState createState() => _SpeechTestPageState();
}

class _SpeechTestPageState extends State<SpeechTestPage> {
  String heardText = "Waiting...";

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  Future<void> initSpeech() async {
    bool available = await speech.initialize(
      onStatus: (status) {
        debugPrint("🎙️ Status: $status");
      },
      onError: (error) {
        debugPrint("❌ Error: $error");
      },
    );
    if (available) {
      speech.listen(
        onResult: (result) {
          setState(() {
            heardText = result.recognizedWords;
          });
          debugPrint("🗣️ Heard: ${result.recognizedWords}");
        },
        listenMode: ListenMode.dictation,
        pauseFor: Duration(seconds: 4),
        partialResults: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Speech Test")),
      body: Center(
        child: Text(
          heardText,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

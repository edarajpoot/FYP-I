import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'dart:async';

// Initialize the notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeService(List<ContactModel> contacts, KeywordModel keywordModel) async {
  print("🚀 Starting background service...");
  print("Keyword to detect: ${keywordModel.voiceText}");
  print("Total contacts: ${contacts.length}");

  // Requesting permissions
  await Permission.microphone.request();
  await Permission.phone.request();

  // Check if permissions are granted
  PermissionStatus microphoneStatus = await Permission.microphone.status;
  PermissionStatus phoneStatus = await Permission.phone.status;

  if (microphoneStatus.isGranted && phoneStatus.isGranted) {
    print("Permissions granted");
  } else {
    print("Permissions not granted");
    return;  // Optionally return if permissions are not granted
  }

  final service = FlutterBackgroundService();

  // Create notification channel for Android 8.0+
  createNotificationChannel();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true, // Foreground service
      autoStart: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'SafeSpeak Running',
      initialNotificationContent: 'Listening for keywords...',
      foregroundServiceNotificationId: 888, // Notification ID for foreground service
    ),
    iosConfiguration: IosConfiguration(),
  );

  await service.startService();

  List<Map<String, dynamic>> contactMaps = contacts.map((e) => e.toJson()).toList();

  service.invoke('start-listening', {
    'contacts': contactMaps,
    'keywordText': keywordModel.voiceText,
  });
}

void createNotificationChannel() async {
  final AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // The id of the channel
    'SafeSpeak Running', // The name of the channel
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}
bool isCallInProgress = false;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  print("✅ Speech is listening");

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Speech recognition setup
  final speech = SpeechToText();
  bool available = await speech.initialize();
  if (!available) {
    print("Speech recognition not available.");
    return;
  }

  List<dynamic> contacts = [];
  String keyword = "";
  bool isListening = false; // ✅ Define it here inside onStart

  service.on('start-listening').listen((event) async {
    print("📩 Data received in background service: $event");

    if (event != null) {
      contacts = event['contacts'];
      keyword = (event['keywordText'] ?? "").toLowerCase();
      print("🎤 Listening for keyword: $keyword");

      if (!isListening) {
        isListening = true;

        speech.listen(
          onResult: (result) async {
  String spoken = result.recognizedWords.toLowerCase();
  print("🗣️ Heard: $spoken");

  if (spoken.contains(keyword) && !isCallInProgress) {
    print("🚨 Keyword matched! Calling now...");
    isCallInProgress = true;

    for (var contact in contacts) {
      await FlutterPhoneDirectCaller.callNumber(contact['contactNumber']);
    }

    // Wait a few seconds before allowing a new call
    await Future.delayed(Duration(seconds: 5));
    isCallInProgress = false;
  }

  // 🔁 This part is the most important for continuous listening
  if (result.finalResult) {
    print("🛑 Final result received. Stopping current session.");
    isListening = false;

    // Small delay before restarting
    Future.delayed(Duration(seconds: 1), () {
      if (!isListening) {
        print("🔁 Restarting listening session.");
        service.invoke('start-listening', {
          'contacts': contacts,
          'keywordText': keyword,
        });
      }
    });
  }
},




          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 3),
          listenMode: ListenMode.dictation,
          partialResults: true,
        );
      } else {
        print("⚠️ Already listening, skipping new listen start.");
      }
    }
  });
}

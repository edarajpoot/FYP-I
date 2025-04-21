import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';

// final Telephony telephony = Telephony.instance;

// Future<void> sendEmergencySms(String number, String message) async {
  
//   bool? permissionsGranted = await telephony.requestSmsPermissions;
//     if (permissionsGranted ?? false) {
//       telephony.sendSms(to: number, message: message);
//       print("📨 SMS sent from BACKGROUND isolate: $number");
//     } else {
//       print("❌ SMS permission not granted (background isolate)");
//     }
// }


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
  await Permission.sms.request();


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
      isForegroundMode: true, // Foreground service to keep the service running
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
  WidgetsFlutterBinding.ensureInitialized();
  print("✅ Speech is listening");

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Speech recognition setup
  final speech = SpeechToText();
  bool available = await speech.initialize();
  if (!available) {
    print("Speech recognition not available.");
    return;
  }

//   service.on('send-sms').listen((event) async {
//   if (event != null) {
//     print("📥 Received send-sms event: $event");

//     final number = event['number'];
//     final message = event['message'];

//     print("📲 Attempting to send SMS in background to $number");

//     bool? permissionsGranted = await telephony.requestSmsPermissions;
//     if (permissionsGranted ?? false) {
//       telephony.sendSms(to: number, message: message);
//       print("📨 SMS sent from BACKGROUND isolate: $number");
//     } else {
//       print("❌ SMS permission not granted (background isolate)");
//     }
//   } else {
//     print("❌ No data received in send-sms event");
//   }
// });


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
        await startListeningSession(speech, contacts, keyword, service);
      } else {
        print("⚠️ Already listening, skipping new listen start.");
      }
    }
  });
}

Future<void> startListeningSession(SpeechToText speech, List<dynamic> contacts, String keyword, ServiceInstance service) async {
  print("🎤 Starting new listening session...");

  speech.listen(
    onResult: (result) async {
      String spoken = result.recognizedWords.toLowerCase();
      print("🗣️ Heard: $spoken");

      // Phone call logic with error handling
      if (spoken.contains(keyword) && !isCallInProgress) {
        print("🚨 Keyword matched! Calling now...");
        isCallInProgress = true;

        try {
    // 🔁 Loop for both SMS and Call
    for (var contact in contacts) {
      String number = contact['contactNumber'];

      // Send SMS
      // print("📡 Invoking send-sms for $number from main isolate");
      // await Future.delayed(Duration(seconds: 2));
      // service.invoke('send-sms', {
      //   'number': number,
      //   'message': "🚨 Emergency! Please help.",
      // });
      // print("📡 Invoking send-sms with number: $number, message: Emergency alert");

//       bool permissionGranted = await Permission.sms.request().isGranted;
// if (permissionGranted) {
//   SmsSender sender = SmsSender();
//   SmsMessage sms = SmsMessage(number, "🚨 Emergency! Please help.");
//   sms.onStateChanged.listen((state) {
//     print('📨 SMS State in background: $state');
//   });
//   sender.sendSms(sms);
//   print("📨 SMS sent to $number");
// } else {
//   print("❌ SMS permission denied in background");
// }


      // print("Sending Message from MAIN isolate: $contact");
      // sendSmsMessage(contact, "🚨 This is an emergency! Please help.");

      // Make Call
      await Future.delayed(Duration(seconds: 2));
      service.invoke('make-call', {
        'contacts': [contact],
      });

      await Future.delayed(Duration(seconds: 5));
    }

  } catch (e) {
    print("❌ Error during emergency handling: $e");
  }

        // Wait a few seconds before allowing a new call
        await Future.delayed(Duration(seconds: 5));
        isCallInProgress = false;
      }

      // 🔁 This part is the most important for continuous listening
      if (result.finalResult) {
        print("🛑 Final result received. Restarting listening without stopping...");
        await Future.delayed(Duration(seconds: 1));

        // Keep listening, avoid stopping the session prematurely
        await startListeningSession(speech, contacts, keyword, service);
      }
    },
  );

}

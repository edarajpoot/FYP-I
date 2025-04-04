import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDummyData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Populates or merges Firestore with dummy data for the currently logged in user
  /// Call this function after a successful login or signup
  Future<void> populateDummyData() async {
    try {
      // Get current user ID
      final User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        print('No user is currently logged in.');
        return;
      }
      
      final String userId = currentUser.uid;
      final String userEmail = currentUser.email ?? 'user@example.com';
      final String userName = currentUser.displayName ?? 'User';
      
      print('Starting data population for user: $userId');
      
      // Print user data before update
      try {
        DocumentSnapshot userDoc = await _firestore.collection('Users').doc(userId).get();
        print('BEFORE UPDATE - User document exists: ${userDoc.exists}');
        
        if (userDoc.exists) {
          print('BEFORE UPDATE - User data: ${userDoc.data()}');
          
          // Check subcollections
          QuerySnapshot contactsSnapshot = await userDoc.reference.collection('emergency_contacts').get();
          print('BEFORE UPDATE - Emergency contacts count: ${contactsSnapshot.size}');
          
          QuerySnapshot keywordsSnapshot = await userDoc.reference.collection('emergency_keywords').get();
          print('BEFORE UPDATE - Emergency keywords count: ${keywordsSnapshot.size}');
          
          QuerySnapshot callHistorySnapshot = await userDoc.reference.collection('call_history').get();
          print('BEFORE UPDATE - Call history count: ${callHistorySnapshot.size}');
        }
      } catch (e) {
        print('Error fetching existing data: $e');
      }
      
      // Start a batch write for better performance and atomicity
      final WriteBatch batch = _firestore.batch();
      
      // 1. Create or update User document
      print('Setting up user document');
      final userRef = _firestore.collection('Users').doc(userId);
      
      // Set with merge: true to avoid overwriting existing data
      batch.set(userRef, {
        'name': userName,
        'email': userEmail,
        'phone_number': '+923001234567',
        'created_at': FieldValue.serverTimestamp(),
        'last_login': FieldValue.serverTimestamp(),
        'emergency_mode': true,
        // 'profile_image_url': 'https://firebasestorage.googleapis.com/v0/b/safespeak.appspot.com/o/profile_images%2Fdefault.jpg',
        'current_location': {
          'latitude': 31.5204,
          'longitude': 74.3587,
          'accuracy': 15.0,
          'address': 'Walton Road, Lahore, Pakistan',
          'last_updated': FieldValue.serverTimestamp()
        },
        'settings': {
          'dark_mode': false,
          'notification_enabled': true,
          'vibration_enabled': true,
          'sound_enabled': true
        }
      }, SetOptions(merge: true));
      
      // 2. Create Emergency Contacts if they don't exist
      print('Creating emergency contacts');
      final contactsData = [
        {
          'name': 'Maliha Mehboob',
          'phone_number': '+923009876543',
          'relationship': 'Friend',
          'priority': 1,
          'created_at': FieldValue.serverTimestamp()
        },
        {
          'name': 'Dr. Erum Mehmood',
          'phone_number': '+923334567890',
          'relationship': 'Supervisor',
          'priority': 2,
          'created_at': FieldValue.serverTimestamp()
        },
        {
          'name': 'Kiran Shehla',
          'phone_number': '+923216789012',
          'relationship': 'Department Head',
          'priority': 3,
          'created_at': FieldValue.serverTimestamp()
        }
      ];
      
      final List<String> contactIds = [];
      
      for (int i = 0; i < contactsData.length; i++) {
        final contactId = 'contact${i+1}';
        contactIds.add(contactId);
        final contactRef = userRef.collection('emergency_contacts').doc(contactId);
        batch.set(contactRef, contactsData[i], SetOptions(merge: true));
      }
      
      // 3. Create Voice Recordings
      print('Setting up voice recordings');
      final voiceRecordingsData = [
        {
          'user_id': userId,
          'keyword_id': 'keyword1',
          'storage_path': 'voice_samples/$userId/help_me.mp3',
          'created_at': FieldValue.serverTimestamp(),
          'duration': 1.8,
          'file_size': 22400
        },
        {
          'user_id': userId,
          'keyword_id': 'keyword2',
          'storage_path': 'voice_samples/$userId/emergency.mp3',
          'created_at': FieldValue.serverTimestamp(),
          'duration': 2.2,
          'file_size': 26800
        },
        {
          'user_id': userId,
          'keyword_id': 'keyword3',
          'storage_path': 'voice_samples/$userId/sos.mp3',
          'created_at': FieldValue.serverTimestamp(),
          'duration': 1.2,
          'file_size': 18600
        }
      ];
      
      for (int i = 0; i < voiceRecordingsData.length; i++) {
        final voiceId = 'voice${i+1}';
        final voiceRef = _firestore.collection('voice_recordings').doc(voiceId);
        batch.set(voiceRef, voiceRecordingsData[i], SetOptions(merge: true));
      }
      
      // 4. Create Emergency Keywords
      print('Setting up emergency keywords');
      final keywordsData = [
        {
          'keyword_text': 'Help me',
          'voice_recording_id': 'voice1',
          'created_at': FieldValue.serverTimestamp(),
          'last_updated': FieldValue.serverTimestamp(),
          'associated_contacts': [contactIds[0], contactIds[1]]
        },
        {
          'keyword_text': 'Emergency',
          'voice_recording_id': 'voice2',
          'created_at': FieldValue.serverTimestamp(),
          'last_updated': FieldValue.serverTimestamp(),
          'associated_contacts': [contactIds[0], contactIds[1], contactIds[2]]
        },
        {
          'keyword_text': 'SOS',
          'voice_recording_id': 'voice3',
          'created_at': FieldValue.serverTimestamp(),
          'last_updated': FieldValue.serverTimestamp(),
          'associated_contacts': [contactIds[1]]
        }
      ];
      
      for (int i = 0; i < keywordsData.length; i++) {
        final keywordId = 'keyword${i+1}';
        final keywordRef = userRef.collection('emergency_keywords').doc(keywordId);
        batch.set(keywordRef, keywordsData[i], SetOptions(merge: true));
      }
      
      // 5. Create Call History
      print('Setting up call history');
      final callHistoryData = [
        {
          'triggered_keyword_id': 'keyword1',
          'triggered_at': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 6))),
          'location': {
            'latitude': 31.5204,
            'longitude': 74.3587,
            'address': 'Walton Road, Lahore, Pakistan'
          },
          'contacts_notified': [
            {
              'contact_id': contactIds[0],
              'name': 'Maliha Mehboob',
              'status': 'connected',
              'call_duration': 65
            },
            {
              'contact_id': contactIds[1],
              'name': 'Dr. Erum Mehmood',
              'status': 'no_answer',
              'call_duration': 0
            }
          ],
          'sms_sent': true
        },
        {
          'triggered_keyword_id': 'keyword3',
          'triggered_at': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 4))),
          'location': {
            'latitude': 31.5150,
            'longitude': 74.3400,
            'address': 'Mall Road, Lahore, Pakistan'
          },
          'contacts_notified': [
            {
              'contact_id': contactIds[1],
              'name': 'Dr. Erum Mehmood',
              'status': 'connected',
              'call_duration': 120
            }
          ],
          'sms_sent': true
        },
        {
          'triggered_keyword_id': 'keyword2',
          'triggered_at': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
          'location': {
            'latitude': 31.4700,
            'longitude': 74.4126,
            'address': 'Allama Iqbal International Airport, Lahore, Pakistan'
          },
          'contacts_notified': [
            {
              'contact_id': contactIds[0],
              'name': 'Maliha Mehboob',
              'status': 'connected',
              'call_duration': 45
            },
            {
              'contact_id': contactIds[1],
              'name': 'Dr. Erum Mehmood',
              'status': 'connected',
              'call_duration': 30
            },
            {
              'contact_id': contactIds[2],
              'name': 'Kiran Shehla',
              'status': 'rejected',
              'call_duration': 0
            }
          ],
          'sms_sent': true
        }
      ];
      
      for (int i = 0; i < callHistoryData.length; i++) {
        final callId = 'call${i+1}';
        final callRef = userRef.collection('call_history').doc(callId);
        batch.set(callRef, callHistoryData[i], SetOptions(merge: true));
      }
      
      // Commit the batch
      print('Committing batch to Firestore...');
      await batch.commit();
      
      print('Successfully populated/merged dummy data for user: $userId');
      
      // Print user data after update
      try {
        DocumentSnapshot updatedUserDoc = await _firestore.collection('users').doc(userId).get();
        print('AFTER UPDATE - User data: ${updatedUserDoc.data()}');
        
        // Check subcollections
        QuerySnapshot contactsSnapshot = await updatedUserDoc.reference.collection('emergency_contacts').get();
        print('AFTER UPDATE - Emergency contacts count: ${contactsSnapshot.size}');
        
        QuerySnapshot keywordsSnapshot = await updatedUserDoc.reference.collection('emergency_keywords').get();
        print('AFTER UPDATE - Emergency keywords count: ${keywordsSnapshot.size}');
        
        QuerySnapshot callHistorySnapshot = await updatedUserDoc.reference.collection('call_history').get();
        print('AFTER UPDATE - Call history count: ${callHistorySnapshot.size}');
      } catch (e) {
        print('Error fetching updated data: $e');
      }
      
    } catch (e) {
      print('Error populating dummy data: $e');
      rethrow;
    }
  }
}
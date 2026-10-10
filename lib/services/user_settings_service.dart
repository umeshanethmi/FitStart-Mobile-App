import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSettingsService {
  UserSettingsService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to access your settings.');
    }
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userDocument =>
      _firestore.collection('users').doc(_userId);

  Future<bool> loadWorkoutReminders() async {
    final snapshot = await _userDocument.get();
    final settings = snapshot.data()?['settings'];
    if (settings is Map<String, dynamic>) {
      return settings['workoutReminders'] as bool? ?? false;
    }
    return false;
  }

  Future<void> saveWorkoutReminders(bool enabled) async {
    final userDocument = _userDocument;
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDocument);
      if (snapshot.exists) {
        transaction.update(userDocument, {
          'settings.workoutReminders': enabled,
        });
      } else {
        transaction.set(userDocument, {
          'settings': {'workoutReminders': enabled},
        });
      }
    });
  }

  Future<void> requestAccountDeletion() async {
    await _userDocument.collection('account_deletion_requests').add({
      'status': 'requested',
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }
}

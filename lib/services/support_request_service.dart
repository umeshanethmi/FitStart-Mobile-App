import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitstart_mobile_app/models/support_request.dart';

class SupportRequestService {
  SupportRequestService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to view or send support requests.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _requestsFor(String userId) =>
      _firestore.collection('users').doc(userId).collection('support_requests');

  Stream<List<SupportRequest>> watchRequests() async* {
    final userId = _userId;
    await for (final snapshot in _requestsFor(
      userId,
    ).orderBy('createdAt', descending: true).snapshots()) {
      yield snapshot.docs.map(SupportRequest.fromDocument).toList();
    }
  }

  Future<void> submitRequest({
    required String expertId,
    required String expertName,
    required String specialization,
    required String message,
  }) async {
    final normalizedMessage = message.trim();
    if (normalizedMessage.length < 10 || normalizedMessage.length > 2000) {
      throw ArgumentError(
        'Your message must be between 10 and 2000 characters.',
      );
    }

    final userId = _userId;
    await _requestsFor(userId).add({
      'userId': userId,
      'expertId': expertId,
      'expertName': expertName,
      'specialization': specialization,
      'message': normalizedMessage,
      'status': 'submitted',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

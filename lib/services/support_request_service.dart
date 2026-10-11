import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fitstart_mobile_app/models/expert_profile.dart';
import 'package:fitstart_mobile_app/models/support_request.dart';

class SupportRequestService {
  static const _logName = 'fitstart.support_request';

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

  DocumentReference<Map<String, dynamic>> _requestReference(
    SupportRequest request,
  ) {
    if (request.userId.isEmpty || request.id.isEmpty) {
      throw ArgumentError('The support request is missing its owner or ID.');
    }
    return _requestsFor(request.userId).doc(request.id);
  }

  Stream<List<SupportRequest>> watchRequests() {
    final userId = _userId;
    return _requestsFor(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(SupportRequest.fromDocument).toList(),
        );
  }

  Stream<List<SupportRequest>> watchAssignedRequests() {
    final expertId = _userId;
    return Stream.multi((controller) {
      StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;
      var cancelled = false;

      controller.onCancel = () {
        cancelled = true;
        final activeSubscription = subscription;
        if (activeSubscription != null) {
          unawaited(activeSubscription.cancel());
        }
      };

      unawaited(() async {
        try {
          final profile = await _firestore
              .collection('users')
              .doc(expertId)
              .get();
          final data = profile.data();
          final role = ExpertProfile.normalizeRole(data?['role'] as String?);
          if (data?['isApproved'] != true ||
              !ExpertProfile.isSupportedExpertRole(role)) {
            throw StateError(
              'Only approved coaches and therapists can view requests.',
            );
          }
          if (cancelled) return;

          subscription = _firestore
              .collectionGroup('support_requests')
              .where('expertId', isEqualTo: expertId)
              .snapshots()
              .listen(
                (snapshot) {
                  final requests =
                      snapshot.docs.map(SupportRequest.fromDocument).toList()
                        ..sort((first, second) {
                          final firstDate = first.activityAt ?? first.createdAt;
                          final secondDate =
                              second.activityAt ?? second.createdAt;
                          if (firstDate == null) return 1;
                          if (secondDate == null) return -1;
                          return secondDate.compareTo(firstDate);
                        });
                  if (!cancelled) controller.add(requests);
                },
                onError: (Object error, StackTrace stackTrace) {
                  if (!cancelled) controller.addError(error, stackTrace);
                },
                onDone: () {
                  if (!cancelled) controller.close();
                },
              );
          if (cancelled) {
            await subscription?.cancel();
          }
        } catch (error, stackTrace) {
          if (!cancelled) {
            controller.addError(error, stackTrace);
            controller.close();
          }
        }
      }());
    });
  }

  Stream<List<SupportRequestReply>> watchReplies(SupportRequest request) {
    final reference = _requestReference(request);
    return reference
        .collection('replies')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(SupportRequestReply.fromDocument).toList(),
        );
  }

  Future<void> submitRequest({
    required String expertId,
    required String expertRole,
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
    final normalizedRole = ExpertProfile.normalizeRole(expertRole);
    if (expertId.trim().isEmpty ||
        !ExpertProfile.isSupportedExpertRole(normalizedRole)) {
      throw ArgumentError('Choose an approved coach or therapist.');
    }
    final user = _auth.currentUser!;
    final requestReference = _requestsFor(userId).doc();
    final requestData = {
      'userId': userId,
      'expertId': expertId,
      'expertRole': normalizedRole,
      'expertName': expertName,
      'specialization': specialization,
      'userName': user.displayName ?? user.email?.split('@').first ?? 'Member',
      'message': normalizedMessage,
      'status': 'submitted',
      'createdAt': FieldValue.serverTimestamp(),
      'lastActivityAt': FieldValue.serverTimestamp(),
      'lastMessage': normalizedMessage,
    };

    try {
      if (kDebugMode) {
        developer.log(
          'Creating support request: path=${requestReference.path}, '
          'userId=$userId, expertId=$expertId, expertRole=$normalizedRole, '
          'messageLength=${normalizedMessage.length}, '
          'timestampFields=createdAt,lastActivityAt(serverTimestamp), '
          'fields=${requestData.keys.join(',')}.',
          name: _logName,
        );
      }
      await requestReference.set(requestData);
    } on FirebaseException catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Support request create failed: operation=set (create), '
          'path=${requestReference.path}, userId=$userId, '
          'expertId=$expertId, expertRole=$normalizedRole, '
          'code=${error.code}.',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }

  Future<void> replyToRequest({
    required SupportRequest request,
    required String text,
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty || normalizedText.length > 2000) {
      throw ArgumentError('A reply must be between 1 and 2000 characters.');
    }

    final expertId = _userId;
    final profilePath = 'users/$expertId';
    var operation = 'get expert profile';
    try {
      final profile = await _firestore.collection('users').doc(expertId).get();
      final profileData = profile.data();
      final role = ExpertProfile.normalizeRole(profileData?['role'] as String?);
      if (profileData?['isApproved'] != true ||
          !ExpertProfile.isSupportedExpertRole(role) ||
          request.expertId != expertId) {
        throw StateError('You are not authorized to reply to this request.');
      }

      final requestReference = _requestReference(request);
      final replyReference = requestReference.collection('replies').doc();
      final batch = _firestore.batch();
      operation = 'batch create reply and update request';
      batch.set(replyReference, {
        'senderId': expertId,
        'senderRole': role,
        'text': normalizedText,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(requestReference, {
        'lastMessage': normalizedText,
        'lastActivityAt': FieldValue.serverTimestamp(),
        'status': 'in_progress',
      });
      await batch.commit();
    } on FirebaseException catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Support request reply failed: operation=$operation, '
          'profilePath=$profilePath, requestPath='
          '${_requestReference(request).path}, expertId=$expertId, '
          'code=${error.code}.',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }
}

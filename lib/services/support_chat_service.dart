import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fitstart_mobile_app/models/expert_profile.dart';
import 'package:fitstart_mobile_app/models/support_chat.dart';

class SupportChatService {
  static const _logName = 'fitstart.support_chat';

  SupportChatService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to access support chats.');
    }
    return user.uid;
  }

  String buildChatId({required String userId, required String expertId}) {
    final ids = [userId, expertId]..sort();
    return ids.join('_');
  }

  Future<SupportChat> getOrCreateChat({
    required String expertId,
    required String expertRole,
    required String expertName,
  }) async {
    final userId = currentUserId;
    if (expertId.isEmpty || expertId == userId) {
      throw ArgumentError('Choose a valid expert to start a chat.');
    }
    final normalizedRole = ExpertProfile.normalizeRole(expertRole);
    if (!ExpertProfile.isSupportedExpertRole(normalizedRole)) {
      throw ArgumentError('Choose an approved coach or therapist.');
    }
    if (expertName.trim().isEmpty) {
      throw ArgumentError('The selected expert profile has no display name.');
    }

    final chatId = buildChatId(userId: userId, expertId: expertId);
    final chatReference = _firestore.collection('support_chats').doc(chatId);

    var operation = 'get member profile';
    var documentPath = 'users/$userId';
    try {
      final userDocument = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      final userData = userDocument.data() ?? const <String, dynamic>{};
      final user = _auth.currentUser!;
      final userRole = userData['role'];
      final isApproved = userData['isApproved'] == true;
      final requesterIsApprovedExpert =
          isApproved &&
          ExpertProfile.isSupportedExpertRole(
            userRole is String ? userRole : null,
          );
      if (kDebugMode) {
        developer.log(
          'Chat requester profile: uid=$userId, role=$userRole, '
          'isApproved=$isApproved, approvedExpert=$requesterIsApprovedExpert.',
          name: _logName,
        );
      }
      final userName = _displayName(
        userData['name'] as String?,
        user.displayName,
        user.email,
      );

      operation = 'transaction get chat';
      documentPath = chatReference.path;
      await _firestore.runTransaction((transaction) async {
        operation = 'transaction get chat';
        final chatDocument = await transaction.get(chatReference);
        if (chatDocument.exists) {
          operation = 'validate existing chat';
          final existing = chatDocument.data()!;
          final existingParticipants = existing['participantIds'];
          if (existing['userId'] != userId ||
              existing['expertId'] != expertId ||
              existing['expertRole'] != normalizedRole ||
              existingParticipants is! List ||
              existingParticipants.length != 2 ||
              !existingParticipants.contains(userId) ||
              !existingParticipants.contains(expertId) ||
              existing['chatId'] != chatId) {
            throw StateError(
              'This conversation does not match its participants.',
            );
          }
          return;
        }

        if (requesterIsApprovedExpert) {
          throw StateError(
            'Approved experts cannot start a new member support chat. '
            'Sign in with a member account to contact an expert.',
          );
        }

        if (kDebugMode) {
          developer.log(
            'Creating chat: path=${chatReference.path}, chatId=$chatId, '
            'userId=$userId, expertId=$expertId, '
            'participantIds=[$userId, $expertId], '
            'expertRole=$normalizedRole, expertName=${expertName.trim()}, '
            'timestampFields=lastMessageAt,createdAt,updatedAt(serverTimestamp), '
            'fields=chatId,userId,expertId,expertRole,userName,expertName,'
            'participantIds,lastMessage,lastMessageId,lastMessageAt,createdAt,'
            'updatedAt,status.',
            name: _logName,
          );
        }

        operation = 'transaction create chat (commit)';
        final now = FieldValue.serverTimestamp();
        transaction.set(chatReference, {
          'chatId': chatId,
          'userId': userId,
          'expertId': expertId,
          'expertRole': normalizedRole,
          'userName': userName,
          'expertName': expertName.trim(),
          'participantIds': [userId, expertId],
          'lastMessage': '',
          'lastMessageId': '',
          'lastMessageAt': now,
          'createdAt': now,
          'updatedAt': now,
          'status': 'active',
        });
      });

      operation = 'get chat after transaction';
      documentPath = chatReference.path;
      final refreshed = await chatReference.get();
      return SupportChat.fromDocument(refreshed);
    } on FirebaseException catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Chat open failed: operation=$operation, path=$documentPath, '
          'authUid=$userId, expertUid=$expertId, chatId=$chatId, '
          'expertRole=$normalizedRole, code=${error.code}.',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }

  Stream<List<SupportChat>> watchUserChats() {
    final userId = currentUserId;
    return _firestore
        .collection('support_chats')
        .where('userId', isEqualTo: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(SupportChat.fromDocument).toList(),
        );
  }

  Stream<List<SupportChat>> watchExpertChats({
    required String expertId,
    required String expertRole,
  }) {
    if (expertId != currentUserId) {
      throw StateError('You can only view chats assigned to your account.');
    }
    final normalizedRole = ExpertProfile.normalizeRole(expertRole);
    if (!ExpertProfile.isSupportedExpertRole(normalizedRole)) {
      throw StateError('Only coaches and therapists have a chat inbox.');
    }
    return _firestore
        .collection('support_chats')
        .where('expertId', isEqualTo: expertId)
        .where('expertRole', isEqualTo: normalizedRole)
        .snapshots()
        .map((snapshot) {
          final chats = snapshot.docs.map(SupportChat.fromDocument).toList()
            ..sort((first, second) {
              final firstDate = first.lastMessageAt ?? first.createdAt;
              final secondDate = second.lastMessageAt ?? second.createdAt;
              if (firstDate == null) return 1;
              if (secondDate == null) return -1;
              return secondDate.compareTo(firstDate);
            });
          return chats;
        });
  }

  Stream<List<SupportMessage>> watchMessages(String chatId) {
    return _firestore
        .collection('support_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(SupportMessage.fromDocument).toList(),
        );
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length > 2000) {
      throw ArgumentError(
        'Your message must be between 1 and 2000 characters.',
      );
    }

    final senderId = currentUserId;
    final messageReference = _firestore
        .collection('support_chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    final chatReference = _firestore.collection('support_chats').doc(chatId);

    await _firestore.runTransaction((transaction) async {
      final chatDoc = await transaction.get(chatReference);
      if (!chatDoc.exists) {
        throw StateError('Conversation not found.');
      }
      final payload = {
        'senderId': senderId,
        'text': trimmed,
        'createdAt': FieldValue.serverTimestamp(),
        'readAt': null,
      };
      transaction.set(messageReference, payload);
      transaction.update(chatReference, {
        'lastMessage': trimmed,
        'lastMessageId': messageReference.id,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });
    });
  }

  Future<void> markConversationRead(String chatId) async {
    final currentUserId = this.currentUserId;
    final messageQuery = await _firestore
        .collection('support_chats')
        .doc(chatId)
        .collection('messages')
        .where('readAt', isNull: true)
        .get();

    final unreadMessages = messageQuery.docs
        .where((message) => message.data()['senderId'] != currentUserId)
        .toList();
    if (unreadMessages.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    for (final message in unreadMessages) {
      batch.update(message.reference, {'readAt': FieldValue.serverTimestamp()});
    }
    await batch.commit();
  }

  String _displayName(String? profileName, String? authName, String? email) {
    for (final value in [profileName, authName]) {
      final name = value?.trim();
      if (name != null && name.isNotEmpty) return name;
    }
    final emailName = email?.split('@').first.trim();
    return emailName == null || emailName.isEmpty
        ? 'FitStart member'
        : emailName;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class SupportChat {
  const SupportChat({
    required this.id,
    required this.userId,
    required this.expertId,
    required this.expertRole,
    required this.userName,
    required this.expertName,
    required this.participantIds,
    required this.lastMessage,
    required this.status,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String expertId;
  final String expertRole;
  final String userName;
  final String expertName;
  final List<String> participantIds;
  final String lastMessage;
  final String status;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String otherParticipantId(String currentUserId) {
    if (participantIds.isEmpty) return '';
    for (final participantId in participantIds) {
      if (participantId != currentUserId) {
        return participantId;
      }
    }
    return participantIds.first;
  }

  factory SupportChat.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final participantIds =
        (data['participantIds'] as List?)?.whereType<String>().toList() ??
        <String>[];
    final lastMessageAtValue = data['lastMessageAt'];
    final createdAtValue = data['createdAt'];
    final updatedAtValue = data['updatedAt'];

    return SupportChat(
      id: document.id,
      userId: (data['userId'] as String?) ?? '',
      expertId: (data['expertId'] as String?) ?? '',
      expertRole: (data['expertRole'] as String?) ?? 'coach',
      userName: (data['userName'] as String?) ?? 'FitStart member',
      expertName: (data['expertName'] as String?) ?? 'FitStart expert',
      participantIds: participantIds,
      lastMessage: (data['lastMessage'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'active',
      lastMessageAt: lastMessageAtValue is Timestamp
          ? lastMessageAtValue.toDate()
          : null,
      createdAt: createdAtValue is Timestamp ? createdAtValue.toDate() : null,
      updatedAt: updatedAtValue is Timestamp ? updatedAtValue.toDate() : null,
    );
  }
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;
  final DateTime? readAt;

  factory SupportMessage.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final createdAtValue = data['createdAt'];
    final readAtValue = data['readAt'];

    return SupportMessage(
      id: document.id,
      senderId: (data['senderId'] as String?) ?? '',
      text: (data['text'] as String?) ?? '',
      createdAt: createdAtValue is Timestamp ? createdAtValue.toDate() : null,
      readAt: readAtValue is Timestamp ? readAtValue.toDate() : null,
    );
  }
}

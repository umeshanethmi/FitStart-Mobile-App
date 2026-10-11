import 'package:cloud_firestore/cloud_firestore.dart';

class SupportRequest {
  const SupportRequest({
    required this.id,
    required this.userId,
    required this.expertId,
    required this.userName,
    required this.expertName,
    required this.specialization,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.lastMessage,
    required this.activityAt,
  });

  final String id;
  final String userId;
  final String expertId;
  final String userName;
  final String expertName;
  final String specialization;
  final String message;
  final String status;
  final DateTime? createdAt;
  final String lastMessage;
  final DateTime? activityAt;

  factory SupportRequest.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final createdAt = data['createdAt'];
    final activityAt = data['lastActivityAt'] ?? data['updatedAt'] ?? createdAt;
    final pathSegments = document.reference.path.split('/');
    final pathUserId = pathSegments.length >= 4 ? pathSegments[1] : '';

    return SupportRequest(
      id: document.id,
      userId: (data['userId'] as String?) ?? pathUserId,
      expertId: (data['expertId'] as String?) ?? '',
      userName:
          (data['userName'] as String?) ??
          (data['name'] as String?) ??
          'FitStart member',
      expertName: data['expertName'] as String? ?? 'FitStart support',
      specialization: data['specialization'] as String? ?? '',
      message: data['message'] as String? ?? '',
      status: data['status'] as String? ?? 'submitted',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : createdAt is DateTime
          ? createdAt
          : null,
      lastMessage: (data['lastMessage'] as String?) ?? '',
      activityAt: activityAt is Timestamp
          ? activityAt.toDate()
          : activityAt is DateTime
          ? activityAt
          : null,
    );
  }
}

class SupportRequestReply {
  const SupportRequestReply({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String senderRole;
  final String text;
  final DateTime? createdAt;

  factory SupportRequestReply.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final createdAt = data['createdAt'];
    return SupportRequestReply(
      id: document.id,
      senderId: (data['senderId'] as String?) ?? '',
      senderRole: (data['senderRole'] as String?) ?? 'user',
      text: (data['text'] as String?) ?? '',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : createdAt is DateTime
          ? createdAt
          : null,
    );
  }
}

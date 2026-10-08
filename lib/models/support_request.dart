import 'package:cloud_firestore/cloud_firestore.dart';

class SupportRequest {
  const SupportRequest({
    required this.id,
    required this.expertName,
    required this.specialization,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String expertName;
  final String specialization;
  final String message;
  final String status;
  final DateTime? createdAt;

  factory SupportRequest.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    final createdAt = data['createdAt'];

    return SupportRequest(
      id: document.id,
      expertName: data['expertName'] as String? ?? 'FitStart support',
      specialization: data['specialization'] as String? ?? '',
      message: data['message'] as String? ?? '',
      status: data['status'] as String? ?? 'submitted',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : createdAt is DateTime
          ? createdAt
          : null,
    );
  }
}

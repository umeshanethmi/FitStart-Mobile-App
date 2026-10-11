import 'package:cloud_firestore/cloud_firestore.dart';

class ExpertProfile {
  const ExpertProfile({
    required this.uid,
    required this.name,
    required this.role,
    required this.specialization,
    required this.bio,
    required this.photoUrl,
    required this.experience,
    this.isAvailable,
    required this.isApproved,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String name;
  final String role;
  final String specialization;
  final String bio;
  final String photoUrl;
  final int experience;
  final bool? isAvailable;
  final bool isApproved;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayRole {
    switch (role) {
      case 'coach':
        return 'Fitness Coach';
      case 'therapist':
        return 'Therapist';
      case 'admin':
        return 'Administrator';
      default:
        return 'Expert';
    }
  }

  String get availabilityText => switch (isAvailable) {
    true => 'Available',
    false => 'Unavailable',
    null => 'Not set',
  };

  factory ExpertProfile.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return ExpertProfile.fromMap({
      ...data,
      'uid': document.id,
    }, documentId: document.id);
  }

  factory ExpertProfile.fromMap(
    Map<String, dynamic> data, {
    String documentId = '',
  }) {
    final createdAtValue = data['createdAt'];
    final updatedAtValue = data['updatedAt'];

    return ExpertProfile(
      uid: (data['uid'] as String?) ?? documentId,
      name: (data['name'] as String?) ?? 'FitStart Expert',
      role: normalizeRole((data['role'] as String?) ?? 'coach'),
      specialization: (data['specialization'] as String?) ?? 'General support',
      bio:
          (data['bio'] as String?) ??
          'Available to support your fitness goals.',
      photoUrl: (data['photoUrl'] as String?) ?? '',
      experience: (data['experience'] is num)
          ? (data['experience'] as num).toInt()
          : 0,
      isAvailable: data['isAvailable'] is bool ? data['isAvailable'] as bool : null,
      isApproved: data['isApproved'] == true,
      createdAt: createdAtValue is Timestamp ? createdAtValue.toDate() : null,
      updatedAt: updatedAtValue is Timestamp ? updatedAtValue.toDate() : null,
    );
  }

  factory ExpertProfile.fromUserDocument({
    required String uid,
    required Map<String, dynamic> data,
    required String? authDisplayName,
    required String? authEmail,
  }) {
    final roleValue = data['role'] is String ? data['role'] as String : '';
    final role = normalizeRole(roleValue);
    final emailName = authEmail?.split('@').first;
    final name = _firstNonEmptyString([
      data['name'],
      data['fullName'],
      data['displayName'],
    ]);
    final createdAtValue = data['createdAt'];
    final updatedAtValue = data['updatedAt'];
    final experienceValue = data['experience'];
    final specialization = _firstNonEmptyString([
      data['specialization'],
      data['speciality'],
      data['expertise'],
    ]);
    final bio = _firstNonEmptyString([data['bio'], data['about']]);
    final photoUrl = _firstNonEmptyString([data['photoUrl'], data['photoURL']]);
    final available = data['isAvailable'] is bool
        ? data['isAvailable'] as bool
        : data['available'] is bool
        ? data['available'] as bool
        : null;

    return ExpertProfile(
      uid: uid,
      name:
          name ??
          (authDisplayName?.trim().isNotEmpty == true
              ? authDisplayName!.trim()
              : (emailName?.isNotEmpty == true
                    ? emailName!
                    : 'FitStart Expert')),
      role: role,
      specialization: specialization ?? 'Specialization not set',
      bio: bio ?? '',
      photoUrl: photoUrl ?? '',
      experience: experienceValue is num ? experienceValue.toInt() : 0,
      isAvailable: available,
      isApproved: data['isApproved'] == true,
      createdAt: createdAtValue is Timestamp ? createdAtValue.toDate() : null,
      updatedAt: updatedAtValue is Timestamp ? updatedAtValue.toDate() : null,
    );
  }

  static String normalizeRole(String? role) {
    final normalized = (role ?? '').trim().toLowerCase();
    switch (normalized) {
      case 'trainer':
        return 'coach';
      case 'coach':
      case 'therapist':
      case 'admin':
        return normalized;
      default:
        return normalized;
    }
  }

  static bool isSupportedExpertRole(String? role) {
    final normalized = normalizeRole(role);
    return normalized == 'coach' || normalized == 'therapist';
  }

  static String? _firstNonEmptyString(List<Object?> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'role': role,
      'specialization': specialization,
      'bio': bio,
      'photoUrl': photoUrl,
      'experience': experience,
      'isAvailable': isAvailable,
      'isApproved': isApproved,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}

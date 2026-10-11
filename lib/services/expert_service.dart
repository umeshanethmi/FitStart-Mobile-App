import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitstart_mobile_app/models/expert_profile.dart';

class ExpertService {
  ExpertService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _logName = 'fitstart.expert_directory';

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to use expert support.');
    }
    return user.uid;
  }

  Future<ExpertProfile> getCurrentExpertProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to access the expert dashboard.');
    }

    final document = await _users.doc(user.uid).get();
    final data = document.data();
    if (!document.exists || data == null) {
      throw StateError(
        'Your Firebase user record was not found at users/${user.uid}. '
        'Ask an administrator to check the account setup.',
      );
    }

    final profile = ExpertProfile.fromUserDocument(
      uid: user.uid,
      data: data,
      authDisplayName: user.displayName,
      authEmail: user.email,
    );
    if (!profile.isApproved ||
        (profile.role != 'coach' && profile.role != 'therapist')) {
      throw StateError(
        'This account does not have an approved coach or therapist role.',
      );
    }
    await _publishExpertProfile(profile);
    return profile;
  }

  Future<ExpertProfile?> getExpertProfile(String uid) async {
    if (uid.trim().isEmpty || uid != currentUserId) return null;
    final doc = await _users.doc(uid).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    final user = _auth.currentUser!;
    final profile = ExpertProfile.fromUserDocument(
      uid: uid,
      data: data,
      authDisplayName: user.displayName,
      authEmail: user.email,
    );
    if (profile.uid != uid ||
        !profile.isApproved ||
        (profile.role != 'coach' && profile.role != 'therapist')) {
      return null;
    }
    return profile;
  }

  Future<List<ExpertProfile>> getApprovedExperts({required String role}) async {
    if (role != 'coach' && role != 'therapist') {
      throw ArgumentError('Choose coach or therapist.');
    }
    if (_auth.currentUser == null) {
      throw StateError('Sign in to browse approved experts.');
    }

    developer.log(
      'Querying expert_directory for role=$role, isApproved=true.',
      name: _logName,
    );

    try {
      final snapshot = await _firestore
          .collection('expert_directory')
          .where('role', isEqualTo: role)
          .where('isApproved', isEqualTo: true)
          .orderBy('name')
          .get();
      final experts = snapshot.docs
          .map(ExpertProfile.fromDocument)
          .where(
            (profile) =>
                profile.uid.isNotEmpty &&
                profile.role == role &&
                profile.isApproved,
          )
          .toList();
      developer.log(
        'Loaded ${experts.length} approved $role profiles from '
        'expert_directory.',
        name: _logName,
      );
      return experts;
    } on FirebaseException catch (error, stackTrace) {
      developer.log(
        'Firestore expert_directory query failed: code=${error.code}, '
        'role=$role.',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected failure querying expert_directory for role=$role.',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> updateCurrentExpertProfile({
    String? name,
    String? specialization,
    String? bio,
    String? photoUrl,
    bool? isAvailable,
  }) async {
    final uid = currentUserId;
    final profileReference = _users.doc(uid);
    final current = await profileReference.get();
    final currentData = current.data();
    final normalizedRole = ExpertProfile.normalizeRole(
      currentData?['role'] as String?,
    );
    if (currentData?['isApproved'] != true ||
        !ExpertProfile.isSupportedExpertRole(normalizedRole)) {
      throw StateError('Only approved experts can update their profile.');
    }
    final data = <String, dynamic>{};
    if (name != null && name.trim().isNotEmpty) data['name'] = name.trim();
    if (specialization != null && specialization.trim().isNotEmpty) {
      data['specialization'] = specialization.trim();
    }
    if (bio != null) data['bio'] = bio.trim();
    if (photoUrl != null) data['photoUrl'] = photoUrl.trim();
    if (isAvailable != null) data['isAvailable'] = isAvailable;
    data['updatedAt'] = FieldValue.serverTimestamp();
    await profileReference.set(data, SetOptions(merge: true));
    final refreshed = await profileReference.get();
    final refreshedData = refreshed.data();
    if (refreshedData == null) {
      throw StateError(
        'The expert profile could not be reloaded after saving.',
      );
    }
    await _publishExpertProfile(
      ExpertProfile.fromUserDocument(
        uid: uid,
        data: refreshedData,
        authDisplayName: _auth.currentUser?.displayName,
        authEmail: _auth.currentUser?.email,
      ),
    );
  }

  Future<void> _publishExpertProfile(ExpertProfile profile) async {
    final normalizedRole = ExpertProfile.normalizeRole(profile.role);
    if (!profile.isApproved ||
        !ExpertProfile.isSupportedExpertRole(normalizedRole)) {
      throw StateError('Only approved coaches and therapists are public.');
    }
    await _firestore.collection('expert_directory').doc(profile.uid).set({
      'name': profile.name,
      'role': normalizedRole,
      'specialization': profile.specialization,
      'bio': profile.bio,
      'photoUrl': profile.photoUrl,
      'experience': profile.experience,
      'isAvailable': profile.isAvailable,
      'isApproved': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> ensureUserProfile(
    String uid,
    Map<String, dynamic> profileData,
  ) async {
    final userReference = _users.doc(uid);
    final userDoc = await userReference.get();
    if (!userDoc.exists) {
      await userReference.set({
        'uid': uid,
        'email': profileData['email'] ?? '',
        'name': profileData['name'] ?? 'User',
        'role': profileData['role'] ?? 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await userReference.set({
      'uid': uid,
      'email': profileData['email'] ?? userDoc.data()?['email'] ?? '',
      'name': profileData['name'] ?? userDoc.data()?['name'] ?? 'User',
      'role': profileData['role'] ?? userDoc.data()?['role'] ?? 'user',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    final doc = await _users.doc(currentUserId).get();
    return doc.data() ?? const <String, dynamic>{};
  }

  Future<void> setUserRole({required String uid, required String role}) async {
    final currentUid = currentUserId;
    final currentDoc = await _users.doc(currentUid).get();
    final currentRole = (currentDoc.data()?['role'] as String?) ?? 'user';
    if (currentRole != 'admin') {
      throw StateError('Only administrators can assign expert roles.');
    }
    if (!['user', 'coach', 'therapist'].contains(role)) {
      throw ArgumentError('Unsupported user role.');
    }
    await _users.doc(uid).set({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

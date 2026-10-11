import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/models/expert_profile.dart';

void main() {
  group('ExpertProfile.fromUserDocument', () {
    test('maps an approved coach document using its Firebase UID', () {
      final profile = ExpertProfile.fromUserDocument(
        uid: 'auth-uid-123',
        data: {
          'role': 'coach',
          'isApproved': true,
          'name': 'Coach Example',
          'specialization': 'Strength training',
          'isAvailable': true,
        },
        authDisplayName: null,
        authEmail: 'coach@example.com',
      );

      expect(profile.uid, 'auth-uid-123');
      expect(profile.name, 'Coach Example');
      expect(profile.role, 'coach');
      expect(profile.isApproved, isTrue);
      expect(profile.specialization, 'Strength training');
      expect(profile.availabilityText, 'Available');
    });

    test('does not infer approval or availability when fields are missing', () {
      final profile = ExpertProfile.fromUserDocument(
        uid: 'auth-uid-456',
        data: {'role': 'therapist'},
        authDisplayName: null,
        authEmail: 'therapist@example.com',
      );

      expect(profile.name, 'therapist');
      expect(profile.role, 'therapist');
      expect(profile.isApproved, isFalse);
      expect(profile.isAvailable, isNull);
      expect(profile.availabilityText, 'Not set');
    });

    test('maps existing public-profile aliases without exposing user data', () {
      final profile = ExpertProfile.fromUserDocument(
        uid: 'firebase-auth-uid',
        data: {
          'role': 'Trainer',
          'isApproved': true,
          'fullName': 'Coach Alias',
          'expertise': 'Mobility',
          'about': 'Movement coaching',
          'photoURL': 'https://example.invalid/profile.png',
          'available': false,
          'email': 'private@example.com',
        },
        authDisplayName: null,
        authEmail: null,
      );

      expect(profile.uid, 'firebase-auth-uid');
      expect(profile.name, 'Coach Alias');
      expect(profile.role, 'coach');
      expect(profile.specialization, 'Mobility');
      expect(profile.bio, 'Movement coaching');
      expect(profile.photoUrl, 'https://example.invalid/profile.png');
      expect(profile.isAvailable, isFalse);
      expect(profile.isApproved, isTrue);
    });
  });
}

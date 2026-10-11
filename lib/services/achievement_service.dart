import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitstart_mobile_app/models/achievement.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';

class AchievementService {
  AchievementService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to access achievements.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _records =>
      _firestore.collection('users').doc(_userId).collection('achievements');

  Stream<List<AchievementRecord>> watchUnlockedAchievements() async* {
    await for (final snapshot in _records.snapshots()) {
      final records = snapshot.docs
          .map(
            (document) =>
                AchievementRecord.fromMap(document.id, document.data()),
          )
          .toList();
      records.sort((first, second) {
        final firstDate = first.earnedAt;
        final secondDate = second.earnedAt;
        if (firstDate == null) return 1;
        if (secondDate == null) return -1;
        return secondDate.compareTo(firstDate);
      });
      yield records;
    }
  }

  Future<List<String>> synchronize(Iterable<WorkoutSession> workouts) {
    final progress = AchievementProgress(workouts);
    final earnedNow = <String>[];
    final references = AchievementCatalog.definitions
        .where((definition) => definition.progressFor(progress) >= 1)
        .map((definition) => _records.doc(definition.id))
        .toList(growable: false);

    return _firestore.runTransaction((transaction) async {
      final existing = <DocumentReference<Map<String, dynamic>>, bool>{};
      for (final reference in references) {
        existing[reference] = (await transaction.get(reference)).exists;
      }

      for (final entry in existing.entries) {
        if (entry.value) continue;
        final definition = AchievementCatalog.byId(entry.key.id)!;
        transaction.set(entry.key, {
          'achievementId': definition.id,
          'rewardPoints': definition.points,
          'earnedAt': FieldValue.serverTimestamp(),
          'progressAtUnlock': definition.progressValue(progress),
        });
        earnedNow.add(definition.id);
      }
      return earnedNow;
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to access workouts.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _workoutPlans {
    return _db.collection('workout_plans');
  }

  Stream<List<WorkoutSession>> watchWorkouts() async* {
    final uid = _uid;
    final userPlans = _workoutPlans.where('userId', isEqualTo: uid);
    await for (final snapshot in userPlans.snapshots()) {
      final records =
          snapshot.docs.map((document) {
            final data = document.data();
            for (final dateField in [
              'startedAt',
              'weekStart',
              'completedAt',
              'createdAt',
              'updatedAt',
            ]) {
              final dateValue = data[dateField];
              if (dateValue is Timestamp) {
                data[dateField] = dateValue.toDate();
              }
            }
            return WorkoutSession.fromMap(document.id, data);
          }).toList()..sort((first, second) {
            final firstDate =
                first.completedAt ??
                first.startedAt ??
                first.createdAt ??
                first.weekStart;
            final secondDate =
                second.completedAt ??
                second.startedAt ??
                second.createdAt ??
                second.weekStart;
            if (firstDate != null && secondDate != null) {
              final chronology = secondDate.compareTo(firstDate);
              if (chronology != 0) return chronology;
            }
            final dayOrder = second.dayIndex.compareTo(first.dayIndex);
            return dayOrder != 0 ? dayOrder : first.name.compareTo(second.name);
          });
      yield records;
    }
  }

  // 1. Create or Update a User Profile (Called after Registration)
  Future<void> createUserProfile(
    String uid,
    Map<String, dynamic> profileData,
  ) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .set(profileData, SetOptions(merge: true));
    } catch (e) {
      print("Error creating user profile: $e");
      rethrow;
    }
  }

  // 2. Fetch User Profile
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // 3. Rule-Based Algorithm: Generate Initial Workout Plan
  Future<void> generateRuleBasedPlan(String uid, String goal) async {
    List<Map<String, dynamic>> selectedExercises = [];

    // Simple rule-based logic (can be expanded massively)
    if (goal == "Lose Weight") {
      selectedExercises = [
        {"exerciseId": "jump_rope", "sets": 3, "reps": 50, "restSeconds": 30},
        {"exerciseId": "burpees", "sets": 3, "reps": 15, "restSeconds": 45},
      ];
    } else if (goal == "Build Muscle") {
      selectedExercises = [
        {"exerciseId": "squat", "sets": 4, "reps": 8, "restSeconds": 90},
        {"exerciseId": "bench_press", "sets": 4, "reps": 8, "restSeconds": 90},
      ];
    } else {
      // Stay Fit
      selectedExercises = [
        {"exerciseId": "pushups", "sets": 3, "reps": 15, "restSeconds": 60},
        {
          "exerciseId": "plank",
          "sets": 3,
          "reps": 1,
          "restSeconds": 60,
        }, // reps = minutes
      ];
    }

    final newPlan = {
      "userId": uid,
      "title": "$goal Starter Plan",
      "isActive": true,
      "exercises": selectedExercises,
      "createdAt": FieldValue.serverTimestamp(),
    };

    await _workoutPlans.add(newPlan);
  }
}

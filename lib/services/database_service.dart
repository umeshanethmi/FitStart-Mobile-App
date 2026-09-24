import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Create or Update a User Profile (Called after Registration)
  Future<void> createUserProfile(String uid, Map<String, dynamic> profileData) async {
    try {
      await _db.collection('users').doc(uid).set(profileData, SetOptions(merge: true));
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
        {"exerciseId": "plank", "sets": 3, "reps": 1, "restSeconds": 60}, // reps = minutes
      ];
    }

    final newPlan = {
      "userId": uid,
      "title": "$goal Starter Plan",
      "isActive": true,
      "exercises": selectedExercises,
      "createdAt": FieldValue.serverTimestamp(),
    };

    await _db.collection('workout_plans').add(newPlan);
  }
}

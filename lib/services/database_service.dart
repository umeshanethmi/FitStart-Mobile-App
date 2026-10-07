import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitstart_mobile_app/services/workout_plan_generator.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';
import 'package:fitstart_mobile_app/models/scheduled_workout.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  Stream<List<WorkoutPlan>> watchWorkoutPlans(String uid) {
    if (uid.trim().isEmpty) throw ArgumentError('A user ID is required.');
    return _db
        .collection('workout_plans')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => WorkoutPlan.fromMap(document.id, document.data()),
              )
              .toList(),
        );
  }

  Stream<List<ScheduledWorkout>> watchScheduledWorkouts(String uid) {
    if (uid.trim().isEmpty) throw ArgumentError('A user ID is required.');
    return _db
        .collection('workout_schedules')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final workouts = snapshot.docs
              .map(
                (document) =>
                    ScheduledWorkout.fromMap(document.id, document.data()),
              )
              .toList();
          workouts.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
          return workouts;
        });
  }

  Future<void> scheduleWorkout({
    required String uid,
    required String planId,
    required DateTime scheduledAt,
  }) async {
    if (uid.trim().isEmpty ||
        planId.trim().isEmpty ||
        !scheduledAt.isAfter(DateTime.now())) {
      throw ArgumentError('Choose a future workout date and time.');
    }
    final planReference = _db.collection('workout_plans').doc(planId);
    final scheduleReference = _db.collection('workout_schedules').doc();
    await _db.runTransaction((transaction) async {
      final plan = (await transaction.get(planReference)).data();
      if (plan == null || plan['userId'] != uid) {
        throw StateError('This workout plan is no longer available.');
      }
      transaction.set(scheduleReference, {
        'userId': uid,
        'planId': planId,
        'title': plan['title'] ?? 'Workout',
        'exercises': plan['exercises'] ?? [],
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> rescheduleWorkout({
    required String uid,
    required String scheduleId,
    required DateTime scheduledAt,
  }) async {
    if (uid.trim().isEmpty ||
        scheduleId.trim().isEmpty ||
        !scheduledAt.isAfter(DateTime.now())) {
      throw ArgumentError('Choose a future workout date and time.');
    }
    final reference = _db.collection('workout_schedules').doc(scheduleId);
    await _db.runTransaction((transaction) async {
      final workout = (await transaction.get(reference)).data();
      if (workout == null || workout['userId'] != uid) {
        throw StateError('This scheduled workout is no longer available.');
      }
      transaction.update(reference, {
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> setWorkoutReminder({
    required String uid,
    required String scheduleId,
    required int minutesBefore,
    required bool enabled,
  }) async {
    if (uid.trim().isEmpty ||
        scheduleId.trim().isEmpty ||
        ![0, 5, 10, 15, 30, 60].contains(minutesBefore)) {
      throw ArgumentError('Invalid reminder settings.');
    }
    final reference = _db.collection('workout_schedules').doc(scheduleId);
    await _db.runTransaction((transaction) async {
      final data = (await transaction.get(reference)).data();
      if (data == null || data['userId'] != uid) {
        throw StateError('This scheduled workout is no longer available.');
      }
      final date = (data['scheduledAt'] as Timestamp).toDate();
      if (enabled &&
          !date
              .subtract(Duration(minutes: minutesBefore))
              .isAfter(DateTime.now())) {
        throw StateError(
          'This reminder time has already passed. Choose a shorter lead time or reschedule the workout.',
        );
      }
      transaction.update(reference, {
        'reminder': {'minutesBefore': minutesBefore, 'enabled': enabled},
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> deleteWorkoutReminder({
    required String uid,
    required String scheduleId,
  }) async {
    if (uid.trim().isEmpty || scheduleId.trim().isEmpty) {
      throw ArgumentError('A user ID and schedule ID are required.');
    }
    final reference = _db.collection('workout_schedules').doc(scheduleId);
    await _db.runTransaction((transaction) async {
      final data = (await transaction.get(reference)).data();
      if (data == null || data['userId'] != uid) {
        throw StateError('This scheduled workout is no longer available.');
      }
      transaction.update(reference, {
        'reminder': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> deleteScheduledWorkout({
    required String uid,
    required String scheduleId,
  }) async {
    if (uid.trim().isEmpty || scheduleId.trim().isEmpty) {
      throw ArgumentError('A user ID and schedule ID are required.');
    }
    final reference = _db.collection('workout_schedules').doc(scheduleId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) return;
      if (snapshot.data()?['userId'] != uid) {
        throw StateError('You cannot delete this scheduled workout.');
      }
      transaction.delete(reference);
    });
  }

  Future<void> deleteWorkoutPlan({
    required String uid,
    required String planId,
  }) async {
    if (uid.trim().isEmpty || planId.trim().isEmpty) {
      throw ArgumentError('A user ID and plan ID are required.');
    }
    final reference = _db.collection('workout_plans').doc(planId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) return;
      if (snapshot.data()?['userId'] != uid) {
        throw StateError('You cannot delete this workout plan.');
      }
      transaction.delete(reference);
    });
  }

  Future<void> updatePlanExercise({
    required String uid,
    required String planId,
    required int exerciseIndex,
    required String exerciseId,
    required int sets,
    required int reps,
    required int restSeconds,
  }) async {
    if (uid.trim().isEmpty ||
        planId.trim().isEmpty ||
        sets < 1 ||
        sets > 10 ||
        reps < 1 ||
        reps > 200 ||
        restSeconds < 0 ||
        restSeconds > 600) {
      throw ArgumentError('Invalid exercise values.');
    }
    final reference = _db.collection('workout_plans').doc(planId);
    // Read the current array so edits to other exercises are preserved.
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final data = snapshot.data();
      if (data == null || data['userId'] != uid) {
        throw StateError('This plan is no longer available.');
      }
      final exercises = (data['exercises'] as List? ?? [])
          .map((exercise) => Map<String, dynamic>.from(exercise as Map))
          .toList();
      if (exerciseIndex < 0 ||
          exerciseIndex >= exercises.length ||
          exercises[exerciseIndex]['exerciseId'] != exerciseId) {
        throw StateError('The exercise has changed. Reopen the plan.');
      }
      exercises[exerciseIndex].addAll({
        'sets': sets,
        'reps': reps,
        'restSeconds': restSeconds,
      });
      transaction.update(reference, {
        'exercises': exercises,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // 3. Rule-Based Algorithm: Generate Initial Workout Plan
  Future<String> generateRuleBasedPlan(
    String uid,
    String goal, {
    String experience = 'Beginner',
    String equipment = 'None',
    int daysPerWeek = 3,
    int durationMinutes = 30,
  }) async {
    if (uid.trim().isEmpty) throw ArgumentError('A user ID is required.');
    final newPlan = WorkoutPlanGenerator().generate(
      goal: goal,
      experience: experience,
      equipment: equipment,
      daysPerWeek: daysPerWeek,
      durationMinutes: durationMinutes,
    );
    newPlan['userId'] = uid;
    newPlan['createdAt'] = FieldValue.serverTimestamp();
    final document = await _db.collection('workout_plans').add(newPlan);
    return document.id;
  }
}

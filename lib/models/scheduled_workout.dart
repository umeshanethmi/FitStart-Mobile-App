import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduledWorkout {
  final String id;
  final String planId;
  final String title;
  final DateTime scheduledAt;
  final List<Map<String, dynamic>> exercises;
  final Map<String, dynamic> preferences;
  final int? reminderMinutes;
  final bool reminderEnabled;

  DateTime? get reminderAt => reminderMinutes == null
      ? null
      : scheduledAt.subtract(Duration(minutes: reminderMinutes!));

  ScheduledWorkout.fromMap(this.id, Map<String, dynamic> data)
    : planId = data['planId'] as String,
      title = data['title'] as String? ?? 'Workout',
      scheduledAt = (data['scheduledAt'] as Timestamp).toDate().toLocal(),
      reminderMinutes = (data['reminder'] as Map?)?['minutesBefore'] as int?,
      reminderEnabled = (data['reminder'] as Map?)?['enabled'] == true,
      preferences = Map<String, dynamic>.from(
        data['preferences'] as Map? ?? {},
      ),
      exercises = (data['exercises'] as List? ?? [])
          .map((exercise) => Map<String, dynamic>.from(exercise as Map))
          .toList();
}

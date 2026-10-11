import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fitstart_mobile_app/models/scheduled_workout.dart';
import 'package:fitstart_mobile_app/services/database_service.dart';

import 'notifications/notification_backend.dart';
import 'notifications/notification_backend_mobile.dart'
    if (dart.library.js_interop) 'notifications/notification_backend_web.dart'
    as platform;

class ReminderNotificationService {
  static final instance = ReminderNotificationService();
  final NotificationBackend _backend;
  final error = ValueNotifier<String?>(null);
  StreamSubscription<User?>? _auth;
  StreamSubscription<List<ScheduledWorkout>>? _workouts;
  Future<void> _queue = Future.value();
  int _generation = 0;

  ReminderNotificationService({NotificationBackend? backend})
    : _backend = backend ?? platform.createNotificationBackend();

  Future<void> requestPermission() async {
    if (!await _backend.requestPermission()) {
      throw StateError(
        'Notifications are blocked. Allow them in your device or browser settings, then try again.',
      );
    }
  }

  static List<WorkoutNotification> notificationsFor(
    List<ScheduledWorkout> workouts,
    DateTime now,
  ) {
    final notifications = <WorkoutNotification>[];
    for (final workout in workouts) {
      final date = workout.reminderAt;
      if (!workout.reminderEnabled || date == null || !date.isAfter(now)) {
        continue;
      }
      notifications.add(
        WorkoutNotification(
          id: workout.id,
          title: 'FitStart: ${workout.title}',
          date: date,
          body: workout.reminderMinutes == 0
              ? 'Your workout starts now.'
              : 'Your workout starts in ${workout.reminderMinutes} minutes.',
        ),
      );
    }
    notifications.sort((a, b) => a.date.compareTo(b.date));
    return notifications;
  }

  Future<void> synchronize(List<ScheduledWorkout> workouts) {
    final operation = _queue.then((_) => _replace(workouts));
    _queue = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> _replace(List<ScheduledWorkout> workouts) async {
    final notifications = notificationsFor(workouts, DateTime.now());
    await _backend.replace(notifications.take(64).toList());
    error.value = notifications.length > 64
        ? 'Only the next 64 reminders can be scheduled on this device.'
        : null;
  }

  void _enqueue(List<ScheduledWorkout> workouts, int generation) {
    _queue = _queue.then((_) async {
      if (generation != _generation) return;
      try {
        await _replace(workouts);
      } catch (failure) {
        error.value = failure is StateError ? failure.message.toString() : 'Reminders are saved, but notifications could not be scheduled on this device. Reopen Reminders and retry.';
      }
    });
  }

  void start() {
    if (_auth != null) return;
    _auth = FirebaseAuth.instance.authStateChanges().listen((user) async {
      final generation = ++_generation;
      await _workouts?.cancel();
      if (generation != _generation) return;
      _enqueue([], generation);
      if (user != null) {
        _workouts = DatabaseService()
            .watchScheduledWorkouts(user.uid)
            .listen(
              (workouts) => _enqueue(workouts, generation),
              onError: (Object _) => error.value = 'Could not load reminders. Check your connection and schedule permissions.',
            );
      }
    });
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/scheduled_workout.dart';
import 'package:fitstart_mobile_app/screens/workout_schedule_screen.dart';
import 'package:fitstart_mobile_app/services/database_service.dart';
import 'package:fitstart_mobile_app/services/reminder_notification_service.dart';
import 'package:fitstart_mobile_app/widgets/workout_reminder_dialog.dart';

class RemindersScreen extends StatefulWidget {
  final String? scheduleId;
  const RemindersScreen({super.key, this.scheduleId});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _database = DatabaseService();
  final _notifications = ReminderNotificationService.instance;
  late final _authChanges = FirebaseAuth.instance.authStateChanges();
  final _busy = <String>{};
  Stream<List<ScheduledWorkout>>? _workouts;
  String? _uid;
  bool _retrying = false;

  Future<void> _edit(String uid, ScheduledWorkout workout) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WorkoutReminderDialog(
        title: workout.title,
        scheduledAt: workout.scheduledAt,
        minutesBefore: workout.reminderMinutes,
        enabled: workout.reminderMinutes == null || workout.reminderEnabled,
        onSave: (minutes, enabled) async {
          if (enabled) await _notifications.requestPermission();
          await _database.setWorkoutReminder(
            uid: uid,
            scheduleId: workout.id,
            minutesBefore: minutes,
            enabled: enabled,
          );
        },
      ),
    );
  }

  Future<void> _perform(String id, Future<void> Function() action) async {
    if (_busy.contains(id)) return;
    setState(() => _busy.add(id));
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is StateError
                  ? error.message.toString()
                  : error is FirebaseException &&
                        error.code == 'permission-denied'
                  ? 'Your account does not have permission to update workout reminders.'
                  : 'Could not update the reminder. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  Future<void> _delete(String uid, ScheduledWorkout workout) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: Text(
          'Remove the reminder for "${workout.title}"? Your scheduled workout will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await _perform(
        workout.id,
        () => _database.deleteWorkoutReminder(uid: uid, scheduleId: workout.id),
      );
    }
  }

  Future<void> _retry(List<ScheduledWorkout> workouts) async {
    setState(() => _retrying = true);
    try {
      await _notifications.requestPermission();
      await _notifications.synchronize(workouts);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is StateError
                  ? error.message.toString()
                  : 'Could not schedule notifications. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: _authChanges,
          initialData: FirebaseAuth.instance.currentUser,
          builder: (context, auth) {
            final user = auth.data;
            if (user == null) {
              return const Center(
                child: Text('Please sign in to manage reminders.'),
              );
            }
            if (_uid != user.uid) {
              _uid = user.uid;
              _workouts = _database.watchScheduledWorkouts(user.uid);
            }
            return StreamBuilder<List<ScheduledWorkout>>(
              key: ValueKey(user.uid),
              stream: _workouts,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            snapshot.error is FirebaseException &&
                                    (snapshot.error as FirebaseException)
                                            .code ==
                                        'permission-denied'
                                ? 'Your account does not have permission to read workout reminders.'
                                : 'Could not load reminders. Please try again.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => setState(
                              () => _workouts = _database
                                  .watchScheduledWorkouts(user.uid),
                            ),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snapshot.data!;
                final workouts = all
                    .where(
                      (workout) =>
                          widget.scheduleId == null ||
                          workout.id == widget.scheduleId,
                    )
                    .toList();
                if (workouts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No scheduled workouts.'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const WorkoutScheduleScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Workout Schedule'),
                        ),
                      ],
                    ),
                  );
                }
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (kIsWeb)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Browser reminders require this tab to stay open.',
                            ),
                          ),
                        ValueListenableBuilder<String?>(
                          valueListenable: _notifications.error,
                          builder: (context, error, _) => error == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        error,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: _retrying
                                            ? null
                                            : () => _retry(all),
                                        icon: const Icon(
                                          Icons.notifications_active_outlined,
                                        ),
                                        label: Text(
                                          _retrying
                                              ? 'Retrying...'
                                              : 'Retry Notifications',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        for (final workout in workouts) ...[
                          WorkoutReminderTile(
                            workout: workout,
                            busy: _busy.contains(workout.id),
                            onEdit: () => _edit(user.uid, workout),
                            onDelete: () => _delete(user.uid, workout),
                            onToggle: (enabled) =>
                                _perform(workout.id, () async {
                                  if (enabled) {
                                    await _notifications.requestPermission();
                                  }
                                  await _database.setWorkoutReminder(
                                    uid: user.uid,
                                    scheduleId: workout.id,
                                    minutesBefore: workout.reminderMinutes!,
                                    enabled: enabled,
                                  );
                                }),
                          ),
                          const Divider(),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class WorkoutReminderTile extends StatelessWidget {
  final ScheduledWorkout workout;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;
  const WorkoutReminderTile({
    super.key,
    required this.workout,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(workout.scheduledAt);
    final time = TimeOfDay.fromDateTime(workout.scheduledAt).format(context);
    final reminder = workout.reminderMinutes;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(workout.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('$date | $time'),
          const SizedBox(height: 8),
          Text(
            reminder == null
                ? 'No reminder'
                : !workout.reminderEnabled
                ? 'Reminder disabled'
                : workout.reminderAt!.isBefore(DateTime.now())
                ? 'Reminder time passed'
                : reminder == 0
                ? 'Reminder at workout time'
                : 'Reminder $reminder minutes before',
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              if (reminder != null)
                Switch(
                  value: workout.reminderEnabled,
                  onChanged: busy ? null : onToggle,
                ),
              IconButton(
                tooltip: reminder == null ? 'Add reminder' : 'Edit reminder',
                onPressed: busy ? null : onEdit,
                icon: Icon(
                  reminder == null
                      ? Icons.notification_add_outlined
                      : Icons.edit_outlined,
                ),
              ),
              if (reminder != null)
                IconButton(
                  tooltip: 'Delete reminder',
                  onPressed: busy ? null : onDelete,
                  color: Theme.of(context).colorScheme.error,
                  icon: const Icon(Icons.delete_outline),
                ),
              if (busy)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

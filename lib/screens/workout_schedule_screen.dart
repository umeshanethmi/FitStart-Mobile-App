import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/scheduled_workout.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';
import 'package:fitstart_mobile_app/screens/ai_workout_plan_screen.dart';
import 'package:fitstart_mobile_app/services/database_service.dart';
import 'package:fitstart_mobile_app/widgets/delete_workout_plan_dialog.dart';
import 'package:fitstart_mobile_app/widgets/schedule_workout_dialog.dart';
import 'package:fitstart_mobile_app/screens/reminders_screen.dart';
import 'package:fitstart_mobile_app/services/workout_completion_service.dart';
import 'package:fitstart_mobile_app/widgets/workout_page.dart';
import 'package:fitstart_mobile_app/models/training_workout_plan.dart';
import 'package:fitstart_mobile_app/screens/daily_workout_plan_screen.dart';

class WorkoutScheduleScreen extends StatefulWidget {
  const WorkoutScheduleScreen({super.key});

  @override
  State<WorkoutScheduleScreen> createState() => _WorkoutScheduleScreenState();
}

class _WorkoutScheduleScreenState extends State<WorkoutScheduleScreen> {
  final _database = DatabaseService();
  late final _authChanges = FirebaseAuth.instance.authStateChanges();
  Stream<List<ScheduledWorkout>>? _workouts;
  String? _uid;

  String _loadError(Object? error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Your account does not have permission to read workout schedules.';
        case 'unauthenticated':
          return 'Your session has expired. Please sign in again.';
        case 'unavailable':
          return 'The schedule service is unavailable. Check your connection and retry.';
        default:
          return 'Could not load your schedule (${error.code}). Please retry.';
      }
    }
    return 'A saved workout could not be loaded. Please check its saved date, time, and plan details.';
  }

  void _openPlans() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AiWorkoutPlanScreen()));
  }

  Future<void> _reschedule(String uid, ScheduledWorkout workout) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScheduleWorkoutDialog(
        title: workout.title,
        initialDate: workout.scheduledAt,
        onSave: (date) => _database.rescheduleWorkout(
          uid: uid,
          scheduleId: workout.id,
          scheduledAt: date,
        ),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Workout rescheduled.')));
    }
  }

  Future<void> _delete(String uid, ScheduledWorkout workout) async {
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteWorkoutPlanDialog(
        title: workout.title,
        scheduledWorkout: true,
        onDelete: () =>
            _database.deleteScheduledWorkout(uid: uid, scheduleId: workout.id),
      ),
    );
    if (deleted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scheduled workout deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WorkoutPage(
      title: 'Workout Schedule',
      planningStyle: true,
      actions: [
        IconButton(
          tooltip: 'Schedule a workout',
          onPressed: _openPlans,
          icon: const Icon(Icons.add),
        ),
      ],
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: _authChanges,
          initialData: FirebaseAuth.instance.currentUser,
          builder: (context, auth) {
            final user = auth.data;
            if (user == null) {
              return const Center(
                child: Text('Please sign in to view your schedule.'),
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
                            _loadError(snapshot.error),
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
                final workouts = snapshot.data!;
                if (workouts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No scheduled workouts yet.'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _openPlans,
                          icon: const Icon(Icons.add),
                          label: const Text('Schedule Workout'),
                        ),
                      ],
                    ),
                  );
                }
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: workouts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, index) => ScheduledWorkoutDetails(
                        key: ValueKey(workouts[index].id),
                        workout: workouts[index],
                        onReschedule: () =>
                            _reschedule(user.uid, workouts[index]),
                        onDelete: () => _delete(user.uid, workouts[index]),
                        onReminder: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                RemindersScreen(scheduleId: workouts[index].id),
                          ),
                        ),
                        onWorkoutCompleted: (session) =>
                            WorkoutCompletionService().complete(session),
                      ),
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

class ScheduledWorkoutDetails extends StatelessWidget {
  final ScheduledWorkout workout;
  final VoidCallback onReschedule;
  final VoidCallback onDelete;
  final VoidCallback onReminder;
  final WorkoutCompletionHandler? onWorkoutCompleted;

  const ScheduledWorkoutDetails({
    super.key,
    required this.workout,
    required this.onReschedule,
    required this.onDelete,
    required this.onReminder,
    this.onWorkoutCompleted,
  });

  void _start(BuildContext context) {
    try {
      final plan = TrainingWorkoutPlan.fromScheduledWorkout(workout);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DailyWorkoutPlanScreen(
            plan: plan,
            onWorkoutCompleted: onWorkoutCompleted,
          ),
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(workout.scheduledAt);
    final time = TimeOfDay.fromDateTime(workout.scheduledAt).format(context);
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: WorkoutPage.planningLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${workout.scheduledAt.day}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: WorkoutPage.blue,
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              workout.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('$date | $time'),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Reschedule workout',
                    onPressed: onReschedule,
                    icon: const Icon(Icons.edit_calendar_outlined),
                  ),
                  IconButton(
                    tooltip: 'Workout reminder',
                    onPressed: onReminder,
                    icon: Icon(
                      workout.reminderEnabled
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_outlined,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete scheduled workout',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
              for (final exercise in workout.exercises)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(WorkoutPlan.exerciseName(exercise)),
                  subtitle: Text(
                    '${exercise['sets']} sets x ${exercise['durationSeconds'] != null ? '${exercise['durationSeconds']}s' : '${exercise['reps']} reps'} | ${exercise['restSeconds']}s rest',
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton.icon(
              onPressed: workout.exercises.isEmpty
                  ? null
                  : () => _start(context),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Workout'),
            ),
          ),
        ],
      ),
    );
  }
}

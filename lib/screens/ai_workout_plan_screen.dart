import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';
import 'package:fitstart_mobile_app/screens/create_ai_plan_screen.dart';
import 'package:fitstart_mobile_app/services/database_service.dart';
import 'package:fitstart_mobile_app/widgets/edit_plan_exercise_dialog.dart';
import 'package:fitstart_mobile_app/widgets/delete_workout_plan_dialog.dart';
import 'package:fitstart_mobile_app/widgets/schedule_workout_dialog.dart';
import 'package:fitstart_mobile_app/widgets/workout_page.dart';

class AiWorkoutPlanScreen extends StatefulWidget {
  const AiWorkoutPlanScreen({super.key});

  @override
  State<AiWorkoutPlanScreen> createState() => _AiWorkoutPlanScreenState();
}

class _AiWorkoutPlanScreenState extends State<AiWorkoutPlanScreen> {
  final _database = DatabaseService();
  late final _authChanges = FirebaseAuth.instance.authStateChanges();
  Stream<List<WorkoutPlan>>? _plans;
  String? _uid;

  Future<void> _schedule(String uid, WorkoutPlan plan) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScheduleWorkoutDialog(
        title: plan.title,
        onSave: (date) => _database.scheduleWorkout(
          uid: uid,
          planId: plan.id,
          scheduledAt: date,
        ),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Workout scheduled.')));
    }
  }

  Future<void> _delete(String uid, WorkoutPlan plan) async {
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteWorkoutPlanDialog(
        title: plan.title,
        onDelete: () => _database.deleteWorkoutPlan(uid: uid, planId: plan.id),
      ),
    );
    if (deleted == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Workout plan deleted.')));
    }
  }

  Future<void> _edit(String uid, WorkoutPlan plan, int index) async {
    final exercise = plan.exercises[index];
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditPlanExerciseDialog(
        exercise: exercise,
        onSave: (sets, reps, rest) => _database.updatePlanExercise(
          uid: uid,
          planId: plan.id,
          exerciseIndex: index,
          exerciseId: exercise['exerciseId'] as String? ?? '',
          sets: sets,
          reps: reps,
          restSeconds: rest,
        ),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Exercise updated.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WorkoutPage(
      title: 'My Workout Plans',
      planningStyle: true,
      actions: [
        IconButton(
          tooltip: 'Create Workout Plan',
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreateAiPlanScreen())),
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
                child: Text('Please sign in to view your plans.'),
              );
            }
            if (_uid != user.uid) {
              _uid = user.uid;
              _plans = _database.watchWorkoutPlans(user.uid);
            }
            return StreamBuilder<List<WorkoutPlan>>(
              key: ValueKey(user.uid),
              stream: _plans,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Could not load your plans. Check your connection and account permissions.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => setState(
                              () => _plans = _database.watchWorkoutPlans(
                                user.uid,
                              ),
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
                final plans = snapshot.data!;
                if (plans.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No workout plans yet.'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CreateAiPlanScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Workout Plan'),
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
                      itemCount: plans.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (_, index) => WorkoutPlanDetails(
                        key: ValueKey(plans[index].id),
                        plan: plans[index],
                        onEdit: (exerciseIndex) =>
                            _edit(user.uid, plans[index], exerciseIndex),
                        onDelete: () => _delete(user.uid, plans[index]),
                        onSchedule: () => _schedule(user.uid, plans[index]),
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

class WorkoutPlanDetails extends StatelessWidget {
  final WorkoutPlan plan;
  final ValueChanged<int> onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSchedule;

  const WorkoutPlanDetails({
    super.key,
    required this.plan,
    required this.onEdit,
    required this.onDelete,
    required this.onSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final preferences = plan.preferences;
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: WorkoutPage.planningLine),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                plan.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Delete plan',
              color: Theme.of(context).colorScheme.error,
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
        initiallyExpanded: true,
        subtitle: Text(
          '${plan.exercises.length} exercises',
          style: const TextStyle(fontSize: 13, color: WorkoutPage.muted),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: onSchedule,
                icon: const Icon(Icons.event_available_outlined),
                label: const Text('Schedule Workout'),
              ),
            ),
          ),
          if (preferences.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (preferences['goal'] != null)
                    Text(
                      '${preferences['goal']}',
                      style: const TextStyle(
                        color: WorkoutPage.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (preferences['experience'] != null)
                    Text('${preferences['experience']}'),
                  if (preferences['equipment'] != null)
                    Text('${preferences['equipment']}'),
                  if (preferences['daysPerWeek'] != null)
                    Text('${preferences['daysPerWeek']} days/week'),
                  if (preferences['durationMinutes'] != null)
                    Text('${preferences['durationMinutes']} min target'),
                ],
              ),
            ),
          if (plan.exercises.isEmpty) const Text('No exercises in this plan.'),
          for (var index = 0; index < plan.exercises.length; index++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SizedBox(
                width: 28,
                child: Text(
                  '${index + 1}'.padLeft(2, '0'),
                  style: const TextStyle(
                    color: WorkoutPage.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              title: Text(WorkoutPlan.exerciseName(plan.exercises[index])),
              subtitle: Text(
                '${plan.exercises[index]['sets']} sets x ${plan.exercises[index]['reps']} reps | ${plan.exercises[index]['restSeconds']}s rest',
              ),
              trailing: IconButton(
                tooltip: 'Edit exercise',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => onEdit(index),
              ),
            ),
        ],
      ),
    );
  }
}

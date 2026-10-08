import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/services/auth_service.dart';
import 'package:fitstart_mobile_app/services/database_service.dart';
import 'package:fitstart_mobile_app/services/workout_plan_generator.dart';
import 'package:fitstart_mobile_app/widgets/workout_page.dart';
import 'package:fitstart_mobile_app/screens/ai_workout_plan_screen.dart';

class CreateAiPlanScreen extends StatefulWidget {
  const CreateAiPlanScreen({super.key});

  @override
  State<CreateAiPlanScreen> createState() => _CreateAiPlanScreenState();
}

class _CreateAiPlanScreenState extends State<CreateAiPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _goal = 'Stay Fit';
  String _experience = 'Beginner';
  String _equipment = 'None';
  int _days = 3;
  int _duration = 30;
  bool _saving = false;
  Map<String, dynamic>? _savedPlan;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final user = AuthService().currentUser;
    if (user == null) {
      setState(() => _error = 'Please sign in before creating a plan.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final plan = WorkoutPlanGenerator().generate(
        goal: _goal,
        planName: _nameController.text,
        experience: _experience,
        equipment: _equipment,
        daysPerWeek: _days,
        durationMinutes: _duration,
      );
      await DatabaseService().generateRuleBasedPlan(
        user.id,
        _goal,
        planName: _nameController.text,
        experience: _experience,
        equipment: _equipment,
        daysPerWeek: _days,
        durationMinutes: _duration,
      );
      if (mounted) setState(() => _savedPlan = plan);
    } on FirebaseException catch (error) {
      if (mounted) {
        setState(
          () => _error = error.code == 'permission-denied'
              ? 'Your account does not have permission to save workout plans.'
              : 'Could not save the plan. Check your connection and try again.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not create the plan. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _selection<T>(
    String label,
    T value,
    List<T> options,
    ValueChanged<T> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: options
            .map(
              (option) =>
                  DropdownMenuItem<T>(value: option, child: Text('$option')),
            )
            .toList(),
        onChanged: _saving
            ? null
            : (selected) {
                if (selected != null) setState(() => onChanged(selected));
              },
        validator: (selected) => selected == null ? 'Select $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = _savedPlan;
    return WorkoutPage(
      title: 'Create Workout Plan',
      planningStyle: true,
      bottomBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Align(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 552),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _generate,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.fitness_center),
                  label: Text(_saving ? 'Saving...' : 'Generate Plan'),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const WorkoutSectionHeading(
                        'Make it yours',
                        icon: Icons.edit_outlined,
                      ),
                      TextFormField(
                        controller: _nameController,
                        enabled: !_saving,
                        maxLength: 60,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Workout plan name',
                          hintText: 'e.g. Morning Strength',
                          prefixIcon: Icon(Icons.drive_file_rename_outline),
                        ),
                        validator: (value) {
                          final name = value?.trim() ?? '';
                          if (name.isEmpty) return 'Enter a workout plan name.';
                          if (name.length > 60) {
                            return 'Use 60 characters or fewer.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const WorkoutSectionHeading(
                        'Training preferences',
                        icon: Icons.fitness_center_outlined,
                      ),
                      _selection(
                        'Fitness goal',
                        _goal,
                        WorkoutPlanGenerator.goals,
                        (value) => _goal = value,
                      ),
                      _selection(
                        'Experience',
                        _experience,
                        WorkoutPlanGenerator.levels,
                        (value) => _experience = value,
                      ),
                      _selection(
                        'Equipment',
                        _equipment,
                        WorkoutPlanGenerator.equipmentOptions,
                        (value) => _equipment = value,
                      ),
                      _number('Days per week', _days, [
                        1,
                        2,
                        3,
                        4,
                        5,
                      ], (value) => _days = value),
                      _number(
                        'Target session length (minutes)',
                        _duration,
                        WorkoutPlanGenerator.durations,
                        (value) => _duration = value,
                      ),
                      if (_error != null) ...[
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
                if (plan != null) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    plan['title'] as String,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saved - ${(plan['preferences'] as Map)['daysPerWeek']} days per week',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AiWorkoutPlanScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list_alt_outlined),
                    label: const Text('My Workout Plans'),
                  ),
                  const SizedBox(height: 16),
                  for (final exercise in plan['exercises'] as List)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.fitness_center),
                      title: Text(exercise['name'] as String),
                      subtitle: Text(
                        '${exercise['sets']} sets x ${exercise['reps']} reps | ${exercise['restSeconds']}s rest',
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _number(
    String label,
    int value,
    List<int> options,
    ValueChanged<int> onChanged,
  ) {
    final index = options.indexOf(value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: WorkoutPage.muted),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: WorkoutPage.line),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Decrease $label',
                  onPressed: _saving || index == 0
                      ? null
                      : () => setState(() => onChanged(options[index - 1])),
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Increase $label',
                  onPressed: _saving || index == options.length - 1
                      ? null
                      : () => setState(() => onChanged(options[index + 1])),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

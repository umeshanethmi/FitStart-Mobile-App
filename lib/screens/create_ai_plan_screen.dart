import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/services/auth_service.dart';
import 'package:fitstart_mobile_app/services/database_service.dart';
import 'package:fitstart_mobile_app/services/workout_plan_generator.dart';

class CreateAiPlanScreen extends StatefulWidget {
  const CreateAiPlanScreen({super.key});

  @override
  State<CreateAiPlanScreen> createState() => _CreateAiPlanScreenState();
}

class _CreateAiPlanScreenState extends State<CreateAiPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  String _goal = 'Stay Fit';
  String _experience = 'Beginner';
  String _equipment = 'None';
  int _days = 3;
  int _duration = 30;
  bool _saving = false;
  Map<String, dynamic>? _savedPlan;
  String? _error;

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
        experience: _experience,
        equipment: _equipment,
        daysPerWeek: _days,
        durationMinutes: _duration,
      );
      await DatabaseService().generateRuleBasedPlan(
        user.id,
        _goal,
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
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Create Workout Plan')),
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
                      _selection('Days per week', _days, [
                        1,
                        2,
                        3,
                        4,
                        5,
                      ], (value) => _days = value),
                      _selection(
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
                      FilledButton.icon(
                        onPressed: _saving ? null : _generate,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.fitness_center),
                        label: Text(_saving ? 'Saving...' : 'Generate Plan'),
                      ),
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
}

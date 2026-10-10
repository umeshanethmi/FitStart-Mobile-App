import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitstart_mobile_app/features/workout/models/custom_workout.dart';
import 'package:fitstart_mobile_app/features/workout/providers/custom_workout_provider.dart';
import 'package:fitstart_mobile_app/models/exercise.dart';

class WorkoutFormScreen extends ConsumerWidget {
  const WorkoutFormScreen({super.key, this.workoutId});

  final String? workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (workoutId == null) {
      return const _WorkoutFormEditor();
    }

    final workout = ref.watch(workoutByIdProvider(workoutId!));
    return workout.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit Workout')),
        body: Center(child: Text('Could not load workout: $error')),
      ),
      data: (value) => value == null
          ? Scaffold(
              appBar: AppBar(title: const Text('Edit Workout')),
              body: const Center(child: Text('Workout not found.')),
            )
          : _WorkoutFormEditor(key: ValueKey(value.id), workout: value),
    );
  }
}

class _WorkoutFormEditor extends ConsumerStatefulWidget {
  const _WorkoutFormEditor({super.key, this.workout});

  final CustomWorkout? workout;

  @override
  ConsumerState<_WorkoutFormEditor> createState() => _WorkoutFormEditorState();
}

class _WorkoutFormEditorState extends ConsumerState<_WorkoutFormEditor> {
  static const _green = Color(0xFF16A34A);
  static const _levels = ['Beginner', 'Intermediate', 'Advanced'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _level;
  late List<_ExerciseFormValue> _exercises;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final workout = widget.workout;
    _nameController = TextEditingController(text: workout?.name ?? '');
    _level = _levels.contains(workout?.level) ? workout!.level : _levels.first;
    _exercises = workout == null || workout.exercises.isEmpty
        ? [_ExerciseFormValue()]
        : workout.exercises.map(_ExerciseFormValue.fromExercise).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final exercise in _exercises) {
      exercise.dispose();
    }
    super.dispose();
  }

  void _addExercise() {
    setState(() => _exercises.add(_ExerciseFormValue()));
  }

  void _removeExercise(int index) {
    final removed = _exercises.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final workout = CustomWorkout(
      id: widget.workout?.id ?? '',
      name: _nameController.text.trim(),
      level: _level,
      plannedDurationMinutes: widget.workout?.plannedDurationMinutes,
      exercises: _exercises
          .map(
            (exercise) => Exercise(
              name: exercise.name.text.trim(),
              description: exercise.description.text.trim(),
              sets: int.parse(exercise.sets.text),
              reps: exercise.isTimed ? null : int.parse(exercise.amount.text),
              durationSeconds: exercise.isTimed
                  ? int.parse(exercise.amount.text)
                  : null,
              restSeconds: int.parse(exercise.rest.text),
              targetArea: exercise.targetArea.text.trim(),
              beginnerTip: exercise.tip.text.trim(),
            ),
          )
          .toList(),
    );

    try {
      final notifier = ref.read(customWorkoutsProvider.notifier);
      if (widget.workout == null) {
        await notifier.createWorkout(workout);
      } else {
        await notifier.updateWorkout(workout);
      }
      if (mounted) context.go('/workouts');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save workout: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  String? _positiveNumber(
    String? value,
    String label, {
    bool allowZero = false,
  }) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null || (allowZero ? number < 0 : number < 1)) {
      return allowZero
          ? '$label must be 0 or more seconds.'
          : '$label must be a whole number greater than 0.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.workout != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Workout' : 'Create Workout',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFFF6F8FD),
        foregroundColor: const Color(0xFF0F172A),
        surfaceTintColor: const Color(0xFFF6F8FD),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            _SectionCard(
              title: 'Workout details',
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Workout name',
                      hintText: 'e.g. Morning Strength',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => _requiredText(value, 'Workout name'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _level,
                    decoration: const InputDecoration(
                      labelText: 'Level',
                      border: OutlineInputBorder(),
                    ),
                    items: _levels
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _level = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Exercises',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(foregroundColor: _green),
                ),
              ],
            ),
            for (var index = 0; index < _exercises.length; index++) ...[
              _ExerciseEditor(
                key: ObjectKey(_exercises[index]),
                number: index + 1,
                value: _exercises[index],
                canRemove: _exercises.length > 1,
                onRemove: () => _removeExercise(index),
                requiredText: _requiredText,
                positiveNumber: _positiveNumber,
                onMeasureChanged: () => setState(() {}),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 10, 18, 14),
        child: SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(isEditing ? 'Save Changes' : 'Save Workout'),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7ECF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ExerciseEditor extends StatelessWidget {
  const _ExerciseEditor({
    super.key,
    required this.number,
    required this.value,
    required this.canRemove,
    required this.onRemove,
    required this.requiredText,
    required this.positiveNumber,
    required this.onMeasureChanged,
  });

  final int number;
  final _ExerciseFormValue value;
  final bool canRemove;
  final VoidCallback onRemove;
  final String? Function(String?, String) requiredText;
  final String? Function(String?, String, {bool allowZero}) positiveNumber;
  final VoidCallback onMeasureChanged;

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
  );

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Exercise $number',
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Exercise information',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (canRemove)
                IconButton(
                  tooltip: 'Remove exercise $number',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ],
          ),
          TextFormField(
            controller: value.name,
            textCapitalization: TextCapitalization.words,
            decoration: _decoration('Exercise name'),
            validator: (text) => requiredText(text, 'Exercise name'),
          ),
          const SizedBox(height: 11),
          TextFormField(
            controller: value.targetArea,
            textCapitalization: TextCapitalization.words,
            decoration: _decoration('Target area'),
            validator: (text) => requiredText(text, 'Target area'),
          ),
          const SizedBox(height: 11),
          DropdownButtonFormField<bool>(
            initialValue: value.isTimed,
            decoration: _decoration('Measure'),
            items: const [
              DropdownMenuItem(value: false, child: Text('Repetitions')),
              DropdownMenuItem(value: true, child: Text('Seconds')),
            ],
            onChanged: (timed) {
              if (timed != null) {
                value.isTimed = timed;
                onMeasureChanged();
              }
            },
          ),
          const SizedBox(height: 11),
          TextFormField(
            controller: value.sets,
            keyboardType: TextInputType.number,
            decoration: _decoration('Sets'),
            validator: (text) => positiveNumber(text, 'Sets'),
          ),
          const SizedBox(height: 11),
          TextFormField(
            controller: value.amount,
            keyboardType: TextInputType.number,
            decoration: _decoration(
              value.isTimed ? 'Seconds per set' : 'Reps per set',
            ),
            validator: (text) =>
                positiveNumber(text, value.isTimed ? 'Seconds' : 'Reps'),
          ),
          const SizedBox(height: 11),
          TextFormField(
            controller: value.rest,
            keyboardType: TextInputType.number,
            decoration: _decoration('Rest between sets (seconds)'),
            validator: (text) => positiveNumber(text, 'Rest', allowZero: true),
          ),
          const SizedBox(height: 11),
          TextFormField(
            controller: value.description,
            minLines: 2,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: _decoration('Instructions'),
            validator: (text) => requiredText(text, 'Instructions'),
          ),
          const SizedBox(height: 11),
          TextFormField(
            controller: value.tip,
            minLines: 2,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: _decoration('Tip'),
            validator: (text) => requiredText(text, 'Tip'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseFormValue {
  _ExerciseFormValue({
    String name = '',
    String description = '',
    String targetArea = '',
    String sets = '3',
    String amount = '10',
    String rest = '45',
    String tip = '',
    this.isTimed = false,
  }) : name = TextEditingController(text: name),
       description = TextEditingController(text: description),
       targetArea = TextEditingController(text: targetArea),
       sets = TextEditingController(text: sets),
       amount = TextEditingController(text: amount),
       rest = TextEditingController(text: rest),
       tip = TextEditingController(text: tip);

  factory _ExerciseFormValue.fromExercise(Exercise exercise) =>
      _ExerciseFormValue(
        name: exercise.name,
        description: exercise.description,
        targetArea: exercise.targetArea,
        sets: exercise.sets.toString(),
        amount: (exercise.durationSeconds ?? exercise.reps!).toString(),
        rest: exercise.restSeconds.toString(),
        tip: exercise.beginnerTip,
        isTimed: exercise.durationSeconds != null,
      );

  final TextEditingController name;
  final TextEditingController description;
  final TextEditingController targetArea;
  final TextEditingController sets;
  final TextEditingController amount;
  final TextEditingController rest;
  final TextEditingController tip;
  bool isTimed;

  void dispose() {
    name.dispose();
    description.dispose();
    targetArea.dispose();
    sets.dispose();
    amount.dispose();
    rest.dispose();
    tip.dispose();
  }
}

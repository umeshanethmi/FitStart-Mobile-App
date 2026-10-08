import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/widgets/workout_page.dart';
import 'package:flutter/services.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';

class EditPlanExerciseDialog extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final Future<void> Function(int sets, int reps, int restSeconds) onSave;

  const EditPlanExerciseDialog({
    super.key,
    required this.exercise,
    required this.onSave,
  });

  @override
  State<EditPlanExerciseDialog> createState() => _EditPlanExerciseDialogState();
}

class _EditPlanExerciseDialogState extends State<EditPlanExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _sets = TextEditingController(
    text: '${widget.exercise['sets'] ?? 1}',
  );
  late final _reps = TextEditingController(
    text: '${widget.exercise['reps'] ?? 1}',
  );
  late final _rest = TextEditingController(
    text: '${widget.exercise['restSeconds'] ?? 60}',
  );
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _sets.dispose();
    _reps.dispose();
    _rest.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(
        int.parse(_sets.text),
        int.parse(_reps.text),
        int.parse(_rest.text),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error =
              error is FirebaseException && error.code == 'permission-denied'
              ? 'You do not have permission to update this plan.'
              : error is StateError
              ? error.message.toString()
              : 'Could not save changes. Please try again.';
        });
      }
    }
  }

  Widget _field(
    String label,
    TextEditingController controller,
    int min,
    int max,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: !_saving,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (text) {
          final number = int.tryParse(text ?? '');
          return number == null || number < min || number > max
              ? 'Enter a number from $min to $max.'
              : null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: WorkoutPage.theme(context, planningStyle: true),
      child: PopScope(
        canPop: !_saving,
        child: AlertDialog(
          scrollable: true,
          title: Text(WorkoutPlan.exerciseName(widget.exercise)),
          content: SizedBox(
            width: 360,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _field('Sets', _sets, 1, 10),
                  _field('Repetitions', _reps, 1, 200),
                  _field('Rest (seconds)', _rest, 0, 600),
                  if (_error != null)
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

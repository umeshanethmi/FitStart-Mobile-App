import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/widgets/workout_page.dart';
import 'package:firebase_core/firebase_core.dart';

class ScheduleWorkoutDialog extends StatefulWidget {
  final String title;
  final DateTime? initialDate;
  final Future<void> Function(DateTime) onSave;

  const ScheduleWorkoutDialog({
    super.key,
    required this.title,
    required this.onSave,
    this.initialDate,
  });

  @override
  State<ScheduleWorkoutDialog> createState() => _ScheduleWorkoutDialogState();
}

class _ScheduleWorkoutDialogState extends State<ScheduleWorkoutDialog> {
  late DateTime _selected =
      widget.initialDate ?? DateTime.now().add(const Duration(days: 1));
  bool _saving = false;
  String? _error;

  String _saveError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Firebase denied permission to save this workout. Your account needs access to workout schedules.';
        case 'unauthenticated':
          return 'Your session has expired. Please sign in again.';
        case 'unavailable':
          return 'Firebase is unavailable. Check your connection and try again.';
        default:
          return 'Could not save the workout (${error.code}). Please try again.';
      }
    }
    if (error is StateError) return error.message.toString();
    if (error is ArgumentError) return error.message.toString();
    return 'Could not save the workout. Please try again.';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final last = DateTime(now.year + 5, 12, 31);
    final date = await showDatePicker(
      context: context,
      initialDate: _selected.isBefore(first)
          ? first
          : _selected.isAfter(last)
          ? last
          : _selected,
      firstDate: first,
      lastDate: last,
    );
    if (date != null && mounted) {
      setState(
        () => _selected = DateTime(
          date.year,
          date.month,
          date.day,
          _selected.hour,
          _selected.minute,
        ),
      );
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selected),
    );
    if (time != null && mounted) {
      setState(
        () => _selected = DateTime(
          _selected.year,
          _selected.month,
          _selected.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final date = DateTime(
      _selected.year,
      _selected.month,
      _selected.day,
      _selected.hour,
      _selected.minute,
    );
    if (!date.isAfter(DateTime.now())) {
      setState(() => _error = 'Choose a future date and time.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(date);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = _saveError(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Theme(
      data: WorkoutPage.theme(context),
      child: PopScope(
        canPop: !_saving,
        child: AlertDialog(
          scrollable: true,
          title: Text(
            widget.initialDate == null
                ? 'Schedule Workout'
                : 'Reschedule Workout',
          ),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.title),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(localizations.formatMediumDate(_selected)),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickTime,
                  icon: const Icon(Icons.schedule),
                  label: Text(
                    TimeOfDay.fromDateTime(_selected).format(context),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _saving
                  ? null
                  : () => Navigator.of(context).pop(false),
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

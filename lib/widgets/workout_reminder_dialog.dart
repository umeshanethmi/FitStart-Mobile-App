import 'package:flutter/material.dart';

class WorkoutReminderDialog extends StatefulWidget {
  final String title;
  final DateTime scheduledAt;
  final int? minutesBefore;
  final bool enabled;
  final Future<void> Function(int, bool) onSave;

  const WorkoutReminderDialog({
    super.key,
    required this.title,
    required this.scheduledAt,
    required this.onSave,
    this.minutesBefore,
    this.enabled = true,
  });

  @override
  State<WorkoutReminderDialog> createState() => _WorkoutReminderDialogState();
}

class _WorkoutReminderDialogState extends State<WorkoutReminderDialog> {
  late int _minutes = widget.minutesBefore ?? 10;
  late bool _enabled = widget.enabled;
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    if (_saving) return;
    if (_enabled &&
        !widget.scheduledAt
            .subtract(Duration(minutes: _minutes))
            .isAfter(DateTime.now())) {
      setState(
        () => _error = 'Choose a reminder time that is still in the future.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(_minutes, _enabled);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error is StateError ? error.message.toString() : 'Could not save the reminder. Check your connection and account permissions.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        scrollable: true,
        title: const Text('Workout Reminder'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reminder'),
                value: _enabled,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _enabled = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _minutes,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Notify me',
                  border: OutlineInputBorder(),
                ),
                items: [0, 5, 10, 15, 30, 60]
                    .map(
                      (minutes) => DropdownMenuItem(
                        value: minutes,
                        child: Text(
                          minutes == 0
                              ? 'At workout time'
                              : '$minutes minutes before',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _saving || !_enabled
                    ? null
                    : (value) => setState(() => _minutes = value!),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
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
    );
  }
}

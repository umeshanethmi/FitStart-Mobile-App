import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class DeleteWorkoutPlanDialog extends StatefulWidget {
  final String title;
  final Future<void> Function() onDelete;
  final bool scheduledWorkout;

  const DeleteWorkoutPlanDialog({
    super.key,
    required this.title,
    required this.onDelete,
    this.scheduledWorkout = false,
  });

  @override
  State<DeleteWorkoutPlanDialog> createState() =>
      _DeleteWorkoutPlanDialogState();
}

class _DeleteWorkoutPlanDialogState extends State<DeleteWorkoutPlanDialog> {
  bool _deleting = false;
  String? _error;

  Future<void> _delete() async {
    if (_deleting) return;
    setState(() {
      _deleting = true;
      _error = null;
    });
    try {
      await widget.onDelete();
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _deleting = false;
          _error =
              error is FirebaseException && error.code == 'permission-denied'
              ? 'You do not have permission to delete this ${widget.scheduledWorkout ? 'workout' : 'plan'}.'
              : error is StateError
              ? error.message.toString()
              : 'Could not delete the ${widget.scheduledWorkout ? 'workout' : 'plan'}. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_deleting,
      child: AlertDialog(
        scrollable: true,
        title: Text(
          widget.scheduledWorkout
              ? 'Delete scheduled workout?'
              : 'Delete workout plan?',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.scheduledWorkout
                  ? 'Remove "${widget.title}" from your schedule? Your saved plan will be kept.'
                  : 'Delete "${widget.title}" and all its exercises? This cannot be undone.',
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
        actions: [
          TextButton(
            onPressed: _deleting
                ? null
                : () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: _deleting ? null : _delete,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            icon: _deleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            label: Text(_deleting ? 'Deleting...' : 'Delete'),
          ),
        ],
      ),
    );
  }
}

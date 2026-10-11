import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';
import 'package:fitstart_mobile_app/services/database_service.dart';

class ProgressDataView extends StatefulWidget {
  const ProgressDataView({super.key, required this.builder});

  final Widget Function(BuildContext context, List<WorkoutSession> workouts)
  builder;

  @override
  State<ProgressDataView> createState() => _ProgressDataViewState();
}

class _ProgressDataViewState extends State<ProgressDataView> {
  final DatabaseService _databaseService = DatabaseService();
  late Stream<List<WorkoutSession>> _workoutsStream;

  @override
  void initState() {
    super.initState();
    _workoutsStream = _databaseService.watchWorkouts();
  }

  void _retry() {
    setState(() => _workoutsStream = _databaseService.watchWorkouts());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WorkoutSession>>(
      stream: _workoutsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ProgressLoadMessage(
            message: _errorMessage(snapshot.error!),
            actionLabel: 'Try again',
            onPressed: _retry,
          );
        }
        if (!snapshot.hasData) {
          return const _ProgressLoadMessage(
            message: 'Loading your workouts...',
            isLoading: true,
          );
        }
        return widget.builder(context, snapshot.data ?? const []);
      },
    );
  }

  String _errorMessage(Object error) {
    if (error is FirebaseException) {
      return 'Could not load your workouts (${error.code}): ${error.message ?? 'Firestore request failed.'}';
    }
    return 'Could not load your workouts: $error';
  }
}

class _ProgressLoadMessage extends StatelessWidget {
  const _ProgressLoadMessage({
    required this.message,
    this.isLoading = false,
    this.actionLabel,
    this.onPressed,
  });

  final String message;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text('Progress & Analytics'),
        backgroundColor: const Color(0xFFF6F8FD),
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const CircularProgressIndicator(color: Color(0xFF2563EB))
                else
                  const Icon(
                    Icons.cloud_off_outlined,
                    color: Color(0xFF64748B),
                    size: 32,
                  ),
                const SizedBox(height: 14),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: 8),
                  TextButton(onPressed: onPressed, child: Text(actionLabel!)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

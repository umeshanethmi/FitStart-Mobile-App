import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/active_workout_screen.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final WorkoutSession session;
  final int exerciseIndex;

  const ExerciseDetailScreen({
    super.key,
    required this.session,
    required this.exerciseIndex,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  static const _exerciseVideoIds = {
    'Bodyweight Squat': 'xqvCmoLULNY',
    'Wall Push-Up': 'BApAd0yDt3Y',
    'Glute Bridge': 'RrU4zx4ysnI',
    'Standing March': 'pGo78U1_9k4',
  };

  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    final exercise = widget.session.plan.exercises[widget.exerciseIndex];
    final videoId = _exerciseVideoIds[exercise.name];
    if (videoId != null && _supportsYoutubePlayer) {
      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          mute: true,
          showControls: true,
          showFullscreenButton: true,
          privacyEnhancedMode: kIsWeb,
        ).copyWith(origin: _youtubeOrigin),
      );
    }
  }

  String get _youtubeOrigin {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return 'https://com.fitstart.fitstartmobileapp';
    }
    return 'https://com.fitstart.fitstart_mobile_app';
  }

  bool get _supportsYoutubePlayer =>
      kIsWeb ||
      (WebViewPlatform.instance != null &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS));

  @override
  void dispose() {
    final controller = _youtubeController;
    if (controller != null) {
      unawaited(controller.close());
    }
    super.dispose();
  }

  void _startExercise() {
    widget.session.start();
    final controller = _youtubeController;
    if (controller != null) {
      unawaited(controller.pauseVideo());
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveWorkoutScreen(
          session: widget.session,
          exerciseIndex: widget.exerciseIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.session.plan.exercises[widget.exerciseIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text(
          'Exercise Details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFFF6F8FD),
        foregroundColor: const Color(0xFF0F172A),
        surfaceTintColor: const Color(0xFFF6F8FD),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 400 ? 18.0 : 24.0;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      8,
                      horizontalPadding,
                      24,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Exercise demonstration',
                                      style: TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.play_circle_fill_rounded,
                                          size: 15,
                                          color: Color(0xFF2563EB),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'VIDEO GUIDE',
                                          style: TextStyle(
                                            color: Color(0xFF1D4ED8),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_youtubeController case final controller?)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: YoutubePlayer(
                                    controller: controller,
                                    aspectRatio: 16 / 9,
                                    backgroundColor: const Color(0xFFE3EDFE),
                                  ),
                                )
                              else
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFEFF6FF),
                                          Color(0xFFDBEAFE),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.play_circle_outline_rounded,
                                          size: 58,
                                          color: Color(0xFF2563EB),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Exercise demonstration',
                                          style: TextStyle(
                                            color: Color(0xFF1E40AF),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 23),
                              Text(
                                exercise.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.7,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                exercise.description,
                                style: TextStyle(
                                  color: Colors.blueGrey.shade700,
                                  height: 1.55,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 21),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Exercise at a glance',
                                      style: TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 19,
                                    color: Colors.blueGrey.shade400,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 11),
                              LayoutBuilder(
                                builder: (context, metricConstraints) {
                                  final wide =
                                      metricConstraints.maxWidth >= 560;
                                  final itemWidth = wide
                                      ? (metricConstraints.maxWidth - 20) / 3
                                      : (metricConstraints.maxWidth - 10) / 2;
                                  return Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      SizedBox(
                                        width: itemWidth,
                                        child: _ExerciseMetric(
                                          icon:
                                              Icons.center_focus_strong_rounded,
                                          label: 'TARGET AREA',
                                          value: exercise.targetArea,
                                        ),
                                      ),
                                      SizedBox(
                                        width: itemWidth,
                                        child: _ExerciseMetric(
                                          icon: Icons.repeat_rounded,
                                          label: 'SETS & REPS',
                                          value: exercise.workDescription,
                                        ),
                                      ),
                                      SizedBox(
                                        width: itemWidth,
                                        child: _ExerciseMetric(
                                          icon: Icons.hourglass_bottom_rounded,
                                          label: 'REST',
                                          value:
                                              '${exercise.restSeconds} seconds',
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.all(17),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(19),
                                  border: Border.all(
                                    color: const Color(0xFFFEF3C7),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.lightbulb_rounded,
                                        color: Color(0xFFD97706),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Form tip',
                                            style: TextStyle(
                                              color: Color(0xFF92400E),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            exercise.beginnerTip,
                                            style: const TextStyle(
                                              color: Color(0xFF78350F),
                                              fontSize: 13,
                                              height: 1.45,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    14,
                    horizontalPadding,
                    18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: _startExercise,
                          icon: const Icon(Icons.play_arrow_rounded, size: 23),
                          label: const Text(
                            'Start Exercise',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ExerciseMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE7ECF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 19),
          const SizedBox(height: 9),
          Text(
            label,
            style: TextStyle(
              color: Colors.blueGrey.shade500,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

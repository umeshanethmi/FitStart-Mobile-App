import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/achievement.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';
import 'package:fitstart_mobile_app/screens/achievement_detail_screen.dart';
import 'package:fitstart_mobile_app/services/achievement_service.dart';
import 'package:fitstart_mobile_app/services/database_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  static const Color _blue = Color(0xFF2563EB);
  static const Color _navy = Color(0xFF0F172A);

  final DatabaseService _databaseService = DatabaseService();
  final AchievementService _achievementService = AchievementService();
  late Stream<List<WorkoutSession>> _workoutsStream;
  late Stream<List<AchievementRecord>> _recordsStream;
  StreamSubscription<List<WorkoutSession>>? _syncSubscription;

  AchievementCategory? _category;
  String _statusFilter = 'All';
  String? _syncError;
  String? _lastSyncKey;
  List<WorkoutSession>? _lastWorkouts;

  @override
  void initState() {
    super.initState();
    _startStreams();
  }

  void _startStreams() {
    _workoutsStream = _databaseService.watchWorkouts().asBroadcastStream();
    _recordsStream = _achievementService.watchUnlockedAchievements();
    _syncSubscription = _workoutsStream.listen(
      _synchronize,
      onError: (Object error) {
        if (mounted) setState(() => _syncError = _errorMessage(error));
      },
    );
  }

  void _retry() {
    _syncSubscription?.cancel();
    setState(() {
      _lastSyncKey = null;
      _syncError = null;
      _startStreams();
    });
  }

  void _retrySync() {
    final workouts = _lastWorkouts;
    if (workouts == null) {
      _retry();
      return;
    }
    setState(() {
      _lastSyncKey = null;
      _syncError = null;
    });
    _synchronize(workouts);
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }

  Future<void> _synchronize(List<WorkoutSession> workouts) async {
    _lastWorkouts = workouts;
    final key =
        workouts
            .where((workout) => workout.isCompleted)
            .map(
              (workout) =>
                  '${workout.id}:${(workout.completedAt ?? workout.startedAt ?? workout.createdAt)?.millisecondsSinceEpoch}:'
                  '${workout.durationSeconds}:${workout.calories}',
            )
            .toList()
          ..sort();
    final signature = key.join('|');
    if (signature == _lastSyncKey) return;
    _lastSyncKey = signature;

    try {
      final newlyUnlocked = await _achievementService.synchronize(workouts);
      if (!mounted) return;
      setState(() => _syncError = null);
      if (newlyUnlocked.isNotEmpty) {
        _showCelebration(newlyUnlocked);
      }
    } catch (error) {
      if (!mounted) return;
      _lastSyncKey = null;
      setState(() => _syncError = _errorMessage(error));
    }
  }

  String _errorMessage(Object error) {
    if (error is FirebaseException) {
      return 'Achievements could not be saved (${error.code}). '
          '${error.message ?? 'Check your connection and try again.'}';
    }
    return 'Achievements could not be saved: $error';
  }

  Future<void> _showCelebration(List<String> ids) async {
    final definitions = ids
        .map(AchievementCatalog.byId)
        .whereType<AchievementDefinition>()
        .toList();
    if (!mounted || definitions.isEmpty) return;
    final points = definitions.fold<int>(
      0,
      (total, item) => total + item.points,
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.celebration_rounded,
          color: Color(0xFFF59E0B),
          size: 42,
        ),
        title: Text(
          definitions.length == 1
              ? 'Achievement unlocked!'
              : 'New achievements!',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final definition in definitions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(definition.icon, color: definition.color, size: 21),
                    const SizedBox(width: 10),
                    Expanded(child: Text(definition.title)),
                    Text('+${definition.points}'),
                  ],
                ),
              ),
            const SizedBox(height: 5),
            Text(
              '+$points reward points earned',
              style: const TextStyle(color: _blue, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Nice!'),
          ),
        ],
      ),
    );
  }

  void _openDetails({
    required AchievementDefinition definition,
    required AchievementProgress progress,
    AchievementRecord? record,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AchievementDetailScreen(
          achievement: definition,
          progress: progress,
          record: record,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WorkoutSession>>(
      stream: _workoutsStream,
      builder: (context, workoutSnapshot) {
        if (workoutSnapshot.hasError) {
          return _loadState(
            message:
                'Could not load your completed workouts: '
                '${_errorMessage(workoutSnapshot.error!)}',
            onRetry: _retry,
          );
        }
        if (!workoutSnapshot.hasData) {
          return _loadState(isLoading: true);
        }
        return StreamBuilder<List<AchievementRecord>>(
          stream: _recordsStream,
          builder: (context, recordSnapshot) {
            if (recordSnapshot.hasError) {
              return _loadState(
                message:
                    'Could not load your saved rewards: '
                    '${_errorMessage(recordSnapshot.error!)}',
                onRetry: _retry,
              );
            }
            if (!recordSnapshot.hasData) {
              return _loadState(isLoading: true);
            }
            return _buildDashboard(workoutSnapshot.data!, recordSnapshot.data!);
          },
        );
      },
    );
  }

  Widget _loadState({
    bool isLoading = false,
    String? message,
    VoidCallback? onRetry,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text('Achievements & Rewards'),
        backgroundColor: const Color(0xFFF6F8FD),
        foregroundColor: _navy,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const CircularProgressIndicator(color: _blue)
              else
                const Icon(
                  Icons.cloud_off_outlined,
                  color: Color(0xFF64748B),
                  size: 32,
                ),
              const SizedBox(height: 14),
              Text(
                isLoading ? 'Loading your achievements...' : message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _navy),
              ),
              if (!isLoading) ...[
                const SizedBox(height: 8),
                TextButton(onPressed: onRetry, child: const Text('Try again')),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    List<WorkoutSession> workouts,
    List<AchievementRecord> records,
  ) {
    final progress = AchievementProgress(workouts);
    final recordsById = {for (final record in records) record.id: record};
    final achievements = AchievementCatalog.definitions;
    final unlockedCount = achievements
        .where((achievement) => recordsById.containsKey(achievement.id))
        .length;
    final lockedCount = achievements.length - unlockedCount;
    final earnedPoints = achievements
        .where((achievement) => recordsById.containsKey(achievement.id))
        .fold<int>(0, (total, achievement) => total + achievement.points);
    final visible = achievements.where((achievement) {
      if (_category != null && achievement.category != _category) return false;
      final unlocked = recordsById.containsKey(achievement.id);
      if (_statusFilter == 'Unlocked' && !unlocked) return false;
      if (_statusFilter == 'Locked' && unlocked) return false;
      return true;
    }).toList();
    final history =
        records
            .where((record) => AchievementCatalog.byId(record.id) != null)
            .toList()
          ..sort((first, second) {
            final firstDate = first.earnedAt;
            final secondDate = second.earnedAt;
            if (firstDate == null) return 1;
            if (secondDate == null) return -1;
            return secondDate.compareTo(firstDate);
          });
    final level = _AchievementLevel.forPoints(earnedPoints);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text(
          'Achievements & Rewards',
          style: TextStyle(
            color: _navy,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFF6F8FD),
        foregroundColor: _navy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const Text(
            'Your achievements',
            style: TextStyle(
              color: _navy,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Earn rewards for every step of your fitness journey.',
            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 18),
          if (_syncError != null) ...[
            _syncErrorBanner(),
            const SizedBox(height: 12),
          ],
          _overviewCard(
            unlockedCount: unlockedCount,
            totalCount: achievements.length,
            points: earnedPoints,
            level: level,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _countCard(
                  icon: Icons.lock_open_rounded,
                  title: 'Unlocked',
                  count: unlockedCount,
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _countCard(
                  icon: Icons.lock_outline_rounded,
                  title: 'To unlock',
                  count: lockedCount,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _pointsCard(earnedPoints)),
            ],
          ),
          const SizedBox(height: 22),
          _sectionTitle('Browse achievements'),
          const SizedBox(height: 10),
          _categoryChips(),
          const SizedBox(height: 10),
          _statusChips(),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: visible.isEmpty
                ? _emptyFilterState(
                    key: ValueKey('empty$_category$_statusFilter'),
                  )
                : Column(
                    key: ValueKey('list$_category$_statusFilter'),
                    children: [
                      for (final achievement in visible)
                        _achievementCard(
                          achievement,
                          progress,
                          recordsById[achievement.id],
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 18),
          _sectionTitle('Achievement history'),
          const SizedBox(height: 10),
          if (history.isEmpty)
            _emptyHistory()
          else
            ...history.take(10).map((record) {
              final achievement = AchievementCatalog.byId(record.id)!;
              return _historyCard(achievement, record, progress);
            }),
        ],
      ),
    );
  }

  Widget _overviewCard({
    required int unlockedCount,
    required int totalCount,
    required int points,
    required _AchievementLevel level,
  }) {
    final percent = totalCount == 0 ? 0.0 : unlockedCount / totalCount;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '$points reward points earned',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.stars_rounded,
                color: Color(0xFFFFD166),
                size: 27,
              ),
            ],
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, child) => Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: animatedProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(animatedProgress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$unlockedCount of $totalCount achievements unlocked',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 15),
          _levelProgress(points, level),
        ],
      ),
    );
  }

  Widget _levelProgress(int points, _AchievementLevel level) {
    if (level.nextThreshold == null) {
      return const Text(
        'You have reached the highest level!',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      );
    }
    final range = level.nextThreshold! - level.threshold;
    final progress = range <= 0 ? 1.0 : (points - level.threshold) / range;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${(level.nextThreshold! - points).clamp(0, level.nextThreshold!)} points to ${level.nextTitle}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD166)),
          ),
        ),
      ],
    );
  }

  Widget _countCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              color: _navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _pointsCard(int points) => Container(
    padding: const EdgeInsets.all(13),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 19),
        const SizedBox(height: 8),
        Text(
          '$points',
          style: const TextStyle(
            color: _navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          'Points',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
        ),
      ],
    ),
  );

  Widget _categoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _categoryChip(null, 'All'),
          for (final category in AchievementCategory.values)
            _categoryChip(category, category.label),
        ],
      ),
    );
  }

  Widget _categoryChip(AchievementCategory? category, String label) {
    final selected = _category == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _category = category),
        selectedColor: const Color(0xFFEAF1FF),
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? _blue : Colors.grey.shade200),
        labelStyle: TextStyle(
          color: selected ? _blue : Colors.grey.shade700,
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        showCheckmark: false,
      ),
    );
  }

  Widget _statusChips() {
    return Wrap(
      spacing: 8,
      children: ['All', 'Unlocked', 'Locked'].map((status) {
        final selected = _statusFilter == status;
        return ChoiceChip(
          label: Text(status),
          selected: selected,
          onSelected: (_) => setState(() => _statusFilter = status),
          selectedColor: const Color(0xFFEAF1FF),
          backgroundColor: Colors.white,
          side: BorderSide(color: selected ? _blue : Colors.grey.shade200),
          labelStyle: TextStyle(
            color: selected ? _blue : Colors.grey.shade700,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _achievementCard(
    AchievementDefinition achievement,
    AchievementProgress progress,
    AchievementRecord? record,
  ) {
    final unlocked = record != null;
    final ratio = achievement.progressFor(progress);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openDetails(
            definition: achievement,
            progress: progress,
            record: record,
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.88, end: 1),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          (unlocked
                                  ? achievement.color
                                  : const Color(0xFF94A3B8))
                              .withValues(alpha: unlocked ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      unlocked ? achievement.icon : Icons.lock_rounded,
                      color: unlocked
                          ? achievement.color
                          : const Color(0xFF94A3B8),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: TextStyle(
                          color: unlocked ? _navy : const Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        achievement.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: unlocked ? 1 : ratio,
                                minHeight: 5,
                                backgroundColor: const Color(0xFFE8EEFA),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  unlocked ? const Color(0xFF16A34A) : _blue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${achievement.points} pts',
                            style: const TextStyle(
                              color: _blue,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unlocked && record.earnedAt != null
                            ? 'Unlocked ${_formatDate(record.earnedAt!)}'
                            : unlocked
                            ? 'Unlocked'
                            : achievement.progressLabel(progress),
                        style: TextStyle(
                          color: unlocked
                              ? const Color(0xFF15803D)
                              : const Color(0xFF64748B),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _historyCard(
    AchievementDefinition achievement,
    AchievementRecord record,
    AchievementProgress progress,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openDetails(
            definition: achievement,
            progress: progress,
            record: record,
          ),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Icon(achievement.icon, color: achievement.color, size: 22),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: const TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        record.earnedAt == null
                            ? 'Unlock date unavailable'
                            : 'Unlocked ${_formatDate(record.earnedAt!)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '+${achievement.points} pts',
                  style: const TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyFilterState({required Key key}) => Container(
    key: key,
    padding: const EdgeInsets.all(22),
    decoration: _cardDecoration(),
    child: Column(
      children: [
        const Icon(
          Icons.search_off_rounded,
          color: Color(0xFF94A3B8),
          size: 34,
        ),
        const SizedBox(height: 8),
        const Text(
          'No achievements match these filters.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ],
    ),
  );

  Widget _emptyHistory() => Container(
    padding: const EdgeInsets.all(22),
    decoration: _cardDecoration(),
    child: Column(
      children: [
        const Icon(
          Icons.emoji_events_outlined,
          color: Color(0xFF94A3B8),
          size: 34,
        ),
        const SizedBox(height: 8),
        const Text(
          'Your achievement history starts with your first completed workout.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B), height: 1.4),
        ),
        const SizedBox(height: 5),
        Text(
          'Complete a workout to earn your first reward.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _syncErrorBanner() => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7ED),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFFED7AA)),
    ),
    child: Row(
      children: [
        const Icon(Icons.sync_problem_rounded, color: Color(0xFFEA580C)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _syncError!,
            style: const TextStyle(color: Color(0xFF9A3412), fontSize: 12),
          ),
        ),
        IconButton(
          tooltip: 'Retry',
          onPressed: _retrySync,
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFFEA580C)),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      color: _navy,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
  );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFE8EEF8)),
    boxShadow: [
      BoxShadow(
        color: _navy.withValues(alpha: 0.035),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _AchievementLevel {
  const _AchievementLevel({
    required this.title,
    required this.threshold,
    required this.nextTitle,
    required this.nextThreshold,
  });

  final String title;
  final int threshold;
  final String nextTitle;
  final int? nextThreshold;

  static _AchievementLevel forPoints(int points) {
    if (points >= 400) {
      return const _AchievementLevel(
        title: 'Champion',
        threshold: 400,
        nextTitle: '',
        nextThreshold: null,
      );
    }
    if (points >= 250) {
      return const _AchievementLevel(
        title: 'Advanced',
        threshold: 250,
        nextTitle: 'Champion',
        nextThreshold: 400,
      );
    }
    if (points >= 100) {
      return const _AchievementLevel(
        title: 'Active',
        threshold: 100,
        nextTitle: 'Advanced',
        nextThreshold: 250,
      );
    }
    return const _AchievementLevel(
      title: 'Beginner',
      threshold: 0,
      nextTitle: 'Active',
      nextThreshold: 100,
    );
  }
}

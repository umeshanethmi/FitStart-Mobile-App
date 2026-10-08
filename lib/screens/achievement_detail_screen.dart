import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/achievement.dart';

class AchievementDetailScreen extends StatelessWidget {
  const AchievementDetailScreen({
    super.key,
    required this.achievement,
    required this.progress,
    this.record,
  });

  final AchievementDefinition achievement;
  final AchievementProgress progress;
  final AchievementRecord? record;

  static const Color _navy = Color(0xFF0F172A);
  static const Color _blue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final unlocked = record != null;
    final value = achievement.progressFor(progress);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text('Achievement details'),
        backgroundColor: const Color(0xFFF6F8FD),
        foregroundColor: _navy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8EEF8)),
            ),
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: achievement.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    unlocked ? achievement.icon : Icons.lock_rounded,
                    color: achievement.color,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                _statusPill(unlocked),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _informationCard(
            title: 'Requirement',
            icon: Icons.flag_outlined,
            child: Text(
              achievement.requirement,
              style: const TextStyle(color: Color(0xFF475569), height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          _informationCard(
            title: 'Your progress',
            icon: Icons.trending_up_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.progressLabel(progress),
                        style: const TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${(value * 100).round()}%',
                      style: const TextStyle(
                        color: _blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: unlocked ? 1 : value),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedValue, child) =>
                      LinearProgressIndicator(
                        value: animatedValue,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: const Color(0xFFE8EEFA),
                        color: _blue,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _informationCard(
            title: 'Reward',
            icon: Icons.stars_rounded,
            child: Text(
              '${achievement.points} points',
              style: const TextStyle(
                color: _blue,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (unlocked && record!.earnedAt != null) ...[
            const SizedBox(height: 12),
            _informationCard(
              title: 'Unlocked',
              icon: Icons.event_available_rounded,
              child: Text(
                _formatDate(record!.earnedAt!),
                style: const TextStyle(color: Color(0xFF475569)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusPill(bool unlocked) {
    final color = unlocked ? const Color(0xFF15803D) : const Color(0xFF64748B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFFECFDF3) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        unlocked ? 'Unlocked' : 'Locked',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _informationCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _blue, size: 20),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

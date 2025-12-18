import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/learning_profile.dart' as models;
import '../providers/profile_provider.dart';

class BadgesView extends StatelessWidget {
  const BadgesView({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final allBadges = _getAllBadges();
    final earnedBadgeIds = profile.badges.map((b) => b.id).toSet();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Your Achievements',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${profile.badges.length} of ${allBadges.length} badges earned',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Progress indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: profile.badges.length / allBadges.length,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 32),

          // Earned badges
          if (profile.badges.isNotEmpty) ...[
            Text(
              'Earned Badges',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: profile.badges.length,
              itemBuilder: (context, index) {
                final badge = profile.badges[index];
                return _buildBadgeCard(
                  context,
                  badge: badge,
                  isEarned: true,
                );
              },
            ),
            const SizedBox(height: 32),
          ],

          // Locked badges
          Text(
            'Locked Badges',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: allBadges.length - profile.badges.length,
            itemBuilder: (context, index) {
              final lockedBadges = allBadges
                  .where((b) => !earnedBadgeIds.contains(b.id))
                  .toList();
              
              if (index >= lockedBadges.length) return const SizedBox();
              
              final badge = lockedBadges[index];
              return _buildBadgeCard(
                context,
                badge: badge,
                isEarned: false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(
    BuildContext context, {
    required models.Badge badge,
    required bool isEarned,
  }) {
    return GestureDetector(
      onTap: () {
        _showBadgeDetails(context, badge, isEarned);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                badge.icon,
                style: TextStyle(
                  fontSize: 48,
                  color: isEarned ? null : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isEarned ? null : Colors.grey,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isEarned) ...[
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, y').format(badge.earnedDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, models.Badge badge, bool isEarned) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badge.icon,
              style: TextStyle(
                fontSize: 80,
                color: isEarned ? null : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (isEarned) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Earned on ${DateFormat('MMMM d, y').format(badge.earnedDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  List<models.Badge> _getAllBadges() {
    final now = DateTime.now();
    return [
      models.Badge(
        id: 'first_question',
        name: 'First Steps',
        description: 'Ask your first question',
        earnedDate: now,
        icon: '🎯',
      ),
      models.Badge(
        id: 'streak_3',
        name: '3 Day Streak',
        description: 'Learn for 3 days in a row',
        earnedDate: now,
        icon: '🔥',
      ),
      models.Badge(
        id: 'streak_7',
        name: 'Week Warrior',
        description: 'Maintain a 7 day learning streak',
        earnedDate: now,
        icon: '⚡',
      ),
      models.Badge(
        id: 'practice_10',
        name: 'Practice Makes Perfect',
        description: 'Complete 10 practice sessions',
        earnedDate: now,
        icon: '📝',
      ),
      models.Badge(
        id: 'perfect_score',
        name: 'Perfect Score',
        description: 'Get 100% in a practice session',
        earnedDate: now,
        icon: '💯',
      ),
      models.Badge(
        id: 'math_master',
        name: 'Math Master',
        description: 'Achieve 80% mastery in Mathematics',
        earnedDate: now,
        icon: '🧮',
      ),
      models.Badge(
        id: 'science_star',
        name: 'Science Star',
        description: 'Achieve 80% mastery in Science',
        earnedDate: now,
        icon: '🔬',
      ),
      models.Badge(
        id: 'social_scholar',
        name: 'Social Scholar',
        description: 'Achieve 80% mastery in Social Science',
        earnedDate: now,
        icon: '🌍',
      ),
      models.Badge(
        id: 'speed_solver',
        name: 'Speed Solver',
        description: 'Complete 5 questions in under 2 minutes',
        earnedDate: now,
        icon: '⚡',
      ),
      models.Badge(
        id: 'curious_mind',
        name: 'Curious Mind',
        description: 'Ask 50 questions',
        earnedDate: now,
        icon: '🤔',
      ),
      models.Badge(
        id: 'night_owl',
        name: 'Night Owl',
        description: 'Study after 10 PM',
        earnedDate: now,
        icon: '🦉',
      ),
      models.Badge(
        id: 'early_bird',
        name: 'Early Bird',
        description: 'Study before 7 AM',
        earnedDate: now,
        icon: '🌅',
      ),
    ];
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../models/learning_profile.dart';

class BadgesView extends StatelessWidget {
  const BadgesView({super.key});

  List<Map<String, dynamic>> _getAllBadges() {
    return [
      {
        'id': 'curious_mind',
        'name': 'Curious Mind',
        'description': 'Asked your first question',
        'requirement': 'Ask 1 question',
        'icon': Icons.lightbulb,
        'requiredCount': 1,
        'checkField': 'questionsAsked',
      },
      {
        'id': 'quick_learner',
        'name': 'Quick Learner',
        'description': 'Asked 10 questions',
        'requirement': 'Ask 10 questions',
        'icon': Icons.school,
        'requiredCount': 10,
        'checkField': 'questionsAsked',
      },
      {
        'id': 'practice_starter',
        'name': 'Practice Starter',
        'description': 'Completed your first practice',
        'requirement': 'Complete 1 practice',
        'icon': Icons.fitness_center,
        'requiredCount': 1,
        'checkField': 'practiceCompleted',
      },
      {
        'id': 'dedicated_student',
        'name': 'Dedicated Student',
        'description': 'Completed 20 practice questions',
        'requirement': 'Complete 20 practice questions',
        'icon': Icons.emoji_events,
        'requiredCount': 20,
        'checkField': 'practiceQuestionsCompleted',
      },
      {
        'id': 'on_fire',
        'name': 'On Fire',
        'description': 'Maintained a 3-day learning streak',
        'requirement': '3-day streak',
        'icon': Icons.local_fire_department,
        'requiredCount': 3,
        'checkField': 'streakDays',
      },
      {
        'id': 'unstoppable',
        'name': 'Unstoppable',
        'description': 'Maintained a 7-day learning streak',
        'requirement': '7-day streak',
        'icon': Icons.stars,
        'requiredCount': 7,
        'checkField': 'streakDays',
      },
    ];
  }

  bool _isBadgeEarned(Map<String, dynamic> badge, LearningProfile profile) {
    final checkField = badge['checkField'] as String;
    final requiredCount = badge['requiredCount'] as int;

    int currentCount = 0;
    switch (checkField) {
      case 'questionsAsked':
        currentCount = profile.questionsAsked;
        break;
      case 'practiceCompleted':
        currentCount = profile.practiceCompleted;
        break;
      case 'practiceQuestionsCompleted':
        currentCount = profile.practiceQuestionsCompleted;
        break;
      case 'streakDays':
        currentCount = profile.streakDays;
        break;
    }

    return currentCount >= requiredCount;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final allBadges = _getAllBadges();
    final earnedBadges =
        allBadges.where((badge) => _isBadgeEarned(badge, profile)).toList();
    final lockedBadges =
        allBadges.where((badge) => !_isBadgeEarned(badge, profile)).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Rewards',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Keep learning to unlock more',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${earnedBadges.length}/${allBadges.length}',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Badges Earned',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (lockedBadges.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Text(
                  'Locked (${lockedBadges.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final badge = lockedBadges[index];
                  return _buildBadgeCard(context, badge, false, profile);
                },
                childCount: lockedBadges.length,
              ),
            ),
          ),
          if (earnedBadges.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text(
                  'Earned (${earnedBadges.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final badge = earnedBadges[index];
                    return _buildBadgeCard(context, badge, true, profile);
                  },
                  childCount: earnedBadges.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadgeCard(
    BuildContext context,
    Map<String, dynamic> badge,
    bool isEarned,
    LearningProfile profile,
  ) {
    final checkField = badge['checkField'] as String;
    final requiredCount = badge['requiredCount'] as int;

    int currentCount = 0;
    switch (checkField) {
      case 'questionsAsked':
        currentCount = profile.questionsAsked;
        break;
      case 'practiceCompleted':
        currentCount = profile.practiceCompleted;
        break;
      case 'practiceQuestionsCompleted':
        currentCount = profile.practiceQuestionsCompleted;
        break;
      case 'streakDays':
        currentCount = profile.streakDays;
        break;
    }

    final progress = currentCount / requiredCount;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          width: isEarned ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isEarned
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1)
                      : Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  badge['icon'] as IconData,
                  size: 40,
                  color: isEarned
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                ),
              ),
              if (!isEarned)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              badge['name'] as String,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              badge['requirement'] as String,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isEarned) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Theme.of(context).dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

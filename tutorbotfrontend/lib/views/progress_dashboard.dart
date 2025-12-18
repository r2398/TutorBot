// Stats & progress

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
import '../models/learning_profile.dart';
import '../providers/profile_provider.dart';

class ProgressDashboard extends StatelessWidget {
  const ProgressDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak card
          _buildStreakCard(context, profile),
          const SizedBox(height: 24),

          // Stats grid
          Text(
            'Your Stats',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildStatsGrid(context, profile),
          const SizedBox(height: 24),

          // Subject mastery
          Text(
            'Subject Mastery',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildSubjectMastery(context, profile),
          const SizedBox(height: 24),

          // Strengths and improvements
          Text(
            'Performance Insights',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildInsights(context, profile),
          const SizedBox(height: 24),

          // Recent activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildRecentActivity(context, profile),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, LearningProfile profile) {
    return Card(
      color: Theme.of(context).colorScheme.tertiary,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_fire_department,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.streakDays} Day Streak!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keep it up! Learn every day to maintain your streak.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, LearningProfile profile) {
    final stats = [
      {
        'icon': Icons.timer_outlined,
        'title': 'Study Time',
        'value': '${profile.totalStudyTime} min',
        'color': Colors.blue,
      },
      {
        'icon': Icons.quiz_outlined,
        'title': 'Questions Asked',
        'value': '${profile.questionsAsked}',
        'color': Colors.green,
      },
      {
        'icon': Icons.psychology_outlined,
        'title': 'Practice Done',
        'value': '${profile.practiceCompleted}',
        'color': Colors.orange,
      },
      {
        'icon': Icons.emoji_events_outlined,
        'title': 'Badges Earned',
        'value': '${profile.badges.length}',
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  stat['icon'] as IconData,
                  size: 32,
                  color: stat['color'] as Color,
                ),
                const SizedBox(height: 8),
                Text(
                  stat['value'] as String,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  stat['title'] as String,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectMastery(BuildContext context, LearningProfile profile) {
    // Calculate mastery per subject
    final subjectMastery = <Subject, double>{};
    
    for (var subject in Subject.values) {
      final concepts = profile.conceptMastery
          .where((c) => c.subject == subject)
          .toList();
      
      if (concepts.isNotEmpty) {
        final avgMastery = concepts
            .map((c) => c.masteryLevel)
            .reduce((a, b) => a + b) / concepts.length;
        subjectMastery[subject] = avgMastery;
      } else {
        subjectMastery[subject] = 0;
      }
    }

    return Column(
      children: Subject.values.map((subject) {
        final mastery = subjectMastery[subject] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getSubjectIcon(subject)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          subject.displayName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '${mastery.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: mastery / 100,
                      minHeight: 8,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInsights(BuildContext context, LearningProfile profile) {
    return Column(
      children: [
        if (profile.strengths.isNotEmpty)
          Card(
            color: Colors.green.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Strengths',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.strengths.map((strength) {
                      return Chip(
                        label: Text(strength),
                        backgroundColor: Colors.green.withValues(alpha: 0.2),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        if (profile.areasForImprovement.isNotEmpty)
          Card(
            color: Colors.orange.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Areas for Improvement',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.orange,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.areasForImprovement.map((area) {
                      return Chip(
                        label: Text(area),
                        backgroundColor: Colors.orange.withValues(alpha: 0.2),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, LearningProfile profile) {
    final recentConcepts = profile.conceptMastery
        .toList()
      ..sort((a, b) => b.lastPracticed.compareTo(a.lastPracticed));

    final displayConcepts = recentConcepts.take(5).toList();

    if (displayConcepts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No recent activity yet. Start practicing to see your progress!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Column(
      children: displayConcepts.map((concept) {
        final timeAgo = _getTimeAgo(concept.lastPracticed);
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getMasteryColor(concept.masteryLevel).withValues(alpha: 0.2),
              child: Icon(
                _getSubjectIcon(concept.subject),
                color: _getMasteryColor(concept.masteryLevel),
              ),
            ),
            title: Text(concept.conceptName),
            subtitle: Text('$timeAgo • ${concept.masteryLevel.toStringAsFixed(0)}% mastery'),
            trailing: Icon(
              concept.masteryLevel >= 80
                  ? Icons.check_circle
                  : concept.masteryLevel >= 50
                      ? Icons.trending_up
                      : Icons.trending_flat,
              color: _getMasteryColor(concept.masteryLevel),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getSubjectIcon(Subject subject) {
    switch (subject) {
      case Subject.mathematics:
        return Icons.calculate;
      case Subject.science:
        return Icons.science;
      case Subject.socialScience:
        return Icons.public;
    }
  }

  Color _getMasteryColor(double mastery) {
    if (mastery >= 80) return Colors.green;
    if (mastery >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
// Study goals and plans

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/learning_profile.dart';
import '../providers/profile_provider.dart';

class StudyPlanView extends StatefulWidget {
  const StudyPlanView({super.key});

  @override
  State<StudyPlanView> createState() => _StudyPlanViewState();
}

class _StudyPlanViewState extends State<StudyPlanView> {
  final Uuid _uuid = const Uuid();

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    Subject? selectedSubject;
    DateTime? targetDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Learning Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Title',
                    hintText: 'e.g., Master Quadratic Equations',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Subject>(
                  initialValue: selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                  ),
                  items: Subject.values.map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedSubject = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Target Date'),
                  subtitle: Text(
                    targetDate != null
                        ? DateFormat('MMM d, y').format(targetDate!)
                        : 'Not set',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        targetDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty &&
                    selectedSubject != null &&
                    targetDate != null) {
                  final goal = LearningGoal(
                    id: _uuid.v4(),
                    title: titleController.text.trim(),
                    targetDate: targetDate!,
                    subject: selectedSubject!,
                  );

                  context.read<ProfileProvider>().addLearningGoal(goal);
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeGoals = profile.learningGoals.where((g) => !g.completed).toList();
    final completedGoals = profile.learningGoals.where((g) => g.completed).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Study Plan',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set goals and track your progress',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              FloatingActionButton(
                onPressed: () => _showAddGoalDialog(context),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Active goals
          if (activeGoals.isNotEmpty) ...[
            Text(
              'Active Goals',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ...activeGoals.map((goal) => _buildGoalCard(context, goal, profile)),
            const SizedBox(height: 32),
          ],

          // Completed goals
          if (completedGoals.isNotEmpty) ...[
            Text(
              'Completed Goals',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ...completedGoals.map((goal) => _buildGoalCard(context, goal, profile)),
          ],

          // Empty state
          if (activeGoals.isEmpty && completedGoals.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Learning Goals Yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set your first learning goal to start tracking your progress!',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddGoalDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Goal'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, LearningGoal goal, LearningProfile profile) {
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;
    final isCompleted = goal.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getSubjectIcon(goal.subject),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green)
                else
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        onTap: () {
                          // Implement edit functionality
                        },
                      ),
                      PopupMenuItem(
                        child: const ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                        onTap: () {
                          // Implement delete functionality
                        },
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.progress / 100,
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.progress.toStringAsFixed(0)}% complete',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  isCompleted
                      ? 'Completed!'
                      : isOverdue
                          ? 'Overdue'
                          : '$daysLeft days left',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isCompleted
                            ? Colors.green
                            : isOverdue
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Simulate progress update
                        final newProgress = (goal.progress + 10).clamp(0, 100);
                        context.read<ProfileProvider>().updateGoalProgress(
                              goal.id,
                              newProgress.toDouble(),
                            );
                      },
                      child: const Text('Update Progress'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileProvider>().updateGoalProgress(goal.id, 100);
                    },
                    child: const Text('Mark Complete'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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
}
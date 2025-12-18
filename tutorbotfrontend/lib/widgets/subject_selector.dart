// Subject selection widget

import 'package:flutter/material.dart';
import '../models/learning_profile.dart';

class SubjectSelector extends StatelessWidget {
  final Subject? selectedSubject;
  final Function(Subject) onSubjectSelected;

  const SubjectSelector({
    super.key,
    required this.selectedSubject,
    required this.onSubjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: Subject.values.map((subject) {
        final isSelected = selectedSubject == subject;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => onSubjectSelected(subject),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getSubjectIcon(subject),
                      size: 32,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.displayName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getSubjectDescription(subject),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.8)
                                      : Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  ],
                ),
              ),
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

  String _getSubjectDescription(Subject subject) {
    switch (subject) {
      case Subject.mathematics:
        return 'Numbers, algebra, geometry, and more';
      case Subject.science:
        return 'Physics, chemistry, biology, and nature';
      case Subject.socialScience:
        return 'History, geography, civics, and society';
    }
  }
}
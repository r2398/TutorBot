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
        IconData icon;
        Color color;

        switch (subject) {
          case Subject.mathematics:
            icon = Icons.calculate;
            color = const Color(0xFF4F7BFF);
            break;
          case Subject.science:
            icon = Icons.science;
            color = const Color(0xFF10B981);
            break;
          case Subject.socialScience:
            icon = Icons.public;
            color = const Color(0xFFF59E0B);
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: isSelected
                ? color.withValues(alpha: 0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => onSubjectSelected(subject),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : Theme.of(context).dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      subject.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isSelected ? color : null,
                            fontWeight: FontWeight.w600,
                          ),
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
}
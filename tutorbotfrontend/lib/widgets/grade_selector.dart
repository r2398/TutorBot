import 'package:flutter/material.dart';
import '../models/learning_profile.dart';

class GradeSelector extends StatelessWidget {
  final Grade? selectedGrade;
  final Function(Grade) onGradeSelected;

  const GradeSelector({
    super.key,
    required this.selectedGrade,
    required this.onGradeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: Grade.values.map((grade) {
        final isSelected = selectedGrade == grade;

        return SizedBox(
          width: (MediaQuery.of(context).size.width - 72) / 3,
          child: Material(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => onGradeSelected(grade),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                    width: isSelected ? 0 : 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${grade.number}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
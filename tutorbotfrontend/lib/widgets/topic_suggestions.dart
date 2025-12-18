// Topic suggestions logic

import 'package:flutter/material.dart';
import '../models/learning_profile.dart';
import '../utils/topic_data.dart';

class TopicSuggestions extends StatelessWidget {
  final Subject subject;
  final Grade grade;
  final Function(String) onTopicSelected;

  const TopicSuggestions({
    super.key,
    required this.subject,
    required this.grade,
    required this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context) {
    final topics = TopicData.getTopicSuggestions(subject, grade);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: topics.map((topic) {
        return ActionChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(topic.icon),
              const SizedBox(width: 8),
              Text(topic.title),
            ],
          ),
          onPressed: () => onTopicSelected(topic.title),
        );
      }).toList(),
    );
  }
}
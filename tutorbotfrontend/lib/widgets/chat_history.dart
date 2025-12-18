import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/learning_profile.dart';

class ChatHistory extends StatelessWidget {
  final List<Message> messages;
  final Subject subject;
  final ScrollController scrollController;

  const ChatHistory({
    super.key,
    required this.messages,
    required this.subject,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isStudent = message.role == MessageRole.student;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                isStudent ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isStudent) ...[
                _buildAvatar(context, false),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isStudent
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      topLeft: isStudent ? const Radius.circular(16) : Radius.zero,
                      topRight: isStudent ? Radius.zero : const Radius.circular(16),
                    ),
                    border: isStudent
                        ? null
                        : Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            message.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: isStudent
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (!isStudent && message.relatedConcepts != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: message.relatedConcepts!.map((concept) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                concept,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isStudent) ...[
                const SizedBox(width: 12),
                _buildAvatar(context, true),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context, bool isStudent) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isStudent
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isStudent ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
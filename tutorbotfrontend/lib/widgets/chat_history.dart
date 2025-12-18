// Chat message UndoHistory

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../models/learning_profile.dart';
import '../providers/message_provider.dart';

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
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  child: const Text('A', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isStudent
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isStudent
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isStudent ? 16 : 4),
                          bottomRight: Radius.circular(isStudent ? 4 : 16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.content,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isStudent
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                ),
                          ),
                          if (message.imageUrl != null) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                message.imageUrl!,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('h:mm a').format(message.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (!isStudent && message.hints != null) ...[
                      const SizedBox(height: 8),
                      _buildHintsSection(context, message),
                    ],
                    if (!isStudent && message.hasVideo == true) ...[
                      const SizedBox(height: 8),
                      _buildVideoSection(context, message),
                    ],
                  ],
                ),
              ),
              if (isStudent) ...[
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHintsSection(BuildContext context, Message message) {
    final currentIndex = message.currentHintIndex ?? 0;
    final hasMoreHints = currentIndex < (message.hints?.length ?? 0) - 1;

    return Card(
      color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.01),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hint ${currentIndex + 1}/${message.hints?.length ?? 0}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message.hints![currentIndex],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (hasMoreHints) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  context.read<MessageProvider>().updateMessageHint(
                        subject,
                        message.id,
                        currentIndex + 1,
                      );
                },
                child: const Text('Show next hint'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection(BuildContext context, Message message) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.play_circle_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Watch Video Explanation'),
        subtitle: const Text('Learn this concept visually'),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          // Open video player
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video player coming soon!')),
          );
        },
      ),
    );
  }
}
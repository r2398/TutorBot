import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../models/learning_profile.dart';
import '../providers/message_provider.dart';
import 'typing_indicator.dart';
import 'streaming_text.dart';

class ChatHistory extends StatefulWidget {
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
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.scrollController.hasClients) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: widget.scrollController,
      thickness: 4,
      radius: const Radius.circular(8),
      thumbVisibility: false,
      child: ListView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: widget.messages.length,
        itemBuilder: (context, index) {
          final message = widget.messages[index];
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
                  child: Column(
                    crossAxisAlignment: isStudent
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (message.showTypingIndicator)
                        const TypingIndicator()
                      else
                        _buildMessageBubble(context, message, isStudent),

                      // Hints section
                      if (!isStudent &&
                          !message.isStreaming &&
                          !message.showTypingIndicator &&
                          message.content.isNotEmpty &&
                          message.hints != null &&
                          message.hints!.isNotEmpty)
                        _buildHintsSection(message),
                    ],
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
      ),
    );
  }

  Widget _buildMessageBubble(
      BuildContext context, Message message, bool isStudent) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isStudent
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isStudent ? 20 : 4),
          bottomRight: Radius.circular(isStudent ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: message.isStreaming
          ? StreamingText(
              text: message.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isStudent
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            )
          : Text(
              message.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isStudent
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
    );
  }

  Widget _buildHintsSection(Message message) {
    final currentHint = message.currentHintIndex ?? 0;
    final totalHints = message.hints?.length ?? 0;
    final hasMoreHints = currentHint < totalHints - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(top: 8),
      // FIXED: Match message bubble width
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          // FIXED: High contrast background
          color: isDark
              ? const Color(0xFF1E293B) // Dark slate
              : const Color(0xFFF8FAFC), // Light gray
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF334155) // Lighter border for dark
                : const Color(0xFFE2E8F0), // Darker border for light
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hint header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                        : const Color(0xFF3B82F6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lightbulb,
                    size: 18,
                    color: isDark
                        ? const Color(0xFF60A5FA) // Lighter blue for dark
                        : const Color(0xFF2563EB), // Darker blue for light
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hint ${currentHint + 1} of $totalHints',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          // FIXED: High contrast text
                          color: isDark
                              ? const Color(0xFFF1F5F9) // Almost white
                              : const Color(0xFF0F172A), // Almost black
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (totalHints > 1)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (currentHint + 1) / totalHints,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: isDark
                                    ? const Color(0xFF60A5FA)
                                    : const Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Hint content with high contrast
            Text(
              message.hints![currentHint],
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
                // FIXED: Maximum contrast text
                color: isDark
                    ? const Color(0xFFE2E8F0) // Light gray for dark mode
                    : const Color(0xFF1E293B), // Dark slate for light mode
              ),
            ),

            // Next hint button
            if (hasMoreHints) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final messageProvider = context.read<MessageProvider>();
                    final newHintIndex = currentHint + 1;

                    debugPrint('Showing hint $newHintIndex of $totalHints');

                    final updatedMessage = message.copyWith(
                      currentHintIndex: newHintIndex,
                    );

                    messageProvider.updateMessage(
                        widget.subject, updatedMessage);

                    _scrollToBottom();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(
                    'Show hint ${currentHint + 2} of $totalHints',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],

            // Completion message
            if (!hasMoreHints && totalHints > 1) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF34D399).withValues(alpha: 0.3)
                        : const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF059669),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All hints revealed! Ready to try solving?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isStudent) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isStudent
              ? [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ]
              : [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.7),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isStudent ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

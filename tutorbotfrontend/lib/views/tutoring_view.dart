import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/learning_profile.dart';
import '../models/message.dart';
import '../providers/message_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/tutor_engine.dart';
import '../widgets/chat_history.dart';
import '../widgets/voice_interface_advanced.dart';
import '../widgets/camera_interface.dart';
import '../widgets/custom_loading_indicator.dart';

enum ChatMode { text, voice, camera }

class TutoringView extends StatefulWidget {
  final Subject subject;

  const TutoringView({super.key, required this.subject});

  @override
  State<TutoringView> createState() => _TutoringViewState();
}

class _TutoringViewState extends State<TutoringView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Uuid _uuid = const Uuid();

  ChatMode _currentMode = ChatMode.text;
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String content, {String? imageUrl}) async {
    if (content.trim().isEmpty && imageUrl == null) return;

    final messageProvider = context.read<MessageProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final profile = profileProvider.profile;

    if (profile == null) return;

    debugPrint('Sending message: $content');

    // Add user message
    final studentMessage = Message(
      id: _uuid.v4(),
      role: MessageRole.student,
      content: content.trim(),
      timestamp: DateTime.now(),
      subject: widget.subject,
      imageUrl: imageUrl,
    );

    await messageProvider.addMessage(widget.subject, studentMessage);
    _messageController.clear();
    _scrollToBottom();

    await profileProvider.incrementQuestionsAsked();

    // Show typing indicator
    final typingMessageId = _uuid.v4();
    final typingMessage = Message(
      id: typingMessageId,
      role: MessageRole.tutor,
      content: '',
      timestamp: DateTime.now(),
      subject: widget.subject,
      showTypingIndicator: true,
    );

    debugPrint('Showing typing indicator');
    await messageProvider.addMessage(widget.subject, typingMessage);
    _scrollToBottom();

    setState(() => _isLoading = true);

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Remove typing indicator
    debugPrint('Removing typing indicator');
    await messageProvider.removeMessage(widget.subject, typingMessageId);

    // Get tutor response
    final response = TutorEngine.generateResponse(
      content,
      widget.subject,
      profile.grade,
    );

    debugPrint('Got response with ${response.hints?.length ?? 0} hints');

    // STEP 1: Add ONLY main response with streaming (NO hints)
    final mainMessageId = _uuid.v4();
    final tutorMessage = Message(
      id: mainMessageId,
      role: MessageRole.tutor,
      content: response.response,
      timestamp: DateTime.now(),
      subject: widget.subject,
      isStreaming: true,
      // CRITICAL: Do NOT include hints yet
    );

    debugPrint('Adding message with streaming (NO hints yet)');
    await messageProvider.addMessage(widget.subject, tutorMessage);
    _scrollToBottom();

    setState(() => _isLoading = false);

    // Calculate streaming duration
    final streamDuration = response.response.length * 30;
    debugPrint('Streaming will take ${streamDuration}ms');

    // STEP 2: Wait for streaming to complete
    await Future.delayed(Duration(milliseconds: streamDuration + 500));

    // STEP 3: Update to non-streaming (STILL no hints)
    debugPrint('Streaming complete, updating to non-streaming');
    final completedMessage = tutorMessage.copyWith(
      isStreaming: false,
    );
    await messageProvider.updateMessage(widget.subject, completedMessage);
    _scrollToBottom();

    // STEP 4: Wait before showing hints
    debugPrint('Waiting 1 second before showing hints');
    await Future.delayed(const Duration(milliseconds: 1000));

    // STEP 5: NOW add hints if available
    if (response.hints != null && response.hints!.isNotEmpty) {
      debugPrint('Adding ${response.hints!.length} hints to completed message');

      final messageWithHints = completedMessage.copyWith(
        hints: response.hints,
        currentHintIndex: 0,
        hasVideo: response.hasVideo,
        videoUrl: response.videoUrl,
        relatedConcepts: response.relatedConcepts,
      );

      await messageProvider.updateMessage(widget.subject, messageWithHints);
      _scrollToBottom();

      debugPrint('Hints added successfully');
    } else {
      debugPrint('No hints to add');
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages =
        context.watch<MessageProvider>().getMessages(widget.subject);
    final profile = context.watch<ProfileProvider>().profile;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          // Mode selector
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeButton(
                      mode: ChatMode.voice,
                      icon: Icons.mic,
                      label: 'Voice',
                    ),
                    const SizedBox(width: 12),
                    _buildModeButton(
                      mode: ChatMode.text,
                      icon: Icons.chat_bubble,
                      label: 'Chat',
                    ),
                    const SizedBox(width: 12),
                    _buildModeButton(
                      mode: ChatMode.camera,
                      icon: Icons.camera_alt,
                      label: 'Camera',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content area
          Expanded(
            child: _buildContentArea(messages, profile),
          ),

          // Loading indicator overlay
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: const CustomLoadingIndicator(
                message: 'Thinking...',
              ),
            ),

          // Input area (only for text mode)
          if (_currentMode == ChatMode.text) _buildTextInputArea(),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required ChatMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentMode == mode;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              setState(() {
                _currentMode = mode;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea(List<Message> messages, LearningProfile profile) {
    switch (_currentMode) {
      case ChatMode.text:
        return messages.isEmpty
            ? _buildEmptyState(profile)
            : ChatHistory(
                messages: messages,
                subject: widget.subject,
                scrollController: _scrollController,
              );

      case ChatMode.voice:
        return VoiceInterfaceAdvanced(
          key: const ValueKey('voice_interface'),
          onTextReceived: (text) => _sendMessage(text),
          subject: widget.subject,
        );

      case ChatMode.camera:
        return CameraInterface(
          key: const ValueKey('camera_interface'),
          onImageCaptured: (imagePath, text) {
            _sendMessage(text, imageUrl: imagePath);
          },
        );
    }
  }

  Widget _buildEmptyState(LearningProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.waving_hand,
              size: 50,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ready to Learn',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Ask me anything or tap the mic',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your question here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !_isLoading,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed: _isLoading
                      ? null
                      : () => _sendMessage(_messageController.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

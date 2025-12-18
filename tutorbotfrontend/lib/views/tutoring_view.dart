// Chat/tutor interface

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/learning_profile.dart';
import '../models/message.dart';
import '../providers/message_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/tutor_engine.dart';
import '../widgets/chat_history.dart';
import '../widgets/voice_interface.dart';
import '../widgets/image_upload.dart';
import '../widgets/topic_suggestions.dart';

class TutoringView extends StatefulWidget {
  final Subject subject;

  const TutoringView({super.key, required this.subject});

  @override
  State<TutoringView> createState() => _TutoringViewState();
}

class _TutoringViewState extends State<TutoringView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Uuid _uuid = const Uuid();
  
  bool _isLoading = false;
  String? _uploadedImageUrl;

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

    // Add student message
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
    _uploadedImageUrl = null;
    _scrollToBottom();

    // Increment questions asked
    await profileProvider.incrementQuestionsAsked();

    // Show loading
    setState(() {
      _isLoading = true;
    });

    // Simulate AI response delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate tutor response
    final tutorResponse = TutorEngine.generateResponse(
      content,
      widget.subject,
      profile.grade,
    );

    final tutorMessage = Message(
      id: _uuid.v4(),
      role: MessageRole.tutor,
      content: tutorResponse.response,
      timestamp: DateTime.now(),
      subject: widget.subject,
      hints: tutorResponse.hints,
      currentHintIndex: 0,
      hasVideo: tutorResponse.hasVideo,
      videoUrl: tutorResponse.videoUrl,
      relatedConcepts: tutorResponse.relatedConcepts,
    );

    await messageProvider.addMessage(widget.subject, tutorMessage);

    setState(() {
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _handleVoiceInput(String text) {
    _messageController.text = text;
  }

  void _handleImageUpload(String imageUrl) {
    setState(() {
      _uploadedImageUrl = imageUrl;
    });
  }

  void _handleTopicSuggestion(String topic) {
    _sendMessage('Can you help me understand $topic?');
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<MessageProvider>().getMessages(widget.subject);
    final profile = context.watch<ProfileProvider>().profile;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Welcome message or chat history
        Expanded(
          child: messages.isEmpty
              ? _buildWelcomeScreen(profile)
              : ChatHistory(
                  messages: messages,
                  subject: widget.subject,
                  scrollController: _scrollController,
                ),
        ),

        // Loading indicator
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(
                  'Thinking...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

        // Image preview
        if (_uploadedImageUrl != null)
          Container(
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.secondary,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _uploadedImageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Image attached'),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _uploadedImageUrl = null;
                    });
                  },
                ),
              ],
            ),
          ),

        // Input area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Image upload button
                ImageUpload(
                  onImageSelected: _handleImageUpload,
                ),
                const SizedBox(width: 8),

                // Text input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything about ${widget.subject.displayName}...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (value) => _sendMessage(value, imageUrl: _uploadedImageUrl),
                  ),
                ),
                const SizedBox(width: 8),

                // Voice input button
                VoiceInterface(
                  onTextReceived: _handleVoiceInput,
                ),
                const SizedBox(width: 8),

                // Send button
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () => _sendMessage(
                      _messageController.text,
                      imageUrl: _uploadedImageUrl,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeScreen(LearningProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi ${profile.studentName}! 👋',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'I\'m Tutor Anna, your AI tutor. Ask me anything about ${widget.subject.displayName}!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Text(
            'Popular topics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TopicSuggestions(
            subject: widget.subject,
            grade: profile.grade,
            onTopicSelected: _handleTopicSuggestion,
          ),
          const SizedBox(height: 32),
          _buildFeatureCard(
            icon: Icons.mic,
            title: 'Voice Input',
            description: 'Ask questions using your voice',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.photo_camera,
            title: 'Image Upload',
            description: 'Upload images of problems to solve',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.lightbulb_outline,
            title: 'Step-by-step Hints',
            description: 'Get hints when you\'re stuck',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.play_circle_outline,
            title: 'Video Resources',
            description: 'Watch videos to learn concepts',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'learning_profile.dart';

enum MessageRole { student, tutor }

class Message {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final Subject? subject;
  final String? imageUrl;
  final List<String>? hints;
  final int? currentHintIndex;
  final bool? hasVideo;
  final String? videoUrl;
  final List<String>? relatedConcepts;
  final bool isStreaming;
  final bool showTypingIndicator;

  Message({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.subject,
    this.imageUrl,
    this.hints,
    this.currentHintIndex,
    this.hasVideo,
    this.videoUrl,
    this.relatedConcepts,
    this.isStreaming = false,
    this.showTypingIndicator = false,
  });

  Message copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    Subject? subject,
    String? imageUrl,
    List<String>? hints,
    int? currentHintIndex,
    bool? hasVideo,
    String? videoUrl,
    List<String>? relatedConcepts,
    bool? isStreaming,
    bool? showTypingIndicator,
  }) {
    return Message(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      subject: subject ?? this.subject,
      imageUrl: imageUrl ?? this.imageUrl,
      hints: hints ?? this.hints,
      // FIXED: Properly handle nullable int
      currentHintIndex: currentHintIndex ?? this.currentHintIndex,
      hasVideo: hasVideo ?? this.hasVideo,
      videoUrl: videoUrl ?? this.videoUrl,
      relatedConcepts: relatedConcepts ?? this.relatedConcepts,
      isStreaming: isStreaming ?? this.isStreaming,
      showTypingIndicator: showTypingIndicator ?? this.showTypingIndicator,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'subject': subject?.name,
        'imageUrl': imageUrl,
        'hints': hints,
        'currentHintIndex': currentHintIndex,
        'hasVideo': hasVideo,
        'videoUrl': videoUrl,
        'relatedConcepts': relatedConcepts,
        'isStreaming': isStreaming,
        'showTypingIndicator': showTypingIndicator,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        role: MessageRole.values.firstWhere((e) => e.name == json['role']),
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
        subject: json['subject'] != null
            ? Subject.values.firstWhere((e) => e.name == json['subject'])
            : null,
        imageUrl: json['imageUrl'],
        hints: json['hints'] != null ? List<String>.from(json['hints']) : null,
        currentHintIndex: json['currentHintIndex'],
        hasVideo: json['hasVideo'],
        videoUrl: json['videoUrl'],
        relatedConcepts: json['relatedConcepts'] != null
            ? List<String>.from(json['relatedConcepts'])
            : null,
        isStreaming: json['isStreaming'] ?? false,
        showTypingIndicator: json['showTypingIndicator'] ?? false,
      );
}

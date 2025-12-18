// AI tutor response logic

import 'dart:math';
import '../models/learning_profile.dart';

class TutorResponse {
  final String response;
  final List<String>? hints;
  final bool hasVideo;
  final String? videoUrl;
  final List<String>? relatedConcepts;

  TutorResponse({
    required this.response,
    this.hints,
    this.hasVideo = false,
    this.videoUrl,
    this.relatedConcepts,
  });
}

class TutorEngine {
  static final Random _random = Random();

  static TutorResponse generateResponse(String question, Subject subject, Grade grade) {
    // Simulate AI response based on question keywords
    final lowerQuestion = question.toLowerCase();
    
    if (lowerQuestion.contains('solve') || lowerQuestion.contains('calculate')) {
      return _generateMathResponse(question, subject);
    } else if (lowerQuestion.contains('explain') || lowerQuestion.contains('what is')) {
      return _generateExplanationResponse(question, subject);
    } else if (lowerQuestion.contains('how') || lowerQuestion.contains('why')) {
      return _generateConceptualResponse(question, subject);
    } else {
      return _generateGeneralResponse(question, subject);
    }
  }

  static TutorResponse _generateMathResponse(String question, Subject subject) {
    return TutorResponse(
      response: "Let me help you solve this problem step by step!\n\n"
          "1. First, identify what we need to find\n"
          "2. Write down the given information\n"
          "3. Apply the appropriate formula or method\n"
          "4. Calculate the result\n\n"
          "Would you like me to show you a worked example?",
      hints: [
        "Start by identifying the known values",
        "Think about which formula applies here",
        "Work through each step carefully",
      ],
      hasVideo: true,
      videoUrl: "https://example.com/video",
      relatedConcepts: ["Algebra", "Problem Solving", "Mathematical Operations"],
    );
  }

  static TutorResponse _generateExplanationResponse(String question, Subject subject) {
    final explanations = {
      Subject.mathematics: "Great question! Let me explain this concept clearly.\n\n"
          "This is a fundamental concept in mathematics that helps us understand patterns and relationships. "
          "Think of it as a tool that makes complex problems easier to solve.\n\n"
          "Would you like to see some examples?",
      Subject.science: "Excellent question! Let me break this down for you.\n\n"
          "In science, we observe that this phenomenon occurs because of specific principles. "
          "Understanding these principles helps us predict and explain what happens in the natural world.\n\n"
          "Shall I show you a real-world example?",
      Subject.socialScience: "That's an important question! Let me explain.\n\n"
          "This concept is crucial for understanding how our society and world function. "
          "It has historical significance and continues to impact us today.\n\n"
          "Would you like to explore this topic further?",
    };

    return TutorResponse(
      response: explanations[subject]!,
      hints: [
        "Think about the core principle",
        "Consider real-world applications",
        "Connect it to what you already know",
      ],
      hasVideo: _random.nextBool(),
      relatedConcepts: ["Core Concepts", "Applications", "Examples"],
    );
  }

  static TutorResponse _generateConceptualResponse(String question, Subject subject) {
    return TutorResponse(
      response: "That's a thoughtful question! Let me help you understand.\n\n"
          "This concept works because of several key factors:\n"
          "• First, we need to consider the fundamental principles\n"
          "• Second, there are specific conditions that apply\n"
          "• Finally, we can see the effects in various situations\n\n"
          "Understanding the 'why' is just as important as knowing the 'what'!\n\n"
          "Would you like me to explain any part in more detail?",
      hints: [
        "Think about cause and effect",
        "Consider the underlying principles",
        "Look for patterns",
      ],
      hasVideo: true,
      relatedConcepts: ["Fundamental Concepts", "Cause and Effect", "Applications"],
    );
  }

  static TutorResponse _generateGeneralResponse(String question, Subject subject) {
    return TutorResponse(
      response: "I'm here to help you learn! Let's explore this together.\n\n"
          "Can you tell me:\n"
          "• What specifically would you like to understand?\n"
          "• Have you tried solving this before?\n"
          "• What part seems most challenging?\n\n"
          "The more specific you are, the better I can help you!",
      hints: [
        "Try breaking the problem into smaller parts",
        "Review related concepts you've learned",
        "Don't hesitate to ask for clarification",
      ],
      hasVideo: false,
      relatedConcepts: ["Problem Solving", "Learning Strategies"],
    );
  }

  static List<String> generateHints(String question, Subject subject) {
    final genericHints = [
      "Think about what you already know about this topic",
      "Break the problem down into smaller steps",
      "Look for patterns or relationships",
      "Consider drawing a diagram or visualization",
      "Try working backwards from what you want to find",
    ];

    return genericHints..shuffle();
  }

  static List<String> suggestVideos(String topic, Subject subject) {
    // In a real app, this would fetch actual video resources
    return [
      "Introduction to $topic",
      "$topic Explained Simply",
      "Advanced $topic Concepts",
      "$topic Practice Problems",
    ];
  }
}
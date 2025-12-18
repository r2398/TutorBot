// Practice questions

enum Difficulty { basic, intermediate, advanced }

extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.basic:
        return 'Basic';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }
}

class PracticeQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String? hint;
  final Difficulty difficulty;
  final String concept;
  final String conceptId;

  PracticeQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.hint,
    required this.difficulty,
    required this.concept,
    required this.conceptId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'correctAnswer': correctAnswer,
    'explanation': explanation,
    'hint': hint,
    'difficulty': difficulty.name,
    'concept': concept,
    'conceptId': conceptId,
  };

  factory PracticeQuestion.fromJson(Map<String, dynamic> json) => PracticeQuestion(
    id: json['id'],
    question: json['question'],
    options: List<String>.from(json['options']),
    correctAnswer: json['correctAnswer'],
    explanation: json['explanation'],
    hint: json['hint'],
    difficulty: Difficulty.values.firstWhere((e) => e.name == json['difficulty']),
    concept: json['concept'],
    conceptId: json['conceptId'],
  );
}
import 'dart:math';
import '../models/practice_question.dart';
import '../models/learning_profile.dart';

class PracticeGenerator {
  static List<PracticeQuestion> generateQuestions(
    Subject subject,
    Grade grade,
    int count, {
    String difficulty = 'Easy',
  }) {
    final Difficulty difficultyEnum = _parseDifficulty(difficulty);
    final List<PracticeQuestion> questions = [];
    final random = Random();

    for (int i = 0; i < count; i++) {
      questions.add(_generateQuestion(subject, grade, difficultyEnum, random));
    }

    return questions;
  }

  static Difficulty _parseDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Difficulty.basic;
      case 'medium':
        return Difficulty.intermediate;
      case 'hard':
        return Difficulty.advanced;
      default:
        return Difficulty.basic;
    }
  }

  static PracticeQuestion _generateQuestion(
    Subject subject,
    Grade grade,
    Difficulty difficulty,
    Random random,
  ) {
    switch (subject) {
      case Subject.mathematics:
        return _generateMathQuestion(grade, difficulty, random);
      case Subject.science:
        return _generateScienceQuestion(grade, difficulty, random);
      case Subject.socialScience:
        return _generateSocialScienceQuestion(grade, difficulty, random);
    }
  }

  static PracticeQuestion _generateMathQuestion(
    Grade grade,
    Difficulty difficulty,
    Random random,
  ) {
    final int a = random.nextInt(20) + 1;
    final int b = random.nextInt(20) + 1;
    final int correctAnswer = a + b;

    final List<String> options = [
      correctAnswer.toString(),
      (correctAnswer + 1).toString(),
      (correctAnswer - 1).toString(),
      (correctAnswer + 2).toString(),
    ];
    options.shuffle(random);

    return PracticeQuestion(
      id: 'math_${random.nextInt(10000)}',
      conceptId: 'addition',
      concept: 'Basic Addition',
      question: 'What is $a + $b?',
      options: options,
      correctAnswer: correctAnswer.toString(),
      explanation: 'Adding $a and $b gives you $correctAnswer.',
      difficulty: difficulty,
    );
  }

  static PracticeQuestion _generateScienceQuestion(
    Grade grade,
    Difficulty difficulty,
    Random random,
  ) {
    final questions = [
      {
        'question': 'What is the chemical symbol for water?',
        'options': ['H2O', 'CO2', 'O2', 'N2'],
        'answer': 'H2O',
        'explanation':
            'Water is composed of two hydrogen atoms and one oxygen atom.',
        'concept': 'Chemical Formulas',
      },
      {
        'question': 'What planet is known as the Red Planet?',
        'options': ['Mars', 'Venus', 'Jupiter', 'Saturn'],
        'answer': 'Mars',
        'explanation': 'Mars appears red due to iron oxide on its surface.',
        'concept': 'Solar System',
      },
    ];

    final q = questions[random.nextInt(questions.length)];

    return PracticeQuestion(
      id: 'science_${random.nextInt(10000)}',
      conceptId: 'science_basics',
      concept: q['concept'] as String,
      question: q['question'] as String,
      options: q['options'] as List<String>,
      correctAnswer: q['answer'] as String,
      explanation: q['explanation'] as String,
      difficulty: difficulty,
    );
  }

  static PracticeQuestion _generateSocialScienceQuestion(
    Grade grade,
    Difficulty difficulty,
    Random random,
  ) {
    final questions = [
      {
        'question': 'Who was the first President of the United States?',
        'options': [
          'George Washington',
          'Thomas Jefferson',
          'Abraham Lincoln',
          'John Adams'
        ],
        'answer': 'George Washington',
        'explanation':
            'George Washington served as the first U.S. President from 1789-1797.',
        'concept': 'American History',
      },
      {
        'question': 'What is the capital of France?',
        'options': ['Paris', 'London', 'Berlin', 'Rome'],
        'answer': 'Paris',
        'explanation': 'Paris has been the capital of France for centuries.',
        'concept': 'World Geography',
      },
    ];

    final q = questions[random.nextInt(questions.length)];

    return PracticeQuestion(
      id: 'social_${random.nextInt(10000)}',
      conceptId: 'social_basics',
      concept: q['concept'] as String,
      question: q['question'] as String,
      options: q['options'] as List<String>,
      correctAnswer: q['answer'] as String,
      explanation: q['explanation'] as String,
      difficulty: difficulty,
    );
  }
}

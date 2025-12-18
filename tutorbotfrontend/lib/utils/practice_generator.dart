// Practice questions generator

import 'dart:math';
import '../models/practice_question.dart';
import '../models/learning_profile.dart';

class PracticeGenerator {
  static final Random _random = Random();

  static List<PracticeQuestion> generateQuestions({
    required Subject subject,
    required Grade grade,
    required Difficulty difficulty,
    int count = 5,
  }) {
    switch (subject) {
      case Subject.mathematics:
        return _generateMathQuestions(grade, difficulty, count);
      case Subject.science:
        return _generateScienceQuestions(grade, difficulty, count);
      case Subject.socialScience:
        return _generateSocialScienceQuestions(grade, difficulty, count);
    }
  }

  static List<PracticeQuestion> _generateMathQuestions(
    Grade grade,
    Difficulty difficulty,
    int count,
  ) {
    final questions = <PracticeQuestion>[];
    final gradeNum = grade.number;

    for (int i = 0; i < count; i++) {
      if (gradeNum <= 8) {
        questions.add(_generateBasicMathQuestion(i, difficulty));
      } else {
        questions.add(_generateAdvancedMathQuestion(i, difficulty));
      }
    }

    return questions;
  }

  static PracticeQuestion _generateBasicMathQuestion(int index, Difficulty difficulty) {
    final int a = difficulty == Difficulty.basic
        ? _random.nextInt(20) + 1
        : _random.nextInt(50) + 10;
    final int b = difficulty == Difficulty.basic
        ? _random.nextInt(20) + 1
        : _random.nextInt(50) + 10;
    
    final operations = ['+', '-', '×', '÷'];
    final operation = operations[_random.nextInt(operations.length)];
    
    int answer;
    String question;
    
    switch (operation) {
      case '+':
        answer = a + b;
        question = 'What is $a + $b?';
        break;
      case '-':
        answer = a - b;
        question = 'What is $a - $b?';
        break;
      case '×':
        answer = a * b;
        question = 'What is $a × $b?';
        break;
      case '÷':
        final divisor = b == 0 ? 1 : b;
        answer = (a / divisor).round();
        question = 'What is $a ÷ $divisor (rounded)?';
        break;
      default:
        answer = 0;
        question = '';
    }

    final options = _generateOptions(answer, 4);

    return PracticeQuestion(
      id: 'q_$index',
      question: question,
      options: options,
      correctAnswer: answer.toString(),
      explanation: 'The correct answer is $answer. $operation operation gives us this result.',
      hint: 'Try solving step by step',
      difficulty: difficulty,
      concept: 'Basic Arithmetic',
      conceptId: 'arithmetic_basic',
    );
  }

  static PracticeQuestion _generateAdvancedMathQuestion(int index, Difficulty difficulty) {
    final questionTypes = [
      'algebra',
      'geometry',
      'trigonometry',
    ];
    
    final type = questionTypes[_random.nextInt(questionTypes.length)];
    
    switch (type) {
      case 'algebra':
        final x = _random.nextInt(10) + 1;
        final c = _random.nextInt(20) + 1;
        final answer = x;
        final options = _generateOptions(answer, 4);
        
        return PracticeQuestion(
          id: 'q_$index',
          question: 'Solve for x: 2x + $c = ${2 * x + c}',
          options: options,
          correctAnswer: answer.toString(),
          explanation: 'Subtract $c from both sides, then divide by 2 to get x = $answer',
          hint: 'Isolate the variable x',
          difficulty: difficulty,
          concept: 'Linear Equations',
          conceptId: 'algebra_linear',
        );
        
      case 'geometry':
        final base = _random.nextInt(10) + 5;
        final height = _random.nextInt(10) + 5;
        final answer = (0.5 * base * height).round();
        final options = _generateOptions(answer, 4);
        
        return PracticeQuestion(
          id: 'q_$index',
          question: 'What is the area of a triangle with base $base cm and height $height cm?',
          options: options.map((e) => '$e cm²').toList(),
          correctAnswer: '$answer cm²',
          explanation: 'Area of triangle = ½ × base × height = ½ × $base × $height = $answer cm²',
          hint: 'Use the formula: Area = ½ × base × height',
          difficulty: difficulty,
          concept: 'Area of Triangles',
          conceptId: 'geometry_area',
        );
        
      default:
        final angle = [30, 45, 60, 90][_random.nextInt(4)];
        final sinValues = {30: 0.5, 45: 0.707, 60: 0.866, 90: 1.0};
        final answer = sinValues[angle]!;
        final options = ['0.5', '0.707', '0.866', '1.0'];
        
        return PracticeQuestion(
          id: 'q_$index',
          question: 'What is sin($angle°)?',
          options: options,
          correctAnswer: answer.toString(),
          explanation: 'sin($angle°) = $answer. This is a standard trigonometric value.',
          hint: 'Remember the standard angles',
          difficulty: difficulty,
          concept: 'Trigonometric Ratios',
          conceptId: 'trig_ratios',
        );
    }
  }

  static List<PracticeQuestion> _generateScienceQuestions(
    Grade grade,
    Difficulty difficulty,
    int count,
  ) {
    // final questions = <PracticeQuestion>[];
    
    final scienceQuestions = [
      PracticeQuestion(
        id: 'sci_1',
        question: 'What is the process by which plants make food?',
        options: ['Photosynthesis', 'Respiration', 'Digestion', 'Reproduction'],
        correctAnswer: 'Photosynthesis',
        explanation: 'Photosynthesis is the process where plants use sunlight to convert carbon dioxide and water into glucose and oxygen.',
        hint: 'Think about what plants need sunlight for',
        difficulty: difficulty,
        concept: 'Plant Biology',
        conceptId: 'bio_plants',
      ),
      PracticeQuestion(
        id: 'sci_2',
        question: 'What is the chemical symbol for water?',
        options: ['H2O', 'CO2', 'O2', 'NaCl'],
        correctAnswer: 'H2O',
        explanation: 'Water is composed of two hydrogen atoms and one oxygen atom, hence H2O.',
        hint: 'Water contains hydrogen and oxygen',
        difficulty: difficulty,
        concept: 'Chemical Formulas',
        conceptId: 'chem_formulas',
      ),
      PracticeQuestion(
        id: 'sci_3',
        question: 'What force pulls objects toward Earth?',
        options: ['Gravity', 'Friction', 'Magnetism', 'Inertia'],
        correctAnswer: 'Gravity',
        explanation: 'Gravity is the force that attracts objects with mass toward each other, particularly toward Earth\'s center.',
        hint: 'Think about why things fall down',
        difficulty: difficulty,
        concept: 'Forces',
        conceptId: 'phys_forces',
      ),
      PracticeQuestion(
        id: 'sci_4',
        question: 'What is the powerhouse of the cell?',
        options: ['Mitochondria', 'Nucleus', 'Ribosome', 'Chloroplast'],
        correctAnswer: 'Mitochondria',
        explanation: 'Mitochondria produce energy (ATP) for the cell through cellular respiration.',
        hint: 'This organelle produces energy',
        difficulty: difficulty,
        concept: 'Cell Biology',
        conceptId: 'bio_cells',
      ),
      PracticeQuestion(
        id: 'sci_5',
        question: 'What is the speed of light?',
        options: ['300,000 km/s', '150,000 km/s', '450,000 km/s', '600,000 km/s'],
        correctAnswer: '300,000 km/s',
        explanation: 'Light travels at approximately 300,000 kilometers per second in a vacuum.',
        hint: 'It\'s a very high speed',
        difficulty: difficulty,
        concept: 'Light',
        conceptId: 'phys_light',
      ),
    ];

    return scienceQuestions.take(count).toList();
  }

  static List<PracticeQuestion> _generateSocialScienceQuestions(
    Grade grade,
    Difficulty difficulty,
    int count,
  ) {
    // final questions = <PracticeQuestion>[];
    
    final socialQuestions = [
      PracticeQuestion(
        id: 'ss_1',
        question: 'Who was the first Prime Minister of India?',
        options: ['Jawaharlal Nehru', 'Mahatma Gandhi', 'Sardar Patel', 'Dr. Rajendra Prasad'],
        correctAnswer: 'Jawaharlal Nehru',
        explanation: 'Jawaharlal Nehru became India\'s first Prime Minister on August 15, 1947.',
        hint: 'He was a close associate of Gandhi',
        difficulty: difficulty,
        concept: 'Indian History',
        conceptId: 'hist_modern',
      ),
      PracticeQuestion(
        id: 'ss_2',
        question: 'What is the capital of India?',
        options: ['New Delhi', 'Mumbai', 'Kolkata', 'Chennai'],
        correctAnswer: 'New Delhi',
        explanation: 'New Delhi is the capital city of India and houses the Parliament and President\'s residence.',
        hint: 'It\'s in the northern part of India',
        difficulty: difficulty,
        concept: 'Geography',
        conceptId: 'geo_india',
      ),
      PracticeQuestion(
        id: 'ss_3',
        question: 'What type of government does India have?',
        options: ['Democracy', 'Monarchy', 'Dictatorship', 'Oligarchy'],
        correctAnswer: 'Democracy',
        explanation: 'India is a democratic republic where citizens elect their representatives.',
        hint: 'People elect their leaders',
        difficulty: difficulty,
        concept: 'Civics',
        conceptId: 'civics_govt',
      ),
      PracticeQuestion(
        id: 'ss_4',
        question: 'Which river is known as the Ganges?',
        options: ['Ganga', 'Yamuna', 'Brahmaputra', 'Narmada'],
        correctAnswer: 'Ganga',
        explanation: 'The Ganga (Ganges) is one of the most sacred rivers in India, flowing through northern India.',
        hint: 'It\'s a sacred river',
        difficulty: difficulty,
        concept: 'Geography',
        conceptId: 'geo_rivers',
      ),
      PracticeQuestion(
        id: 'ss_5',
        question: 'In which year did India gain independence?',
        options: ['1947', '1950', '1942', '1945'],
        correctAnswer: '1947',
        explanation: 'India gained independence from British rule on August 15, 1947.',
        hint: 'It was after World War II',
        difficulty: difficulty,
        concept: 'Indian History',
        conceptId: 'hist_independence',
      ),
    ];

    return socialQuestions.take(count).toList();
  }

  static List<String> _generateOptions(int correctAnswer, int optionCount) {
    final options = <String>[correctAnswer.toString()];
    final used = <int>{correctAnswer};

    while (options.length < optionCount) {
      final offset = _random.nextInt(10) + 1;
      final wrongAnswer = _random.nextBool()
          ? correctAnswer + offset
          : correctAnswer - offset;
      
      if (!used.contains(wrongAnswer) && wrongAnswer > 0) {
        options.add(wrongAnswer.toString());
        used.add(wrongAnswer);
      }
    }

    options.shuffle();
    return options;
  }
}
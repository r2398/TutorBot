// Topic suggestions logic

import '../models/learning_profile.dart';

class TopicSuggestion {
  final String id;
  final String title;
  final String description;
  final Subject subject;
  final Grade? grade;
  final String icon;

  TopicSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    this.grade,
    required this.icon,
  });
}

class TopicData {
  static List<TopicSuggestion> getTopicSuggestions(Subject subject, Grade grade) {
    final gradeNum = grade.number;
    
    switch (subject) {
      case Subject.mathematics:
        return _getMathematicsTopics(gradeNum);
      case Subject.science:
        return _getScienceTopics(gradeNum);
      case Subject.socialScience:
        return _getSocialScienceTopics(gradeNum);
    }
  }

  static List<TopicSuggestion> _getMathematicsTopics(int grade) {
    if (grade <= 8) {
      return [
        TopicSuggestion(
          id: 'math_1',
          title: 'Fractions & Decimals',
          description: 'Learn about fractions and decimal operations',
          subject: Subject.mathematics,
          icon: '🔢',
        ),
        TopicSuggestion(
          id: 'math_2',
          title: 'Geometry Basics',
          description: 'Understand shapes, angles, and measurements',
          subject: Subject.mathematics,
          icon: '📐',
        ),
        TopicSuggestion(
          id: 'math_3',
          title: 'Algebra Introduction',
          description: 'Start with variables and simple equations',
          subject: Subject.mathematics,
          icon: '🧮',
        ),
        TopicSuggestion(
          id: 'math_4',
          title: 'Data Handling',
          description: 'Charts, graphs, and statistics',
          subject: Subject.mathematics,
          icon: '📊',
        ),
      ];
    } else {
      return [
        TopicSuggestion(
          id: 'math_5',
          title: 'Quadratic Equations',
          description: 'Solve and graph quadratic equations',
          subject: Subject.mathematics,
          icon: '📈',
        ),
        TopicSuggestion(
          id: 'math_6',
          title: 'Trigonometry',
          description: 'Learn about sine, cosine, and tangent',
          subject: Subject.mathematics,
          icon: '📐',
        ),
        TopicSuggestion(
          id: 'math_7',
          title: 'Calculus Basics',
          description: 'Introduction to derivatives and integrals',
          subject: Subject.mathematics,
          icon: '∫',
        ),
        TopicSuggestion(
          id: 'math_8',
          title: 'Probability & Statistics',
          description: 'Advanced data analysis and probability',
          subject: Subject.mathematics,
          icon: '🎲',
        ),
      ];
    }
  }

  static List<TopicSuggestion> _getScienceTopics(int grade) {
    if (grade <= 8) {
      return [
        TopicSuggestion(
          id: 'sci_1',
          title: 'Plants & Animals',
          description: 'Learn about living organisms',
          subject: Subject.science,
          icon: '🌱',
        ),
        TopicSuggestion(
          id: 'sci_2',
          title: 'Light & Sound',
          description: 'Understand waves and energy',
          subject: Subject.science,
          icon: '💡',
        ),
        TopicSuggestion(
          id: 'sci_3',
          title: 'Matter & Materials',
          description: 'Properties and changes in matter',
          subject: Subject.science,
          icon: '⚗️',
        ),
        TopicSuggestion(
          id: 'sci_4',
          title: 'Force & Motion',
          description: 'Newton\'s laws and mechanics',
          subject: Subject.science,
          icon: '🚀',
        ),
      ];
    } else {
      return [
        TopicSuggestion(
          id: 'sci_5',
          title: 'Chemical Reactions',
          description: 'Understand chemical equations and reactions',
          subject: Subject.science,
          icon: '🧪',
        ),
        TopicSuggestion(
          id: 'sci_6',
          title: 'Electricity & Magnetism',
          description: 'Learn about circuits and electromagnetic fields',
          subject: Subject.science,
          icon: '⚡',
        ),
        TopicSuggestion(
          id: 'sci_7',
          title: 'Genetics & Evolution',
          description: 'DNA, inheritance, and natural selection',
          subject: Subject.science,
          icon: '🧬',
        ),
        TopicSuggestion(
          id: 'sci_8',
          title: 'Atomic Structure',
          description: 'Atoms, electrons, and periodic table',
          subject: Subject.science,
          icon: '⚛️',
        ),
      ];
    }
  }

  static List<TopicSuggestion> _getSocialScienceTopics(int grade) {
    return [
      TopicSuggestion(
        id: 'ss_1',
        title: 'Indian History',
        description: 'Ancient, medieval, and modern India',
        subject: Subject.socialScience,
        icon: '🏛️',
      ),
      TopicSuggestion(
        id: 'ss_2',
        title: 'Geography',
        description: 'Physical and political geography',
        subject: Subject.socialScience,
        icon: '🗺️',
      ),
      TopicSuggestion(
        id: 'ss_3',
        title: 'Civics & Government',
        description: 'Democracy, rights, and governance',
        subject: Subject.socialScience,
        icon: '⚖️',
      ),
      TopicSuggestion(
        id: 'ss_4',
        title: 'Economics',
        description: 'Money, trade, and economic systems',
        subject: Subject.socialScience,
        icon: '💰',
      ),
    ];
  }
}
// Profile, Badge, Goal, ConceptMastery

enum Subject { mathematics, science, socialScience }

enum Grade { six, seven, eight, nine, ten, eleven, twelve }

enum Language {
  english, hindi, tamil, telugu, bengali, marathi, gujarati,
  kannada, malayalam, punjabi, odia, assamese
}

extension GradeExtension on Grade {
  int get number => index + 6;
  
  static Grade fromNumber(int number) {
    return Grade.values[number - 6];
  }
}

extension SubjectExtension on Subject {
  String get displayName {
    switch (this) {
      case Subject.mathematics:
        return 'Mathematics';
      case Subject.science:
        return 'Science';
      case Subject.socialScience:
        return 'Social Science';
    }
  }
}

extension LanguageExtension on Language {
  String get displayName {
    switch (this) {
      case Language.english:
        return 'English';
      case Language.hindi:
        return 'हिंदी';
      case Language.tamil:
        return 'தமிழ்';
      case Language.telugu:
        return 'తెలుగు';
      case Language.bengali:
        return 'বাংলা';
      case Language.marathi:
        return 'मराठी';
      case Language.gujarati:
        return 'ગુજરાતી';
      case Language.kannada:
        return 'ಕನ್ನಡ';
      case Language.malayalam:
        return 'മലയാളം';
      case Language.punjabi:
        return 'ਪੰਜਾਬੀ';
      case Language.odia:
        return 'ଓଡ଼ିଆ';
      case Language.assamese:
        return 'অসমীয়া';
    }
  }
}

class ConceptMastery {
  final String conceptId;
  final String conceptName;
  final Subject subject;
  double masteryLevel;
  DateTime lastPracticed;
  int attemptsCount;
  double successRate;
  List<String> commonErrors;

  ConceptMastery({
    required this.conceptId,
    required this.conceptName,
    required this.subject,
    this.masteryLevel = 0,
    required this.lastPracticed,
    this.attemptsCount = 0,
    this.successRate = 0,
    this.commonErrors = const [],
  });

  Map<String, dynamic> toJson() => {
    'conceptId': conceptId,
    'conceptName': conceptName,
    'subject': subject.name,
    'masteryLevel': masteryLevel,
    'lastPracticed': lastPracticed.toIso8601String(),
    'attemptsCount': attemptsCount,
    'successRate': successRate,
    'commonErrors': commonErrors,
  };

  factory ConceptMastery.fromJson(Map<String, dynamic> json) => ConceptMastery(
    conceptId: json['conceptId'],
    conceptName: json['conceptName'],
    subject: Subject.values.firstWhere((e) => e.name == json['subject']),
    masteryLevel: json['masteryLevel'].toDouble(),
    lastPracticed: DateTime.parse(json['lastPracticed']),
    attemptsCount: json['attemptsCount'],
    successRate: json['successRate'].toDouble(),
    commonErrors: List<String>.from(json['commonErrors'] ?? []),
  );
}

class LearningGoal {
  final String id;
  final String title;
  final DateTime targetDate;
  double progress;
  final Subject subject;
  bool completed;

  LearningGoal({
    required this.id,
    required this.title,
    required this.targetDate,
    this.progress = 0,
    required this.subject,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetDate': targetDate.toIso8601String(),
    'progress': progress,
    'subject': subject.name,
    'completed': completed,
  };

  factory LearningGoal.fromJson(Map<String, dynamic> json) => LearningGoal(
    id: json['id'],
    title: json['title'],
    targetDate: DateTime.parse(json['targetDate']),
    progress: json['progress'].toDouble(),
    subject: Subject.values.firstWhere((e) => e.name == json['subject']),
    completed: json['completed'],
  );
}

class Badge {
  final String id;
  final String name;
  final String description;
  final DateTime earnedDate;
  final String icon;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.earnedDate,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'earnedDate': earnedDate.toIso8601String(),
    'icon': icon,
  };

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    earnedDate: DateTime.parse(json['earnedDate']),
    icon: json['icon'],
  );
}

class LearningProfile {
  final String studentName;
  final Grade grade;
  final Language preferredLanguage;
  final Subject preferredSubject;
  String? apaarId;
  List<ConceptMastery> conceptMastery;
  List<LearningGoal> learningGoals;
  List<Badge> badges;
  int totalStudyTime;
  int questionsAsked;
  int practiceCompleted;
  int streakDays;
  DateTime lastActive;
  List<String> strengths;
  List<String> areasForImprovement;
  int practiceQuestionsCompleted;

  LearningProfile({
    required this.studentName,
    required this.grade,
    required this.preferredLanguage,
    required this.preferredSubject,
    this.apaarId,
    this.conceptMastery = const [],
    this.learningGoals = const [],
    this.badges = const [],
    this.totalStudyTime = 0,
    this.questionsAsked = 0,
    this.practiceCompleted = 0,
    this.streakDays = 0,
    required this.lastActive,
    this.strengths = const [],
    this.areasForImprovement = const [],
    this.practiceQuestionsCompleted = 0,
  });

  Map<String, dynamic> toJson() => {
    'studentName': studentName,
    'grade': grade.number,
    'preferredLanguage': preferredLanguage.name,
    'preferredSubject': preferredSubject.name,
    'apaarId': apaarId,
    'conceptMastery': conceptMastery.map((e) => e.toJson()).toList(),
    'learningGoals': learningGoals.map((e) => e.toJson()).toList(),
    'badges': badges.map((e) => e.toJson()).toList(),
    'totalStudyTime': totalStudyTime,
    'questionsAsked': questionsAsked,
    'practiceCompleted': practiceCompleted,
    'streakDays': streakDays,
    'lastActive': lastActive.toIso8601String(),
    'strengths': strengths,
    'areasForImprovement': areasForImprovement,
    'practiceQuestionsCompleted': practiceQuestionsCompleted,
  };

  factory LearningProfile.fromJson(Map<String, dynamic> json) => LearningProfile(
    studentName: json['studentName'],
    grade: GradeExtension.fromNumber(json['grade']),
    preferredLanguage: Language.values.firstWhere((e) => e.name == json['preferredLanguage']),
    preferredSubject: Subject.values.firstWhere((e) => e.name == json['preferredSubject']),
    apaarId: json['apaarId'],
    conceptMastery: (json['conceptMastery'] as List?)?.map((e) => ConceptMastery.fromJson(e)).toList() ?? [],
    learningGoals: (json['learningGoals'] as List?)?.map((e) => LearningGoal.fromJson(e)).toList() ?? [],
    badges: (json['badges'] as List?)?.map((e) => Badge.fromJson(e)).toList() ?? [],
    totalStudyTime: json['totalStudyTime'] ?? 0,
    questionsAsked: json['questionsAsked'] ?? 0,
    practiceCompleted: json['practiceCompleted'] ?? 0,
    streakDays: json['streakDays'] ?? 0,
    lastActive: DateTime.parse(json['lastActive']),
    strengths: List<String>.from(json['strengths'] ?? []),
    areasForImprovement: List<String>.from(json['areasForImprovement'] ?? []),
    practiceQuestionsCompleted: json['practiceQuestionsCompleted'] ?? 0,
  );

  LearningProfile copyWith({
    String? studentName,
    Grade? grade,
    Language? preferredLanguage,
    Subject? preferredSubject,
    String? apaarId,
    List<ConceptMastery>? conceptMastery,
    List<LearningGoal>? learningGoals,
    List<Badge>? badges,
    int? totalStudyTime,
    int? questionsAsked,
    int? practiceCompleted,
    int? streakDays,
    DateTime? lastActive,
    List<String>? strengths,
    List<String>? areasForImprovement,
    int? practiceQuestionsCompleted,
  }) => LearningProfile(
    studentName: studentName ?? this.studentName,
    grade: grade ?? this.grade,
    preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    preferredSubject: preferredSubject ?? this.preferredSubject,
    apaarId: apaarId ?? this.apaarId,
    conceptMastery: conceptMastery ?? this.conceptMastery,
    learningGoals: learningGoals ?? this.learningGoals,
    badges: badges ?? this.badges,
    totalStudyTime: totalStudyTime ?? this.totalStudyTime,
    questionsAsked: questionsAsked ?? this.questionsAsked,
    practiceCompleted: practiceCompleted ?? this.practiceCompleted,
    streakDays: streakDays ?? this.streakDays,
    lastActive: lastActive ?? this.lastActive,
    strengths: strengths ?? this.strengths,
    areasForImprovement: areasForImprovement ?? this.areasForImprovement,
    practiceQuestionsCompleted: practiceQuestionsCompleted ?? this.practiceQuestionsCompleted,
  );
}
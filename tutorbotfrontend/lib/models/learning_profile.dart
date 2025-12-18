// Profile, Badge, Goal, LearningGoal, ConceptMastery

enum Subject { mathematics, science, socialScience }

enum Grade { six, seven, eight, nine, ten, eleven, twelve }

enum Language {
  english,
  hindi,
  tamil,
  telugu,
  kannada,
  malayalam,
  bengali,
  marathi,
  gujarati,
  punjabi,
  urdu,
  odia
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

extension GradeExtension on Grade {
  int get number {
    switch (this) {
      case Grade.six:
        return 6;
      case Grade.seven:
        return 7;
      case Grade.eight:
        return 8;
      case Grade.nine:
        return 9;
      case Grade.ten:
        return 10;
      case Grade.eleven:
        return 11;
      case Grade.twelve:
        return 12;
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
      case Language.kannada:
        return 'ಕನ್ನಡ';
      case Language.malayalam:
        return 'മലയാളം';
      case Language.bengali:
        return 'বাংলা';
      case Language.marathi:
        return 'मराठी';
      case Language.gujarati:
        return 'ગુજરાતી';
      case Language.punjabi:
        return 'ਪੰਜਾਬੀ';
      case Language.urdu:
        return 'اردو';
      case Language.odia:
        return 'ଓଡ଼ିଆ';
    }
  }
}

class LearningProfile {
  final String studentName;
  final Grade grade;
  final Language preferredLanguage;
  final Subject preferredSubject;
  final int streakDays;
  final int totalStudyTime;
  final int questionsAsked;
  final int practiceCompleted;
  final int practiceQuestionsCompleted;
  final List<Badge> badges;
  final List<Goal> goals;
  final List<LearningGoal> learningGoals;
  final List<ConceptMastery> conceptMastery;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final DateTime lastActive;

  LearningProfile({
    required this.studentName,
    required this.grade,
    required this.preferredLanguage,
    required this.preferredSubject,
    required this.streakDays,
    required this.totalStudyTime,
    required this.questionsAsked,
    required this.practiceCompleted,
    this.practiceQuestionsCompleted = 0,
    required this.badges,
    required this.goals,
    this.learningGoals = const [],
    required this.conceptMastery,
    required this.strengths,
    required this.areasForImprovement,
    required this.lastActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'grade': grade.name,
      'preferredLanguage': preferredLanguage.name,
      'preferredSubject': preferredSubject.name,
      'streakDays': streakDays,
      'totalStudyTime': totalStudyTime,
      'questionsAsked': questionsAsked,
      'practiceCompleted': practiceCompleted,
      'practiceQuestionsCompleted': practiceQuestionsCompleted,
      'badges': badges.map((b) => b.toJson()).toList(),
      'goals': goals.map((g) => g.toJson()).toList(),
      'learningGoals': learningGoals.map((g) => g.toJson()).toList(),
      'conceptMastery': conceptMastery.map((c) => c.toJson()).toList(),
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'lastActive': lastActive.toIso8601String(),
    };
  }

  factory LearningProfile.fromJson(Map<String, dynamic> json) {
    return LearningProfile(
      studentName: json['studentName'],
      grade: Grade.values.firstWhere((g) => g.name == json['grade']),
      preferredLanguage: Language.values
          .firstWhere((l) => l.name == json['preferredLanguage']),
      preferredSubject:
          Subject.values.firstWhere((s) => s.name == json['preferredSubject']),
      streakDays: json['streakDays'] ?? 0,
      totalStudyTime: json['totalStudyTime'] ?? 0,
      questionsAsked: json['questionsAsked'] ?? 0,
      practiceCompleted: json['practiceCompleted'] ?? 0,
      practiceQuestionsCompleted: json['practiceQuestionsCompleted'] ?? 0,
      badges:
          (json['badges'] as List?)?.map((b) => Badge.fromJson(b)).toList() ??
              [],
      goals:
          (json['goals'] as List?)?.map((g) => Goal.fromJson(g)).toList() ?? [],
      learningGoals: (json['learningGoals'] as List?)
              ?.map((g) => LearningGoal.fromJson(g))
              .toList() ??
          [],
      conceptMastery: (json['conceptMastery'] as List?)
              ?.map((c) => ConceptMastery.fromJson(c))
              .toList() ??
          [],
      strengths: List<String>.from(json['strengths'] ?? []),
      areasForImprovement: List<String>.from(json['areasForImprovement'] ?? []),
      lastActive: DateTime.parse(json['lastActive']),
    );
  }

  LearningProfile copyWith({
    String? studentName,
    Grade? grade,
    Language? preferredLanguage,
    Subject? preferredSubject,
    int? streakDays,
    int? totalStudyTime,
    int? questionsAsked,
    int? practiceCompleted,
    int? practiceQuestionsCompleted,
    List<Badge>? badges,
    List<Goal>? goals,
    List<LearningGoal>? learningGoals,
    List<ConceptMastery>? conceptMastery,
    List<String>? strengths,
    List<String>? areasForImprovement,
    DateTime? lastActive,
  }) {
    return LearningProfile(
      studentName: studentName ?? this.studentName,
      grade: grade ?? this.grade,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredSubject: preferredSubject ?? this.preferredSubject,
      streakDays: streakDays ?? this.streakDays,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      questionsAsked: questionsAsked ?? this.questionsAsked,
      practiceCompleted: practiceCompleted ?? this.practiceCompleted,
      practiceQuestionsCompleted:
          practiceQuestionsCompleted ?? this.practiceQuestionsCompleted,
      badges: badges ?? this.badges,
      goals: goals ?? this.goals,
      learningGoals: learningGoals ?? this.learningGoals,
      conceptMastery: conceptMastery ?? this.conceptMastery,
      strengths: strengths ?? this.strengths,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      lastActive: lastActive ?? this.lastActive,
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'earnedDate': earnedDate.toIso8601String(),
      'icon': icon,
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      earnedDate: DateTime.parse(json['earnedDate']),
      icon: json['icon'],
    );
  }
}

class Goal {
  final String id;
  final String title;
  final String description;
  final DateTime targetDate;
  final bool isCompleted;
  final Subject subject;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDate,
    required this.isCompleted,
    required this.subject,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetDate': targetDate.toIso8601String(),
      'isCompleted': isCompleted,
      'subject': subject.name,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetDate: DateTime.parse(json['targetDate']),
      isCompleted: json['isCompleted'] ?? false,
      subject: Subject.values.firstWhere((s) => s.name == json['subject']),
    );
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? targetDate,
    bool? isCompleted,
    Subject? subject,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      subject: subject ?? this.subject,
    );
  }
}

class LearningGoal {
  final String id;
  final String title;
  final DateTime targetDate;
  final Subject subject;
  double progress;
  bool completed;

  LearningGoal({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.subject,
    this.progress = 0.0,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetDate': targetDate.toIso8601String(),
      'subject': subject.name,
      'progress': progress,
      'completed': completed,
    };
  }

  factory LearningGoal.fromJson(Map<String, dynamic> json) {
    return LearningGoal(
      id: json['id'],
      title: json['title'],
      targetDate: DateTime.parse(json['targetDate']),
      subject: Subject.values.firstWhere((s) => s.name == json['subject']),
      progress: json['progress']?.toDouble() ?? 0.0,
      completed: json['completed'] ?? false,
    );
  }

  LearningGoal copyWith({
    String? id,
    String? title,
    DateTime? targetDate,
    Subject? subject,
    double? progress,
    bool? completed,
  }) {
    return LearningGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      subject: subject ?? this.subject,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
    );
  }
}

class ConceptMastery {
  final String conceptName;
  final Subject subject;
  final double masteryLevel;
  final DateTime lastPracticed;

  ConceptMastery({
    required this.conceptName,
    required this.subject,
    required this.masteryLevel,
    required this.lastPracticed,
  });

  Map<String, dynamic> toJson() {
    return {
      'conceptName': conceptName,
      'subject': subject.name,
      'masteryLevel': masteryLevel,
      'lastPracticed': lastPracticed.toIso8601String(),
    };
  }

  factory ConceptMastery.fromJson(Map<String, dynamic> json) {
    return ConceptMastery(
      conceptName: json['conceptName'],
      subject: Subject.values.firstWhere((s) => s.name == json['subject']),
      masteryLevel: json['masteryLevel'].toDouble(),
      lastPracticed: DateTime.parse(json['lastPracticed']),
    );
  }
}
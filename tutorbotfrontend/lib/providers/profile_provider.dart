import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning_profile.dart';

class ProfileProvider extends ChangeNotifier {
  LearningProfile? _profile;

  LearningProfile? get profile => _profile;

  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('learning_profile');

      if (profileJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(profileJson);
        _profile = LearningProfile.fromJson(decoded);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> saveProfile(LearningProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(profile.toJson());
      await prefs.setString('learning_profile', profileJson);
      _profile = profile;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving profile: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(LearningProfile profile) async {
    await saveProfile(profile);
  }

  Future<void> incrementQuestionsAsked() async {
    if (_profile != null) {
      final updated = LearningProfile(
        studentName: _profile!.studentName,
        grade: _profile!.grade,
        preferredLanguage: _profile!.preferredLanguage,
        preferredSubject: _profile!.preferredSubject,
        streakDays: _profile!.streakDays,
        totalStudyTime: _profile!.totalStudyTime,
        questionsAsked: _profile!.questionsAsked + 1,
        practiceCompleted: _profile!.practiceCompleted,
        badges: _profile!.badges,
        goals: _profile!.goals,
        conceptMastery: _profile!.conceptMastery,
        strengths: _profile!.strengths,
        areasForImprovement: _profile!.areasForImprovement,
        lastActive: DateTime.now(),
      );
      await saveProfile(updated);
    }
  }

  Future<void> incrementPracticeCompleted() async {
    if (_profile != null) {
      final updated = LearningProfile(
        studentName: _profile!.studentName,
        grade: _profile!.grade,
        preferredLanguage: _profile!.preferredLanguage,
        preferredSubject: _profile!.preferredSubject,
        streakDays: _profile!.streakDays,
        totalStudyTime: _profile!.totalStudyTime,
        questionsAsked: _profile!.questionsAsked,
        practiceCompleted: _profile!.practiceCompleted + 1,
        practiceQuestionsCompleted:
            _profile!.practiceQuestionsCompleted + 5,
        badges: _profile!.badges,
        goals: _profile!.goals,
        learningGoals: _profile!.learningGoals,
        conceptMastery: _profile!.conceptMastery,
        strengths: _profile!.strengths,
        areasForImprovement: _profile!.areasForImprovement,
        lastActive: DateTime.now(),
      );
      await saveProfile(updated);
    }
  }

  Future<void> addLearningGoal(LearningGoal goal) async {
    if (_profile != null) {
      final updatedGoals = List<LearningGoal>.from(_profile!.learningGoals)
        ..add(goal);

      final updated = LearningProfile(
        studentName: _profile!.studentName,
        grade: _profile!.grade,
        preferredLanguage: _profile!.preferredLanguage,
        preferredSubject: _profile!.preferredSubject,
        streakDays: _profile!.streakDays,
        totalStudyTime: _profile!.totalStudyTime,
        questionsAsked: _profile!.questionsAsked,
        practiceCompleted: _profile!.practiceCompleted,
        practiceQuestionsCompleted: _profile!.practiceQuestionsCompleted,
        badges: _profile!.badges,
        goals: _profile!.goals,
        learningGoals: updatedGoals,
        conceptMastery: _profile!.conceptMastery,
        strengths: _profile!.strengths,
        areasForImprovement: _profile!.areasForImprovement,
        lastActive: DateTime.now(),
      );
      await saveProfile(updated);
    }
  }

  Future<void> updateGoalProgress(String goalId, double progress) async {
    if (_profile != null) {
      final updatedGoals = _profile!.learningGoals.map((goal) {
        if (goal.id == goalId) {
          return LearningGoal(
            id: goal.id,
            title: goal.title,
            targetDate: goal.targetDate,
            subject: goal.subject,
            progress: progress,
            completed: progress >= 100,
          );
        }
        return goal;
      }).toList();

      final updated = LearningProfile(
        studentName: _profile!.studentName,
        grade: _profile!.grade,
        preferredLanguage: _profile!.preferredLanguage,
        preferredSubject: _profile!.preferredSubject,
        streakDays: _profile!.streakDays,
        totalStudyTime: _profile!.totalStudyTime,
        questionsAsked: _profile!.questionsAsked,
        practiceCompleted: _profile!.practiceCompleted,
        practiceQuestionsCompleted: _profile!.practiceQuestionsCompleted,
        badges: _profile!.badges,
        goals: _profile!.goals,
        learningGoals: updatedGoals,
        conceptMastery: _profile!.conceptMastery,
        strengths: _profile!.strengths,
        areasForImprovement: _profile!.areasForImprovement,
        lastActive: DateTime.now(),
      );
      await saveProfile(updated);
    }
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}

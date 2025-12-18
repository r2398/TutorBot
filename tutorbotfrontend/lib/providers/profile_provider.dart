// Learning profile state management

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning_profile.dart';

class ProfileProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  LearningProfile? _profile;

  ProfileProvider(this._prefs) {
    _loadProfile();
  }

  LearningProfile? get profile => _profile;

  void _loadProfile() {
    final profileJson = _prefs.getString('learningProfile');
    if (profileJson != null) {
      _profile = LearningProfile.fromJson(json.decode(profileJson));
      notifyListeners();
    }
  }

  Future<void> saveProfile(LearningProfile profile) async {
    _profile = profile;
    await _prefs.setString('learningProfile', json.encode(profile.toJson()));
    notifyListeners();
  }

  Future<void> updateProfile(LearningProfile Function(LearningProfile) update) async {
    if (_profile != null) {
      _profile = update(_profile!);
      await _prefs.setString('learningProfile', json.encode(_profile!.toJson()));
      notifyListeners();
    }
  }

  Future<void> incrementQuestionsAsked() async {
    if (_profile != null) {
      _profile = _profile!.copyWith(
        questionsAsked: _profile!.questionsAsked + 1,
        lastActive: DateTime.now(),
      );
      await _prefs.setString('learningProfile', json.encode(_profile!.toJson()));
      notifyListeners();
    }
  }

  Future<void> incrementPracticeCompleted() async {
    if (_profile != null) {
      _profile = _profile!.copyWith(
        practiceCompleted: _profile!.practiceCompleted + 1,
        practiceQuestionsCompleted: _profile!.practiceQuestionsCompleted + 1,
        lastActive: DateTime.now(),
      );
      await _prefs.setString('learningProfile', json.encode(_profile!.toJson()));
      notifyListeners();
    }
  }

  Future<void> addStudyTime(int minutes) async {
    if (_profile != null) {
      _profile = _profile!.copyWith(
        totalStudyTime: _profile!.totalStudyTime + minutes,
        lastActive: DateTime.now(),
      );
      await _prefs.setString('learningProfile', json.encode(_profile!.toJson()));
      notifyListeners();
    }
  }

  Future<void> updateStreak() async {
    if (_profile != null) {
      final lastActive = _profile!.lastActive;
      final now = DateTime.now();
      final difference = now.difference(lastActive).inHours;
      
      int newStreak = _profile!.streakDays;
      if (difference >= 24 && difference < 48) {
        newStreak++;
      } else if (difference >= 48) {
        newStreak = 1;
      }

      _profile = _profile!.copyWith(
        streakDays: newStreak,
        lastActive: now,
      );
      await _prefs.setString('learningProfile', json.encode(_profile!.toJson()));
      notifyListeners();
    }
  }

  Future<void> addBadge(Badge badge) async {
    if (_profile != null) {
      final badges = List<Badge>.from(_profile!.badges);
      if (!badges.any((b) => b.id == badge.id)) {
        badges.add(badge);
        _profile = _profile!.copyWith(badges: badges);
        await _prefs.setString('learningProfile', json.encode(_profile!.toJson()));
        notifyListeners();
      }
    }
  }

  Future<void> addLearningGoal(LearningGoal goal) async {
    if (_profile != null) {
      final goals = List<LearningGoal>.from(_profile!.learningGoals);
      goals.add(goal);
      _profile = _profile!.copyWith(learningGoals: goals);
      await _prefs.setString('learningProfile', json.encode(_profile!.toJson()));
      notifyListeners();
    }
  }

  Future<void> updateGoalProgress(String goalId, double progress) async {
    if (_profile != null) {
      final goals = List<LearningGoal>.from(_profile!.learningGoals);
      final index = goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        goals[index].progress = progress;
        if (progress >= 100) {
          goals[index].completed = true;
        }
        _profile = _profile!.copyWith(learningGoals: goals);
        await _prefs.setString('learningProfile', json.encode(_profile!.toJson()));
        notifyListeners();
      }
    }
  }

  Future<void> clearProfile() async {
    _profile = null;
    await _prefs.remove('learningProfile');
    notifyListeners();
  }
}
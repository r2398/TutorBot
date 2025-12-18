// Chat messages state management

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../models/learning_profile.dart';

class MessageProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  final Map<Subject, List<Message>> _messagesBySubject = {};

  MessageProvider(this._prefs) {
    _loadMessages();
  }

  List<Message> getMessages(Subject subject) {
    return _messagesBySubject[subject] ?? [];
  }

  Future<void> addMessage(Subject subject, Message message) async {
    if (!_messagesBySubject.containsKey(subject)) {
      _messagesBySubject[subject] = [];
    }
    _messagesBySubject[subject]!.add(message);
    await _saveMessages(subject);
    notifyListeners();
  }

  Future<void> updateMessageHint(Subject subject, String messageId, int hintIndex) async {
    final messages = _messagesBySubject[subject];
    if (messages != null) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final oldMessage = messages[index];
        messages[index] = Message(
          id: oldMessage.id,
          role: oldMessage.role,
          content: oldMessage.content,
          timestamp: oldMessage.timestamp,
          imageUrl: oldMessage.imageUrl,
          hints: oldMessage.hints,
          currentHintIndex: hintIndex,
          hasVideo: oldMessage.hasVideo,
        );
        await _saveMessages(subject);
        notifyListeners();
      }
    }
  }

  Future<void> clearMessages(Subject subject) async {
    _messagesBySubject[subject] = [];
    await _saveMessages(subject);
    notifyListeners();
  }

  Future<void> _loadMessages() async {
    for (var subject in Subject.values) {
      final key = 'messages_${subject.name}';
      final jsonString = _prefs.getString(key);
      if (jsonString != null) {
        try {
          final List<dynamic> jsonList = json.decode(jsonString);
          _messagesBySubject[subject] = jsonList
              .map((json) => Message.fromJson(json))
              .toList();
        } catch (e) {
          debugPrint('Error loading messages for $subject: $e');
          _messagesBySubject[subject] = [];
        }
      }
    }
    notifyListeners();
  }

  Future<void> _saveMessages(Subject subject) async {
    final key = 'messages_${subject.name}';
    final messages = _messagesBySubject[subject] ?? [];
    final jsonString = json.encode(
      messages.map((m) => m.toJson()).toList(),
    );
    await _prefs.setString(key, jsonString);
  }
}
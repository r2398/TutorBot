import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../models/learning_profile.dart';

class MessageProvider extends ChangeNotifier {
  final Map<Subject, List<Message>> _messagesBySubject = {
    Subject.mathematics: [],
    Subject.science: [],
    Subject.socialScience: [],
  };

  List<Message> getMessages(Subject subject) {
    return _messagesBySubject[subject] ?? [];
  }

  Future<void> addMessage(Subject subject, Message message) async {
    _messagesBySubject[subject]?.add(message);
    notifyListeners();
    await _saveMessages(subject);
  }

  Future<void> removeMessage(Subject subject, String messageId) async {
    _messagesBySubject[subject]?.removeWhere((msg) => msg.id == messageId);
    notifyListeners();
    await _saveMessages(subject);
  }

  Future<void> updateMessage(Subject subject, Message updatedMessage) async {
    final messages = _messagesBySubject[subject];
    if (messages != null) {
      final index = messages.indexWhere((msg) => msg.id == updatedMessage.id);
      if (index != -1) {
        messages[index] = updatedMessage;
        notifyListeners();
        await _saveMessages(subject);
      }
    }
  }

  Future<void> clearMessages(Subject subject) async {
    _messagesBySubject[subject]?.clear();
    notifyListeners();
    await _saveMessages(subject);
  }

  Future<void> _saveMessages(Subject subject) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messages = _messagesBySubject[subject] ?? [];
      final messagesJson = jsonEncode(
        messages.map((m) => m.toJson()).toList(),
      );
      await prefs.setString('messages_${subject.name}', messagesJson);
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }

  Future<void> loadMessages(Subject subject) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('messages_${subject.name}');

      if (messagesJson != null) {
        final List<dynamic> decoded = jsonDecode(messagesJson);
        _messagesBySubject[subject] = decoded
            .map((json) => Message.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }
}

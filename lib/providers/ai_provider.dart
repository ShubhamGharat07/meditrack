import 'package:flutter/material.dart';
import '../viewmodels/ai_viewmodel.dart';
import '../core/errors/failures.dart';

// Chat message model — AI aur User ke messages
class ChatMessage {
  final String message;
  final bool isUser; // true = User, false = AI
  final DateTime time;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.time,
  });
}

class AIProvider extends ChangeNotifier {
  final AIViewModel _aiViewModel = AIViewModel();

  // ─────────────────────────────────────
  // STATES
  // ─────────────────────────────────────

  bool _isLoading = false;
  List<ChatMessage> _messages = [];
  String _errorMessage = '';

  // Getters
  bool get isLoading => _isLoading;
  List<ChatMessage> get messages => _messages;
  String get errorMessage => _errorMessage;

  // ─────────────────────────────────────
  // SEND MESSAGE
  // ─────────────────────────────────────

  Future<void> sendMessage(String message) async {
    try {
      // User ka message list mein add karo
      _messages.add(
        ChatMessage(message: message, isUser: true, time: DateTime.now()),
      );
      _setLoading(true);
      _clearError();

      // AIViewModel ko message do
      // ViewModel → Gemini API → Response
      final response = await _aiViewModel.sendMessage(message);

      // AI ka response list mein add karo
      _messages.add(
        ChatMessage(message: response, isUser: false, time: DateTime.now()),
      );
    } on ServerFailure catch (e) {
      _errorMessage = e.message;
      // Error message bhi chat mein dikha
      _messages.add(
        ChatMessage(
          message:
              'Sorry, I am unable to process your request. Please try again!',
          isUser: false,
          time: DateTime.now(),
        ),
      );
    } catch (e) {
      _errorMessage = 'Something went wrong!';
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // CLEAR CHAT
  // ─────────────────────────────────────

  void clearChat() {
    _messages = [];
    _aiViewModel.clearChat();
    notifyListeners();
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }
}

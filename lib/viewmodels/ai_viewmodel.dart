import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/errors/failures.dart';

class AIViewModel {
  final List<Map<String, dynamic>> _chatHistory = [];
  bool _isInitialized = false;

  // Models to try in order — if one fails, try the next
  final List<String> _models = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
  ];

  // Base system instruction (always present)
  final String _baseSystemInstruction =
      'You are MediTrack AI, a personal health assistant. '
      'You provide accurate health information and medicine guidance. '
      'Always remind users to consult their doctor for medical advice. '
      'Keep responses concise and easy to understand. '
      'Never provide definitive medical diagnoses. '
      'When the user asks about their medicines, appointments, health records, '
      'or insurance, always use the patient data provided below. '
      'If data shows specific medicines or appointments, reference them directly. '
      'Do not say you do not have access to their data — use what is provided.';

  // ─────────────────────────────────────
  // SEND MESSAGE — RAG Enabled
  //
  // KEY FIX: Context is refreshed on EVERY message.
  // If user adds a new doctor/medicine and immediately asks AI,
  // the AI will have the latest data.
  //
  // How it works:
  // - Chat history index [0] = system instruction (user role)
  // - Chat history index [1] = AI acknowledgment (model role)
  // - Index [2+] = actual conversation
  //
  // On every call, index [0] is REPLACED with fresh context.
  // This means AI always sees the latest data without losing
  // conversation history.
  // ─────────────────────────────────────
  Future<String> sendMessage(String message, {String? context}) async {
    try {
      if (message.isEmpty) {
        throw ServerFailure('Message is required!');
      }

      final apiKey = (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
      if (apiKey.isEmpty) {
        throw ServerFailure('API key not found!');
      }

      // Build full system instruction: base + patient data context
      final String fullSystemInstruction =
          context != null && context.isNotEmpty
              ? '$_baseSystemInstruction\n\n'
                '═══════════════════════════════════\n'
                'PATIENT\'S CURRENT HEALTH DATA:\n'
                '═══════════════════════════════════\n'
                '$context\n'
                '═══════════════════════════════════\n'
                'Use the above data to answer the patient\'s questions accurately. '
                'Today\'s date is ${_todayFormatted()}.'
              : _baseSystemInstruction;

      if (!_isInitialized) {
        // FIRST MESSAGE — create system instruction + AI ack
        _chatHistory.add({
          'role': 'user',
          'parts': [
            {'text': fullSystemInstruction},
          ],
        });
        _chatHistory.add({
          'role': 'model',
          'parts': [
            {
              'text':
                  'Understood! I am MediTrack AI, your personal health assistant. '
                  'I have access to your health data and can answer questions about '
                  'your medicines, appointments, health records, and insurance. '
                  'How can I help you today?',
            },
          ],
        });
        _isInitialized = true;
      } else {
        // SUBSEQUENT MESSAGES — REPLACE system instruction with fresh context
        // This ensures AI always has the LATEST data
        // (e.g., user just added a new doctor appointment)
        _chatHistory[0] = {
          'role': 'user',
          'parts': [
            {'text': fullSystemInstruction},
          ],
        };
      }

      // Add user message to history
      _chatHistory.add({
        'role': 'user',
        'parts': [
          {'text': message},
        ],
      });

      final body = jsonEncode({
        'contents': _chatHistory,
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 1024},
      });

      // Try each model in order
      String? lastError;
      for (final model in _models) {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$apiKey',
        );

        try {
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            if (data['candidates'] == null ||
                (data['candidates'] as List).isEmpty) {
              lastError = 'No response generated';
              continue;
            }

            final text =
                data['candidates'][0]['content']['parts'][0]['text'];

            // Add AI response to history
            _chatHistory.add({
              'role': 'model',
              'parts': [
                {'text': text},
              ],
            });

            return text;
          } else if (response.statusCode == 429) {
            final error = jsonDecode(response.body);
            lastError = error['error']?['message'] ?? 'Rate limited!';
            await Future.delayed(const Duration(seconds: 2));
            continue;
          } else if (response.statusCode == 404) {
            final error = jsonDecode(response.body);
            lastError = error['error']?['message'] ?? 'Model not found!';
            continue;
          } else {
            final error = jsonDecode(response.body);
            final errorMessage =
                error['error']?['message'] ?? 'Unknown error!';
            if (response.statusCode == 403) {
              lastError = errorMessage;
              continue;
            }
            throw ServerFailure(errorMessage);
          }
        } catch (e) {
          if (e is ServerFailure) rethrow;
          lastError = 'Network error: $e';
          continue;
        }
      }

      // All models failed — remove last user message from history
      if (_chatHistory.isNotEmpty) {
        _chatHistory.removeLast();
      }
      throw ServerFailure(
        'All AI models are currently unavailable. Please try again.\n'
        'Error: $lastError',
      );
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure('AI Error: ${e.toString()}');
    }
  }

  // ─────────────────────────────────────
  // CLEAR CHAT
  // ─────────────────────────────────────
  void clearChat() {
    _chatHistory.clear();
    _isInitialized = false;
  }

  // ─────────────────────────────────────
  // DATE HELPER
  // ─────────────────────────────────────
  String _todayFormatted() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
  }
}

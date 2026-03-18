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

  final String _systemInstruction =
      'You are MediTrack AI, a helpful health assistant. '
      'You provide accurate health information and medicine guidance. '
      'Always remind users to consult their doctor for medical advice. '
      'Keep responses concise and easy to understand. '
      'Never provide definitive medical diagnoses.';

  Future<String> sendMessage(String message) async {
    try {
      if (message.isEmpty) {
        throw ServerFailure('Message is required!');
      }

      final apiKey = (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
      if (apiKey.isEmpty) {
        throw ServerFailure('API key not found!');
      }

      print(
        'API Key loaded: ${apiKey.substring(0, 8)}...${apiKey.substring(apiKey.length - 4)}',
      );

      // Add system instruction to the first message
      if (!_isInitialized) {
        _chatHistory.add({
          'role': 'user',
          'parts': [
            {'text': _systemInstruction},
          ],
        });
        _chatHistory.add({
          'role': 'model',
          'parts': [
            {
              'text':
                  'Understood! I am MediTrack AI, your personal health assistant. How can I help you today?',
            },
          ],
        });
        _isInitialized = true;
      }

      // Add user message
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

      // Try each model until one works
      String? lastError;
      for (final model in _models) {
        // Use v1 endpoint instead of v1beta
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$apiKey',
        );

        print('Trying model: $model (v1 endpoint)');

        try {
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          );

          print('Status Code ($model): ${response.statusCode}');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            // Check if candidates exist
            if (data['candidates'] == null ||
                (data['candidates'] as List).isEmpty) {
              print('No candidates returned for $model');
              lastError = 'No response generated';
              continue;
            }

            final text = data['candidates'][0]['content']['parts'][0]['text'];

            // Add AI response to history
            _chatHistory.add({
              'role': 'model',
              'parts': [
                {'text': text},
              ],
            });

            return text;
          } else if (response.statusCode == 429) {
            // Rate limited — wait 2 seconds and try next model
            final error = jsonDecode(response.body);
            lastError = error['error']?['message'] ?? 'Rate limited!';
            print('Rate limited on $model: $lastError');
            print('Waiting 2 seconds before trying next model...');
            await Future.delayed(const Duration(seconds: 2));
            continue;
          } else if (response.statusCode == 404) {
            // Model not found — try next model
            final error = jsonDecode(response.body);
            lastError = error['error']?['message'] ?? 'Model not found!';
            print('Model $model not found (404), trying next...');
            continue;
          } else {
            // Other error — log full response and throw
            print('Full error response ($model): ${response.body}');
            final error = jsonDecode(response.body);
            final errorMessage = error['error']?['message'] ?? 'Unknown error!';
            print('API Error ($model): $errorMessage');

            // For 403 (permission denied) try next model too
            if (response.statusCode == 403) {
              lastError = errorMessage;
              continue;
            }

            throw ServerFailure(errorMessage);
          }
        } catch (e) {
          if (e is ServerFailure) rethrow;
          // Network error — try next model
          print('Network error with $model: $e');
          lastError = 'Network error: $e';
          continue;
        }
      }

      // All models failed — remove the user message we added
      if (_chatHistory.isNotEmpty) {
        _chatHistory.removeLast();
      }
      throw ServerFailure(
        'All AI models are currently unavailable. Please try again in a minute.\n'
        'Error: $lastError',
      );
    } on ServerFailure {
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      throw ServerFailure('AI Error: ${e.toString()}');
    }
  }

  void clearChat() {
    _chatHistory.clear();
    _isInitialized = false;
  }
}

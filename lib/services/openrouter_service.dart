import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/ai_config.dart';

/// Thin client for [OpenRouter chat completions](https://openrouter.ai/docs/api).
class OpenRouterService {
  static final Uri _endpoint =
      Uri.parse('https://openrouter.ai/api/v1/chat/completions');

  /// [messages] should be user/assistant turns only (no system message).
  Future<String> chatCompletion({
    required String systemPrompt,
    required List<Map<String, dynamic>> messages,
  }) async {
    final key = AiConfig.openRouterApiKey;
    if (key.isEmpty) {
      throw const OpenRouterHttpException(
        statusCode: 0,
        message:
            'OPENROUTER_API_KEY is empty. Set it in .env (see env.example) or use --dart-define.',
      );
    }

    final payload = <String, dynamic>{
      'model': AiConfig.openRouterModel,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages,
      ],
      'temperature': 0.65,
      'max_tokens': 1200,
    };

    final response = await http.post(
      _endpoint,
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
        'HTTP-Referer': AiConfig.openRouterReferer,
        'X-Title': AiConfig.openRouterTitle,
      },
      body: jsonEncode(payload),
    );

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw OpenRouterHttpException(
        statusCode: response.statusCode,
        message:
            response.body.isEmpty ? 'Invalid response body' : response.body,
      );
    }

    if (response.statusCode != 200) {
      final err = decoded is Map ? decoded['error'] : null;
      var msg = 'Request failed';
      if (err is Map && err['message'] != null) {
        msg = err['message'].toString();
      } else if (decoded is Map && decoded['message'] != null) {
        msg = decoded['message'].toString();
      }
      throw OpenRouterHttpException(
        statusCode: response.statusCode,
        message: msg,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const OpenRouterHttpException(
        statusCode: 500,
        message: 'Unexpected response shape',
      );
    }

    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const OpenRouterHttpException(
        statusCode: 500,
        message: 'No completion choices returned',
      );
    }

    final first = choices.first;
    if (first is! Map) {
      throw const OpenRouterHttpException(
        statusCode: 500,
        message: 'Malformed choice object',
      );
    }

    final message = first['message'];
    if (message is! Map || message['content'] == null) {
      throw const OpenRouterHttpException(
        statusCode: 500,
        message: 'Empty assistant message',
      );
    }

    final text = _extractTextFromContent(message['content']);
    if (text.isEmpty) {
      throw const OpenRouterHttpException(
        statusCode: 500,
        message: 'Assistant returned empty text',
      );
    }

    return text;
  }

  Future<String> molePhotoAnalysis({
    required String imageDataUrl,
    String? userContext,
  }) async {
    final key = AiConfig.openRouterApiKey;
    if (key.isEmpty) {
      throw const OpenRouterHttpException(
        statusCode: 0,
        message:
            'OPENROUTER_API_KEY is empty. Set it in .env (see env.example) or use --dart-define.',
      );
    }

    final payload = <String, dynamic>{
      'model': AiConfig.openRouterModel,
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a skincare routine coach (not a doctor). Analyze the skin photo for '
                  'visible skin condition patterns only: texture, redness, oiliness, dryness, '
                  'and pigmentation cues. Do not identify the person. Never diagnose conditions or '
                  'replace a clinic exam. Keep output concise and practical.\n\n'
                  'Return sections exactly:\n'
                  '1) Quick observation (2-3 bullets)\n'
                  '2) What to improve this week (3-5 bullets: routine steps, SPF, hydration, consistency)\n'
                  '3) Caution signs to monitor (2 bullets: signs worth professional evaluation)\n'
                  '4) When to consult a dermatologist (1 short paragraph).',
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text':
                  'Analyze this skincare progress photo and suggest practical routine improvements. ${userContext ?? ''}',
            },
            {
              'type': 'image_url',
              'image_url': {'url': imageDataUrl},
            },
          ],
        },
      ],
      'temperature': 0.45,
      'max_tokens': 900,
    };

    final response = await http.post(
      _endpoint,
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
        'HTTP-Referer': AiConfig.openRouterReferer,
        'X-Title': AiConfig.openRouterTitle,
      },
      body: jsonEncode(payload),
    );

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw OpenRouterHttpException(
        statusCode: response.statusCode,
        message:
            response.body.isEmpty ? 'Invalid response body' : response.body,
      );
    }

    if (response.statusCode != 200) {
      final err = decoded is Map ? decoded['error'] : null;
      var msg = 'Request failed';
      if (err is Map && err['message'] != null) {
        msg = err['message'].toString();
      } else if (decoded is Map && decoded['message'] != null) {
        msg = decoded['message'].toString();
      }
      throw OpenRouterHttpException(
        statusCode: response.statusCode,
        message: msg,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const OpenRouterHttpException(
        statusCode: 500,
        message: 'Unexpected response shape',
      );
    }

    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const OpenRouterHttpException(
        statusCode: 500,
        message: 'No completion choices returned',
      );
    }

    final first = choices.first;
    if (first is! Map) {
      throw const OpenRouterHttpException(
        statusCode: 500,
        message: 'Malformed choice object',
      );
    }

    final message = first['message'];
    if (message is! Map || message['content'] == null) {
      throw const OpenRouterHttpException(
        statusCode: 500,
        message: 'Empty assistant message',
      );
    }

    final text = _extractTextFromContent(message['content']);
    if (text.isEmpty) {
      throw const OpenRouterHttpException(
        statusCode: 500,
        message: 'Assistant returned empty text',
      );
    }
    return text;
  }

  String _extractTextFromContent(dynamic content) {
    if (content is String) return content.trim();
    if (content is List) {
      final parts = <String>[];
      for (final item in content) {
        if (item is Map && item['text'] != null) {
          parts.add(item['text'].toString());
        } else if (item is String) {
          parts.add(item);
        }
      }
      return parts.join('\n').trim();
    }
    return content?.toString().trim() ?? '';
  }
}

class OpenRouterHttpException implements Exception {
  const OpenRouterHttpException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => 'OpenRouterHttpException($statusCode): $message';
}

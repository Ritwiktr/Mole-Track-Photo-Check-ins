import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Values load from root `.env` (see [env.example]) via [flutter_dotenv].
/// `--dart-define=KEY=value` still overrides when you need CI/release injection.
abstract final class AiConfig {
  static String get openRouterApiKey {
    final v = dotenv.env['OPENROUTER_API_KEY']?.trim() ?? '';
    if (v.isNotEmpty) return v;
    return const String.fromEnvironment(
      'OPENROUTER_API_KEY',
      defaultValue: '',
    );
  }

  static String get openRouterModel {
    final v = dotenv.env['OPENROUTER_MODEL']?.trim();
    if (v != null && v.isNotEmpty) return v;
    return const String.fromEnvironment(
      'OPENROUTER_MODEL',
      defaultValue: 'google/gemma-4-31b-it',
    );
  }

  static String get openRouterReferer {
    final v = dotenv.env['OPENROUTER_HTTP_REFERER']?.trim();
    if (v != null && v.isNotEmpty) return v;
    return const String.fromEnvironment(
      'OPENROUTER_HTTP_REFERER',
      defaultValue: 'https://acnetrack.local',
    );
  }

  static String get openRouterTitle {
    final v = dotenv.env['OPENROUTER_APP_TITLE']?.trim();
    if (v != null && v.isNotEmpty) return v;
    return const String.fromEnvironment(
      'OPENROUTER_APP_TITLE',
      defaultValue: 'AcneTrack AI',
    );
  }
}

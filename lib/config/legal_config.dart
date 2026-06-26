/// Legal URLs, AI recipient disclosure, and privacy copy — keep in sync with App Store Connect.
abstract final class LegalConfig {
  static const String termsUrl = 'https://www.writecream.com/terms-of-service/';
  static const String privacyPolicyUrl =
      'https://www.writecream.com/privacy-policy/';

  /// Primary third-party AI recipient (Apple Guideline 5.1.2).
  static const String aiRecipientName = 'OpenRouter';
  static const String aiRecipientUrl = 'https://openrouter.ai';
  static const String aiRecipientPrivacyUrl = 'https://openrouter.ai/privacy';

  /// Model routed through OpenRouter for this app (shown before data is sent).
  static const String aiModelProvider = 'Google';
  static const String aiModelName = 'google/gemma-4-31b-it';

  /// User-facing disclosure naming the recipient before any AI data is transmitted.
  static const String aiProviderDisclosure =
      'When you enable AI features and tap Agree, the following data may be sent '
      'to OpenRouter (https://openrouter.ai), a third-party AI routing service:\n\n'
      '• Onboarding wellness answers (skin concerns, habits, goals, sleep/stress)\n'
      '• Messages you type in the AI coach chat\n'
      '• Progress photos you choose to analyze (as image data)\n\n'
      'OpenRouter routes your request to AI model providers — including Google '
      '(model: google/gemma-4-31b-it) — solely to generate AI responses for this app. '
      'OpenRouter and its model partners process data under their privacy policies '
      'and contractual data-protection requirements. We require partners to provide '
      'equal or equivalent protection of your data.\n\n'
      'You can decline AI sharing and still use local tracking features. '
      'Disable AI data sharing anytime in Settings.';

  static const String aiConsentAgreeLabel =
      'Agree — send my data to OpenRouter';
}

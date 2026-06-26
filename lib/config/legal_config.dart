/// Legal URLs and third-party AI disclosure copy — keep in sync with App Store Connect.
abstract final class LegalConfig {
  static const String termsUrl = 'https://www.writecream.com/terms-of-service/';
  static const String privacyPolicyUrl =
      'https://www.writecream.com/privacy-policy/';

  /// User-facing copy for who receives AI data (do not name specific vendors in-app).
  static const String aiProviderDisclosure =
      'Data is transmitted to our third-party AI service provider and its '
      'cloud AI processing partners for analysis. These providers process data '
      'only to deliver AI features in this app, under contractual data-protection '
      'requirements. See our Privacy Policy for full details.';
}

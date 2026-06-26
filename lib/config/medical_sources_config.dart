/// Authoritative health-information sources cited in the app (Guideline 1.4.1).
abstract final class MedicalSourcesConfig {
  static const String disclaimer =
      'AI Dermatologist provides general wellness and educational information only. '
      'It is not medical advice, diagnosis, or treatment. Always consult a qualified '
      'dermatologist or healthcare professional for medical concerns.';

  static const List<MedicalSource> sources = [
    MedicalSource(
      organization: 'American Academy of Dermatology',
      title: 'Skin conditions & care',
      url: 'https://www.aad.org/public/diseases',
      topics: 'Acne, eczema, rosacea, rashes, and general skin health',
    ),
    MedicalSource(
      organization: 'MedlinePlus (NIH)',
      title: 'Skin conditions overview',
      url: 'https://medlineplus.gov/skinconditions.html',
      topics: 'Evidence-based summaries of common skin conditions',
    ),
    MedicalSource(
      organization: 'U.S. Food and Drug Administration',
      title: 'Sunscreen & sun protection',
      url: 'https://www.fda.gov/radiation-emitting-products/sunlamps-and-sunlamp-products/sunscreen-how-help-protect-your-skin-sun',
      topics: 'SPF use and UV protection guidance',
    ),
    MedicalSource(
      organization: 'Centers for Disease Control and Prevention',
      title: 'Skin cancer prevention',
      url: 'https://www.cdc.gov/skin-cancer/prevention/',
      topics: 'Sun safety and skin cancer risk reduction',
    ),
    MedicalSource(
      organization: 'National Institute of Arthritis and Musculoskeletal and Skin Diseases (NIH)',
      title: 'Skin diseases research & information',
      url: 'https://www.niams.nih.gov/health-topics/skin-diseases',
      topics: 'NIH-backed skin disease education',
    ),
  ];
}

class MedicalSource {
  const MedicalSource({
    required this.organization,
    required this.title,
    required this.url,
    required this.topics,
  });

  final String organization;
  final String title;
  final String url;
  final String topics;
}

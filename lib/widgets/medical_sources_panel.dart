import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/legal_config.dart';
import '../config/medical_sources_config.dart';

/// Citations for health/wellness information (Apple Guideline 1.4.1).
class MedicalSourcesPanel extends StatelessWidget {
  const MedicalSourcesPanel({
    super.key,
    this.compact = false,
    this.showDisclaimer = true,
  });

  final bool compact;
  final bool showDisclaimer;

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.menu_book_outlined, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              'Health information sources',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (showDisclaimer) ...[
          const SizedBox(height: 8),
          Text(
            MedicalSourcesConfig.disclaimer,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          'General skin-health guidance in this app is informed by these '
          'authoritative sources. Tap a link to read the original information:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        ...MedicalSourcesConfig.sources.map(
          (source) => Padding(
            padding: EdgeInsets.only(bottom: compact ? 8 : 10),
            child: InkWell(
              onTap: () => _openUrl(source.url),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.open_in_new_rounded,
                        size: 16,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.organization,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                            ),
                          ),
                          Text(
                            source.title,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!compact)
                            Text(
                              source.topics,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => _openUrl(LegalConfig.aiRecipientPrivacyUrl),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'OpenRouter privacy policy',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-screen list of medical sources (Settings).
class MedicalSourcesScreen extends StatelessWidget {
  const MedicalSourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health information sources')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: const [
          MedicalSourcesPanel(compact: false, showDisclaimer: true),
        ],
      ),
    );
  }
}

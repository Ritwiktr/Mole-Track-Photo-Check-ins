import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/legal_config.dart';

/// Shared disclosure copy for Apple Guidelines 5.1.1(i) and 5.1.2(i).
class AiDataDisclosureBody extends StatelessWidget {
  const AiDataDisclosureBody({super.key});

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
        Text(
          'This app uses AI features powered by a third-party service. '
          'You must review who receives your data before anything is sent.',
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 16),
        Text(
          'Who receives your data',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LegalConfig.aiRecipientName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _openUrl(LegalConfig.aiRecipientUrl),
                child: Text(
                  LegalConfig.aiRecipientUrl,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'OpenRouter routes requests to AI model providers, including '
                '${LegalConfig.aiModelProvider} (model: ${LegalConfig.aiModelName}).',
                style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'What will be sent to OpenRouter',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const _Bullet(
          'Your onboarding wellness answers (skin concerns, treatment habits, goals, '
          'sleep and stress levels, and similar profile details)',
        ),
        const _Bullet('Messages you type in the AI coach chat'),
        const _Bullet(
          'Progress photos you choose to analyze (sent as image data for AI observations only)',
        ),
        const SizedBox(height: 16),
        Text(
          'How it is used & your choices',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          LegalConfig.aiProviderDisclosure,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 0,
          children: [
            TextButton(
              onPressed: () => _openUrl(LegalConfig.privacyPolicyUrl),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Privacy Policy',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _openUrl(LegalConfig.aiRecipientPrivacyUrl),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'OpenRouter Privacy Policy',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 8),
            child: Icon(
              Icons.circle,
              size: 6,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Returns `true` if the user agreed, `false` if they declined or dismissed.
Future<bool> showAiDataConsentDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: scheme.primary),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Share data with OpenRouter?'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: const AiDataDisclosureBody(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Do not send'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(LegalConfig.aiConsentAgreeLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

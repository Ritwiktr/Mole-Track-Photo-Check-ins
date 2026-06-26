import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/legal_config.dart';

/// Shared disclosure copy for Apple Guideline 5.1.2 (third-party AI data sharing).
class AiDataDisclosureBody extends StatelessWidget {
  const AiDataDisclosureBody({super.key});

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(LegalConfig.privacyPolicyUrl);
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
          'Before any data is sent, please review what is shared and who receives it.',
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 16),
        Text(
          'What may be sent when you use AI features',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const _Bullet(
          'Your onboarding wellness answers (skin concerns, routine habits, goals, '
          'sleep and stress levels, and similar profile details)',
        ),
        const _Bullet('Messages you type in the AI coach chat'),
        const _Bullet(
          'Progress photos you choose to analyze (sent as image data for AI observations only)',
        ),
        const SizedBox(height: 16),
        Text(
          'Who receives this data',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          LegalConfig.aiProviderDisclosure,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 16),
        Text(
          'How it is used',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'To personalize your routine plan, generate coach replies, and provide '
          'skincare-focused photo observations. This is wellness guidance only — '
          'not medical diagnosis or treatment.',
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _openPrivacyPolicy,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Read our Privacy Policy',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
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
            const Expanded(child: Text('AI data sharing')),
          ],
        ),
        content: SingleChildScrollView(
          child: const AiDataDisclosureBody(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Agree and enable AI'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

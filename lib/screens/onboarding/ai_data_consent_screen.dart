import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/skin_journey_provider.dart';
import '../../widgets/ai_data_consent.dart';
import '../../widgets/soft_components.dart';

/// Shown once after onboarding, before any AI data is transmitted.
class AiDataConsentScreen extends StatelessWidget {
  const AiDataConsentScreen({super.key});

  Future<void> _agree(BuildContext context) async {
    await context.read<MoleJourneyNotifier>().grantAiDataSharingConsent();
  }

  Future<void> _decline(BuildContext context) async {
    await context.read<MoleJourneyNotifier>().dismissAiConsentPrompt();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PeachBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.shield_outlined, color: scheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI features & your data',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: SoftCard(
                      child: const AiDataDisclosureBody(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _agree(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Agree and enable AI'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => _decline(context),
                  child: const Text('Not now — use app without AI'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Prompts for consent when needed; returns whether AI may proceed.
Future<bool> requestAiDataSharingConsent(BuildContext context) async {
  final notifier = context.read<MoleJourneyNotifier>();
  if (notifier.aiDataSharingConsented) return true;

  final granted = await showAiDataConsentDialog(context);
  if (!context.mounted) return false;
  if (granted) {
    await notifier.grantAiDataSharingConsent();
    return true;
  }
  return false;
}

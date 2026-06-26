import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/legal_config.dart';
import '../../providers/skin_journey_provider.dart';
import '../../widgets/ai_data_consent.dart';
import '../../widgets/premium_dialog.dart';
import '../../widgets/soft_components.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MoleJourneyNotifier>();
    return PeachBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            SoftCard(
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: notifier.darkModeEnabled,
                title: const Text('Dark mode'),
                subtitle: const Text('Use dark theme across the app'),
                onChanged: (v) => notifier.setDarkMode(v),
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: notifier.aiDataSharingConsented,
                title: const Text('AI data sharing'),
                subtitle: Text(
                  notifier.aiDataSharingConsented
                      ? 'Coach, insights, and photo analysis may send data to '
                          'third-party AI providers.'
                      : 'Off — AI features will not send data to third parties.',
                ),
                onChanged: (enabled) async {
                  if (enabled) {
                    final granted = await showAiDataConsentDialog(context);
                    if (!context.mounted || !granted) return;
                    await notifier.grantAiDataSharingConsent();
                  } else {
                    await notifier.revokeAiDataSharingConsent();
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Privacy Policy'),
                    subtitle: const Text('How we collect, use, and share data'),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                    onTap: () => _openUrl(LegalConfig.privacyPolicyUrl),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                    onTap: () => _openUrl(LegalConfig.termsUrl),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  notifier.isPremium ? 'Premium active' : 'Upgrade to Premium',
                ),
                subtitle: Text(
                  notifier.isPremium
                      ? 'Active plan: ${notifier.activePremiumProductId}'
                      : 'Unlock unlimited uploads and full skincare history',
                ),
                trailing: notifier.isPremium
                    ? const Icon(Icons.verified_rounded, color: Colors.green)
                    : const Icon(Icons.lock_open_rounded),
                onTap: () => showPremiumDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/skin_journey_provider.dart';
import '../../widgets/premium_dialog.dart';
import '../../widgets/soft_components.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(notifier.isPremium ? 'Premium active' : 'Upgrade to Premium'),
                subtitle: Text(
                  notifier.isPremium
                      ? 'Active plan: ${notifier.activePremiumProductId}'
                      : 'Unlock unlimited uploads and full mole-map history',
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

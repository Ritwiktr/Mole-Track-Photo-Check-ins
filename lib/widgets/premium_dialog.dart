import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/skin_journey_provider.dart';

const _termsUrl = 'https://www.writecream.com/terms-of-service/';
const _appleEulaUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

Future<void> showPremiumDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _PremiumDialog(),
  );
}

class _PremiumDialog extends StatefulWidget {
  const _PremiumDialog();

  @override
  State<_PremiumDialog> createState() => _PremiumDialogState();
}

class _PremiumDialogState extends State<_PremiumDialog> {
  String _selectedProductId = SkinJourneyNotifier.yearlyProductId;

  @override
  Widget build(BuildContext context) {
    final n = context.watch<SkinJourneyNotifier>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final products = {for (final p in n.premiumProducts) p.id: p};
    final options = <_PlanOption>[
      _PlanOption(
        title: 'Monthly',
        subtitle: 'Unlimited uploads + full insights (auto-renews monthly)',
        fallbackPrice: '\$4.99',
        productId: SkinJourneyNotifier.monthlyProductId,
      ),
      _PlanOption(
        title: 'Yearly',
        subtitle: 'Unlimited uploads + full insights (auto-renews yearly)',
        fallbackPrice: '\$29.99',
        productId: SkinJourneyNotifier.yearlyProductId,
        badge: 'Best value',
      ),
      _PlanOption(
        title: 'Lifetime',
        subtitle: 'One-time purchase: unlimited uploads + full insights',
        fallbackPrice: '\$59.99',
        productId: SkinJourneyNotifier.lifetimeProductId,
      ),
    ];
    final selected = options.firstWhere(
      (o) => o.productId == _selectedProductId,
      orElse: () => options[1],
    );
    final selectedProduct = products[selected.productId];
    final selectedPrice = selectedProduct?.price ?? selected.fallbackPrice;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.workspace_premium_rounded, color: scheme.primary),
          ),
          const SizedBox(width: 10),
          Text(
            'Unlock Premium',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 30,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Each Premium plan includes:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '• Unlimited weekly photo uploads\n'
              '• Complete progress history\n'
              '• Full AI skin insights and trend tracking',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            ...options.map(
              (option) => _PlanTile(
                option: option,
                price: products[option.productId]?.price ?? option.fallbackPrice,
                selected: _selectedProductId == option.productId,
                onTap: () => setState(() => _selectedProductId = option.productId),
              ),
            ),
            if (n.purchaseError != null) ...[
              const SizedBox(height: 6),
              Text(
                n.purchaseError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Monthly and Yearly renew automatically until canceled in App Store settings.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Wrap(
              spacing: 12,
              runSpacing: 0,
              children: [
                TextButton(
                  onPressed: () => _launch(_termsUrl),
                  child: const Text('Terms of Service'),
                ),
                TextButton(
                  onPressed: () => _launch(_appleEulaUrl),
                  child: const Text("Apple's EULA"),
                ),
              ],
            ),
            TextButton(
              onPressed: n.purchaseLoading ? null : n.restorePurchases,
              child: const Text('Restore purchases'),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: n.purchaseLoading
                    ? null
                    : () async {
                        await n.buyPremium(selected.productId);
                      },
                child: n.purchaseLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Continue • $selectedPrice'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.option,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final _PlanOption option;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.10)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.75)
                : scheme.outline.withValues(alpha: 0.25),
            width: selected ? 1.4 : 1.0,
          ),
                        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        option.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (option.badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            option.badge!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    price,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanOption {
  const _PlanOption({
    required this.title,
    required this.subtitle,
    required this.fallbackPrice,
    required this.productId,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String fallbackPrice;
  final String productId;
  final String? badge;
}

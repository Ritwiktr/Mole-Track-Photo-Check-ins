import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/skin_journey_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/premium_dialog.dart';
import '../../widgets/soft_components.dart';
import '../ai/photo_analysis_result_screen.dart';

class EvolutionTab extends StatefulWidget {
  const EvolutionTab({super.key});

  @override
  State<EvolutionTab> createState() => _EvolutionTabState();
}

class _EvolutionTabState extends State<EvolutionTab> {
  @override
  Widget build(BuildContext context) {
    final n = context.watch<MoleJourneyNotifier>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final history = n.photoAnalysisHistory;
    final isPremium = n.isPremium;
    final visibleHistory = isPremium ? history : history.take(1).toList();

    return DermBackdrop(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        physics: const BouncingScrollPhysics(),
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'Progress timeline',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!isPremium)
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free plan includes your latest result and 1 upload per week.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => showPremiumDialog(context),
                    child: const Text('Unlock Premium'),
                  ),
                ],
              ),
            ),
          if (!isPremium) const SizedBox(height: 12),
          if (visibleHistory.isEmpty)
            SoftCard(
              child: Text(
                'No entries yet. Tap + to add a photo and create your first progress check-in.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            ...List.generate(visibleHistory.length.clamp(0, 8).toInt(), (i) {
              final entry = visibleHistory[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i == 7 ? 0 : 12),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PhotoAnalysisResultScreen(entry: entry),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.surface,
                          scheme.surfaceContainerHighest
                              .withValues(alpha: isDark ? 0.35 : 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.25)
                              : AppColors.accent.withValues(alpha: 0.08),
                          blurRadius: isDark ? 10 : 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: scheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                          child: Image.file(
                            File(entry.imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.photo_camera_back_outlined,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat.yMMMd().add_jm().format(entry.createdAt),
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _cleanPreview(entry.analysis),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _cleanPreview(String raw) {
    final first = raw
        .split('\n')
        .map((e) => e.trim())
        .firstWhere((e) => e.isNotEmpty, orElse: () => raw.trim());
    return first
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('`', '')
        .replaceAll(RegExp(r'^\*+'), '')
        .replaceAll(RegExp(r'^\-+'), '')
        .replaceAll(RegExp(r'^\d+[\)\.\:]\s*'), '')
        .replaceAll(RegExp(r'^"+|"+$'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

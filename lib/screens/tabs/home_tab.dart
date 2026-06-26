import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../providers/skin_journey_provider.dart';
import '../settings/settings_screen.dart';
import '../../theme/app_colors.dart';
import '../../widgets/medical_sources_panel.dart';
import '../../widgets/soft_components.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final n = context.watch<MoleJourneyNotifier>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final score = n.moleWatchScore;
    final pct = (score / 100).clamp(0.0, 1.0);
    final clearance = n.improvementGoalFraction;
    final healing = n.monitoringPercent;
    final target = DateTime.now().add(const Duration(days: 28));

    return DermBackdrop(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Derm plan',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    icon: const Icon(Icons.person_outline_rounded),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SoftCard(
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary.withValues(alpha: isDark ? 0.22 : 0.26),
                          scheme.primary.withValues(alpha: isDark ? 0.08 : 0.12),
                          scheme.surface.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: scheme.surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You are on track',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Stay consistent with treatment, sun protection, and check-ins this week.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SoftCard(
                  child: Column(
                    children: [
                      _metricRow(context, 'Top focus area', n.mainCause),
                      _softDivider(context),
                      _metricRow(
                        context,
                        'Next AI check-in',
                        '${n.nextCheckInDaysEstimate} days',
                      ),
                      _softDivider(context),
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Reach ${(clearance * 100).round()}% of your weekly goal',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: clearance,
                          minHeight: 8,
                          backgroundColor:
                              scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                          color: AppColors.accent,
                        ),
                      ),
                      _softDivider(context),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Skin health score',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Higher means your treatment habits are staying consistent.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          CircularPercentIndicator(
                            radius: 37,
                            lineWidth: 6,
                            percent: pct,
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: AppColors.accent,
                            backgroundColor:
                                scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                            center: Text(
                              '$score',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _metricRow(context, 'Condition summary', n.molePatternLabel),
                      _softDivider(context),
                      Text(
                        'Current focus',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${healing.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (healing / 25).clamp(0.0, 1.0),
                          minHeight: 7,
                          backgroundColor:
                              scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                          color: AppColors.success,
                        ),
                      ),
                      _softDivider(context),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Progress check-in',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _countdown(target),
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontSize: 34,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Next check-in • ${DateFormat.MMMd().format(target)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.schedule_rounded,
                            size: 30,
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SoftCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.menu_book_outlined, color: scheme.primary),
                    title: const Text('Health information sources'),
                    subtitle: const Text('AAD, NIH, FDA & CDC citations'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MedicalSourcesScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _countdown(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return '0d 0h 0m';
    final d = diff.inDays;
    final h = diff.inHours.remainder(24);
    final m = diff.inMinutes.remainder(60);
    return '${d}d ${h}h ${m}m';
  }

  Widget _metricRow(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                ),
          ),
        ),
      ],
    );
  }

  Widget _softDivider(BuildContext context) {
    // Compute with ambient theme so dark mode uses proper contrast.
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.outline.withValues(alpha: 0.05),
              scheme.outline.withValues(alpha: 0.55),
              scheme.outline.withValues(alpha: 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

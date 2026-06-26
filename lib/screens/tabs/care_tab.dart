import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/skin_journey_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/soft_components.dart';

class CareTab extends StatelessWidget {
  const CareTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DermBackdrop(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Treatment plan',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: scheme.outline.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Text(
                        'Personalized',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: _RoutinePanel()),
        ],
      ),
    );
  }
}

class _RoutinePanel extends StatefulWidget {
  const _RoutinePanel();

  @override
  State<_RoutinePanel> createState() => _RoutinePanelState();
}

class _RoutinePanelState extends State<_RoutinePanel> {
  bool _morning = true;

  @override
  Widget build(BuildContext context) {
    final n = context.watch<MoleJourneyNotifier>();
    final scheme = Theme.of(context).colorScheme;
    final period = _morning ? 'morning' : 'night';
    final steps = _morning ? n.morningSteps : n.nightSteps;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
      physics: const BouncingScrollPhysics(),
      children: [
        SoftCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medical_services_outlined, color: AppColors.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clear treatment steps, better outcomes',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Follow AM/PM dermatology steps for steady, visible progress.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SegmentedTwo(
          left: 'Morning',
          right: 'Night',
          isLeftSelected: _morning,
          onChanged: (v) => setState(() => _morning = v),
        ),
        const SizedBox(height: 16),
        WeekDots(completed: n.weekCompletionPreview()),
        const SizedBox(height: 14),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: steps.isEmpty
              ? Text(
                  'No AI treatment steps yet. Add an API key to generate personalized dermatology steps.',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : Column(
                  children: List.generate(steps.length, (index) {
                    final s = steps[index];
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDeep,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _routineIcon(s.category),
                                color: AppColors.accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.category,
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    s.productName,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    s.blurb,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Checkbox.adaptive(
                              value: n.isStepDone(period, s.id),
                              activeColor: AppColors.accent,
                              onChanged: (_) => n.toggleRoutine(period, s.id),
                            ),
                          ],
                        ),
                        if (index != steps.length - 1) const Divider(height: 14),
                      ],
                    );
                  }),
                ),
        ),
      ],
    );
  }
}

IconData _routineIcon(String category) {
  final key = category.toLowerCase();
  if (key.contains('cleanse')) return Icons.bubble_chart_outlined;
  if (key.contains('treat')) return Icons.healing_outlined;
  if (key.contains('moist')) return Icons.opacity_outlined;
  if (key.contains('protect')) return Icons.shield_outlined;
  if (key.contains('barrier')) return Icons.security_outlined;
  return Icons.spa_outlined;
}

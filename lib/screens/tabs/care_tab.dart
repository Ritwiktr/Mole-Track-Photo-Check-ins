import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/skin_journey_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/soft_components.dart';

class CareTab extends StatefulWidget {
  const CareTab({super.key});

  @override
  State<CareTab> createState() => _CareTabState();
}

class _CareTabState extends State<CareTab> {
  int _inner = 0; // 0 routine, 1 nutrition

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PeachBackdrop(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Care plan',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: SegmentedTwo(
              left: 'Routine',
              right: 'Nutrition',
              isLeftSelected: _inner == 0,
              onChanged: (v) => setState(() => _inner = v ? 0 : 1),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _inner == 0
                  ? const _RoutinePanel(key: ValueKey('r'))
                  : const _NutritionPanel(key: ValueKey('n')),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutinePanel extends StatefulWidget {
  const _RoutinePanel({super.key});

  @override
  State<_RoutinePanel> createState() => _RoutinePanelState();
}

class _RoutinePanelState extends State<_RoutinePanel> {
  bool _morning = true;

  @override
  Widget build(BuildContext context) {
    final n = context.watch<SkinJourneyNotifier>();
    final scheme = Theme.of(context).colorScheme;
    final period = _morning ? 'morning' : 'night';
    final steps = _morning ? n.morningSteps : n.nightSteps;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
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
                child: const Icon(Icons.spa_outlined, color: AppColors.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skincare made simple',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Day-by-day steps you can actually finish.',
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
                  'No AI routine steps yet. Add API key to generate personalized care steps.',
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
                          color: AppColors.peachDeep,
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

class _NutritionPanel extends StatelessWidget {
  const _NutritionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foods = context.watch<SkinJourneyNotifier>().nutritionItems;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      physics: const BouncingScrollPhysics(),
      children: [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Nutrition',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.restaurant_menu_rounded, color: AppColors.accent),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Small, steady upgrades beat crash diets. These picks support calm skin and steady energy — all stored locally — no accounts.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: foods.isEmpty
              ? Text(
                  'No AI nutrition suggestions yet. Add API key to generate personalized nutrition support.',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : Column(
                  children: List.generate(foods.length, (i) {
                    final f = foods[i];
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
                          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: scheme.outline.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Icon(
                          _foodIcon(f.name),
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
                              f.name,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(f.amount, style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: f.tags
                                  .map(
                                    (t) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: scheme.surfaceContainerHighest
                                            .withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        t,
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (i != foods.length - 1) const Divider(height: 14),
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

IconData _foodIcon(String name) {
  final key = name.toLowerCase();
  if (key.contains('spinach')) return Icons.eco_outlined;
  if (key.contains('tea')) return Icons.emoji_food_beverage_outlined;
  if (key.contains('blue')) return Icons.circle_outlined;
  if (key.contains('walnut')) return Icons.grain_outlined;
  return Icons.restaurant_outlined;
}

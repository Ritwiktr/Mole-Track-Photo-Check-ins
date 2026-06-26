import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/skin_journey_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/soft_components.dart';

class DailyTab extends StatelessWidget {
  const DailyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final n = context.watch<MoleJourneyNotifier>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = n.selectedDaily;
    final done = n.dailyCompleted;
    final total = n.dailyTotal;
    final streak = n.streakApprox;
    final habits = n.dailyHabits;

    final days = List<DateTime>.generate(
      9,
      (i) => DateTime.now().subtract(Duration(days: 4 - i)),
    );

    return PeachBackdrop(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            'Your mole habits',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Small daily actions build a reliable photo history.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                DateFormat.yMMMM().format(selected),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? scheme.primary.withValues(alpha: 0.22)
                      : AppColors.accentSoft.withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '9-day view',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? scheme.primary : AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) =>
                  const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final d = days[i];
                final isSel = d.year == selected.year &&
                    d.month == selected.month &&
                    d.day == selected.day;
                final isToday = d.year == DateTime.now().year &&
                    d.month == DateTime.now().month &&
                    d.day == DateTime.now().day;
                return GestureDetector(
                  onTap: () => n.pickDailyDay(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 62,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isSel
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                if (isDark) ...[
                                  scheme.primary.withValues(alpha: 0.28),
                                  scheme.surface.withValues(alpha: 0.92),
                                ] else ...[
                                  AppColors.accentSoft.withValues(alpha: 0.55),
                                  Colors.white,
                                ],
                              ],
                            )
                          : null,
                      color: isSel
                          ? null
                          : scheme.surfaceContainerHighest.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel
                            ? AppColors.accent.withValues(alpha: 0.65)
                            : scheme.outline.withValues(alpha: 0.35),
                        width: isSel ? 1.4 : 1,
                      ),
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                color: AppColors.accent
                                    .withValues(alpha: isDark ? 0.20 : 0.12),
                                blurRadius: isDark ? 8 : 12,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.E().format(d).substring(0, 1),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    isSel ? scheme.onSurface : scheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${d.day}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isSel ? scheme.primary : null,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSel
                                ? AppColors.accent
                                : isToday
                                    ? AppColors.success
                                    : scheme.outline.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Streak',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '$streak day${streak == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Consistency is built when you complete at least half of your habits.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    height: 1,
                    color: AppColors.outline.withValues(alpha: 0.45),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '$done / $total',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : done / total,
                    minHeight: 12,
                    backgroundColor:
                        scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            DateFormat.yMMMMd().format(selected),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: habits.isEmpty
                ? Text(
                    'No AI habits yet. Add an API key to generate your personalized mole habits.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : Column(
                    children: List.generate(habits.length, (i) {
                      final h = habits[i];
                      return Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest
                                      .withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: scheme.outline.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Icon(
                                  _habitIcon(h.id),
                                  size: 18,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  h.title,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              Checkbox.adaptive(
                                value: n.isDailyDone(h.id),
                                onChanged: (_) => n.toggleDaily(h.id),
                              ),
                            ],
                          ),
                          if (i != habits.length - 1) const Divider(height: 8),
                        ],
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }

  IconData _habitIcon(String id) {
    switch (id) {
      case 'h1':
        return Icons.face_retouching_natural_outlined;
      case 'h2':
        return Icons.spa_outlined;
      case 'h3':
        return Icons.wb_sunny_outlined;
      case 'h4':
        return Icons.bed_outlined;
      case 'h5':
        return Icons.pan_tool_alt_outlined;
      case 'h6':
        return Icons.edit_note_outlined;
      case 'h7':
        return Icons.water_drop_outlined;
      case 'h8':
        return Icons.self_improvement_outlined;
      case 'h9':
        return Icons.smartphone_outlined;
      default:
        return Icons.task_alt_outlined;
    }
  }
}

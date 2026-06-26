import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/onboarding_questions.dart';
import '../../providers/skin_journey_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/soft_components.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final _controller = PageController();
  final Map<String, dynamic> _answers = {};
  int _page = 0;

  @override
  void initState() {
    super.initState();
    for (final q in onboardingQuestions) {
      if (q.type == QuestionType.scale) {
        _answers[q.id] = q.min;
      }
    }
  }

  OnboardingQuestion get _q => onboardingQuestions[_page];

  bool get _canContinue {
    final q = _q;
    final v = _answers[q.id];
    if (q.type == QuestionType.singleChoice) {
      return v != null && v.toString().isNotEmpty;
    }
    return v != null;
  }

  Future<void> _finish() async {
    final notifier = context.read<MoleJourneyNotifier>();
    await notifier.completeOnboarding(_answers);
  }

  void _next() {
    if (!_canContinue) return;
    if (_page == onboardingQuestions.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_page == 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = onboardingQuestions.length;
    return PeachBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Text(
                      '${_page + 1}/$total',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: (_page + 1) / total),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: value.clamp(0.05, 1.0),
                        minHeight: 6,
                        backgroundColor: AppColors.cream,
                        color: AppColors.accent,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: total,
                    itemBuilder: (_, i) {
                      final q = onboardingQuestions[i];
                      return _QuestionPage(
                        question: q,
                        value: _answers[q.id],
                        onChanged: (v) => setState(() => _answers[q.id] = v),
                      );
                    },
                  ),
                ),
                PrimaryPillButton(
                  label: _page == total - 1 ? 'Start my routine' : 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _canContinue ? _next : null,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final OnboardingQuestion question;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    final q = question;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.prompt,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            q.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          if (q.type == QuestionType.singleChoice) ...[
            ...q.options.map(
              (o) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OptionTile(
                  label: o,
                  selected: value == o,
                  onTap: () => onChanged(o),
                ),
              ),
            ),
          ] else ...[
            _ScaleEditor(
              question: q,
              value: value is int ? value as int : q.min,
              onChanged: onChanged,
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.card
            : AppColors.cream.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.65)
              : AppColors.outline.withValues(alpha: 0.45),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AnimatedScale(
                  scale: selected ? 1 : 0.85,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: selected ? AppColors.accent : AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScaleEditor extends StatelessWidget {
  const _ScaleEditor({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final OnboardingQuestion question;
  final int value;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    final q = question;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.accentSoft.withValues(alpha: 0.35),
              thumbColor: AppColors.card,
              overlayColor: AppColors.accent.withValues(alpha: 0.12),
              trackHeight: 5,
            ),
            child: Slider(
              min: q.min.toDouble(),
              max: q.max.toDouble(),
              divisions: q.max - q.min,
              value: value.toDouble().clamp(q.min.toDouble(), q.max.toDouble()),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                q.minLabel ?? '${q.min}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.peachDeep,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.outline.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  '$value',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                q.maxLabel ?? '${q.max}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

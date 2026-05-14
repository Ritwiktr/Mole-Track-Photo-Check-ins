enum QuestionType { singleChoice, scale }

class OnboardingQuestion {
  const OnboardingQuestion({
    required this.id,
    required this.prompt,
    required this.subtitle,
    required this.type,
    this.options = const [],
    this.min = 0,
    this.max = 10,
    this.minLabel,
    this.maxLabel,
  });

  final String id;
  final String prompt;
  final String subtitle;
  final QuestionType type;
  final List<String> options;
  final int min;
  final int max;
  final String? minLabel;
  final String? maxLabel;
}

const onboardingQuestions = <OnboardingQuestion>[
  OnboardingQuestion(
    id: 'concern',
    prompt: 'What bothers you most right now?',
    subtitle: 'We use this to prioritize your plan.',
    type: QuestionType.singleChoice,
    options: [
      'Active breakouts',
      'Dark marks & texture',
      'Oiliness & clogged pores',
      'Sensitivity & redness',
    ],
  ),
  OnboardingQuestion(
    id: 'duration',
    prompt: 'How long have you been managing acne?',
    subtitle: 'Trends inform realistic timelines.',
    type: QuestionType.singleChoice,
    options: ['Under 3 months', '3–12 months', '1–3 years', '3+ years'],
  ),
  OnboardingQuestion(
    id: 'skinType',
    prompt: 'How does your skin feel midday?',
    subtitle: 'Helps us shape product categories.',
    type: QuestionType.singleChoice,
    options: ['Mostly oily', 'Mostly dry', 'Combination', 'Unsure'],
  ),
  OnboardingQuestion(
    id: 'routine',
    prompt: 'What does your routine look like today?',
    subtitle: 'No judgment — we meet you where you are.',
    type: QuestionType.singleChoice,
    options: [
      'Just cleanser',
      'Cleanser + moisturizer',
      'Full routine with SPF',
      'I am starting from scratch',
    ],
  ),
  OnboardingQuestion(
    id: 'rx',
    prompt: 'Are you using prescription acne care?',
    subtitle: 'So we avoid conflicting actives in tips.',
    type: QuestionType.singleChoice,
    options: ['Yes, currently', 'Sometimes', 'Not now', 'Prefer not to say'],
  ),
  OnboardingQuestion(
    id: 'stress',
    prompt: 'Stress load this month',
    subtitle: '1 = calm season, 10 = high stress.',
    type: QuestionType.scale,
    min: 1,
    max: 10,
    minLabel: 'Calm',
    maxLabel: 'Overwhelming',
  ),
  OnboardingQuestion(
    id: 'sleep',
    prompt: 'Average sleep per night',
    subtitle: 'Rough hours, honest is enough.',
    type: QuestionType.scale,
    min: 4,
    max: 10,
    minLabel: '~4h',
    maxLabel: '8h+',
  ),
  OnboardingQuestion(
    id: 'dairy',
    prompt: 'How often do you have dairy?',
    subtitle: 'Useful context for nutrition nudges.',
    type: QuestionType.singleChoice,
    options: ['Rarely', 'Weekly', 'Most days', 'Daily'],
  ),
  OnboardingQuestion(
    id: 'sun',
    prompt: 'Sun & outdoor time',
    subtitle: 'SPF habits and exposure.',
    type: QuestionType.singleChoice,
    options: [
      'Mostly indoors',
      'Outdoors, inconsistent SPF',
      'Daily SPF 30+',
      'Lots of sports / sweat',
    ],
  ),
  OnboardingQuestion(
    id: 'hormonal',
    prompt: 'Do breakouts track with hormones or cycles?',
    subtitle: 'Optional — helps label patterns.',
    type: QuestionType.singleChoice,
    options: ['Yes, clearly', 'Sometimes', 'No', 'Not sure'],
  ),
  OnboardingQuestion(
    id: 'goal',
    prompt: 'Primary goal for the next 8 weeks',
    subtitle: 'We optimize reminders around this.',
    type: QuestionType.singleChoice,
    options: [
      'Fewer new breakouts',
      'Faster healing',
      'Even tone / marks',
      'Build a stable routine',
    ],
  ),
  OnboardingQuestion(
    id: 'sensitivity',
    prompt: 'How reactive is your skin to new products?',
    subtitle: 'Guides how aggressive suggestions feel.',
    type: QuestionType.singleChoice,
    options: [
      'Very sensitive',
      'Sometimes stings',
      'Pretty resilient',
      'Never tried much',
    ],
  ),
];

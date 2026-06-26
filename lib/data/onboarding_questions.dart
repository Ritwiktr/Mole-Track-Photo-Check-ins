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
    prompt: 'What is your biggest dermatology concern right now?',
    subtitle: 'We use this to prioritize your treatment plan.',
    type: QuestionType.singleChoice,
    options: [
      'Acne and breakouts',
      'Eczema or irritation',
      'Dark spots / hyperpigmentation',
      'Rosacea or redness',
      'Preventive skin health',
    ],
  ),
  OnboardingQuestion(
    id: 'duration',
    prompt: 'How long have you been managing this skin concern?',
    subtitle: 'Trends inform realistic timelines.',
    type: QuestionType.singleChoice,
    options: ['Just starting', 'A few months', '1–3 years', '3+ years'],
  ),
  OnboardingQuestion(
    id: 'skinType',
    prompt: 'How does your skin usually react to sun?',
    subtitle: 'Helps us calibrate photo tips and outdoor habits.',
    type: QuestionType.singleChoice,
    options: [
      'Burns easily',
      'Burns then tans',
      'Tans easily',
      'Rarely burns',
    ],
  ),
  OnboardingQuestion(
    id: 'routine',
    prompt: 'How do you currently track your skin progress?',
    subtitle: 'No judgment — we meet you where you are.',
    type: QuestionType.singleChoice,
    options: [
      'Photos in my camera roll only',
      'Notes or a tracking app',
      'Advice from a dermatologist',
      'I am starting from scratch',
    ],
  ),
  OnboardingQuestion(
    id: 'rx',
    prompt: 'Do you consult a dermatologist regularly?',
    subtitle: 'So we align guidance with your existing care plan.',
    type: QuestionType.singleChoice,
    options: ['Yes, on a schedule', 'Sometimes', 'Not recently', 'Prefer not to say'],
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
    prompt: 'Any known skin sensitivities or conditions?',
    subtitle: 'Optional context so suggestions stay gentle and practical.',
    type: QuestionType.singleChoice,
    options: ['Yes', 'Unsure', 'No', 'Prefer not to say'],
  ),
  OnboardingQuestion(
    id: 'sun',
    prompt: 'Typical sun & outdoor habits',
    subtitle: 'UV exposure strongly affects skin barrier and pigmentation.',
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
    prompt: 'Has your skin changed noticeably in recent months?',
    subtitle: 'Changes help us tune treatment pacing and check-ins.',
    type: QuestionType.singleChoice,
    options: ['Yes, clearly', 'Somewhat', 'Not much', 'I have not tracked closely'],
  ),
  OnboardingQuestion(
    id: 'goal',
    prompt: 'Primary goal for the next 8 weeks',
    subtitle: 'We optimize reminders around this.',
    type: QuestionType.singleChoice,
    options: [
      'Build a consistent treatment routine',
      'Improve texture and clarity',
      'Reduce dark spots and marks',
      'Prepare for a dermatologist visit',
    ],
  ),
  OnboardingQuestion(
    id: 'sensitivity',
    prompt: 'Comfort photographing skin at home?',
    subtitle: 'Guides how detailed reminders feel.',
    type: QuestionType.singleChoice,
    options: [
      'Very comfortable',
      'Okay with guidance',
      'Prefer minimal photos',
      'Not sure yet',
    ],
  ),
];

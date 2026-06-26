import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/skin_journey_provider.dart';
import 'screens/onboarding/ai_data_consent_screen.dart';
import 'screens/onboarding/onboarding_flow_screen.dart';
import 'screens/shell/main_shell_screen.dart';
import 'services/local_storage.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  final storage = await LocalStorage.open();
  runApp(
    ChangeNotifierProvider(
      create: (_) => MoleJourneyNotifier(storage),
      child: const AiDermatologistApp(),
    ),
  );
}

class AiDermatologistApp extends StatelessWidget {
  const AiDermatologistApp({super.key});

  @override
  Widget build(BuildContext context) {
    final n = context.watch<MoleJourneyNotifier>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Dermatologist',
      theme: buildAppTheme(),
      darkTheme: buildDarkAppTheme(),
      themeMode: n.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: const _Bootstrap(),
    );
  }
}

class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  @override
  Widget build(BuildContext context) {
    final n = context.watch<MoleJourneyNotifier>();
    if (!n.hydrated) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!n.onboardingComplete) {
      return const OnboardingFlowScreen();
    }
    if (n.shouldShowAiConsentPrompt) {
      return const AiDataConsentScreen();
    }
    return const MainShellScreen();
  }
}

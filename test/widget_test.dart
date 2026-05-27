// Basic smoke test with mocked local preferences.

import 'dart:io';

import 'package:mole_track_ai/main.dart';
import 'package:mole_track_ai/providers/skin_journey_provider.dart';
import 'package:mole_track_ai/services/local_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final env = File('.env');
    if (!env.existsSync()) {
      await File('env.example').copy(env.path);
    }
    await dotenv.load(fileName: '.env', isOptional: true);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App builds after storage init', (WidgetTester tester) async {
    final storage = await LocalStorage.open();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MoleJourneyNotifier(storage),
        child: const MoleTrackApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MoleTrackApp), findsOneWidget);
  });
}

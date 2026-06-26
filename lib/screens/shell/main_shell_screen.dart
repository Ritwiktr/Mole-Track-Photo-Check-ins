import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/skin_journey_provider.dart';
import '../../widgets/premium_dialog.dart';
import '../onboarding/ai_data_consent_screen.dart';
import '../ai/photo_analysis_result_screen.dart';
import '../tabs/care_tab.dart';
import '../tabs/daily_tab.dart';
import '../tabs/evolution_tab.dart';
import '../tabs/home_tab.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;
  final ImagePicker _picker = ImagePicker();

  static const _titles = ['Home', 'Treatment', 'Progress', 'Habits'];

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MoleJourneyNotifier>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _index,
              children: const [
                HomeTab(),
                CareTab(),
                EvolutionTab(),
                DailyTab(),
              ],
            ),
          ),
          if (notifier.aiInsightsLoading)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.26),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: scheme.outline.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.8,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Setting up your personalized dermatology insights...',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: isDark ? 0.85 : 0.95),
              scheme.primary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: isDark ? 0.25 : 0.4),
              blurRadius: isDark ? 10 : 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _startPhotoAiFlow(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, size: 30),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        shape: const CircularNotchedRectangle(),
        color: scheme.surface.withValues(alpha: isDark ? 0.95 : 0.96),
        elevation: 18,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: _titles[0],
              selected: _index == 0,
              onTap: () => setState(() => _index = 0),
            ),
            _NavItem(
              icon: Icons.medical_services_outlined,
              label: _titles[1],
              selected: _index == 1,
              onTap: () => setState(() => _index = 1),
            ),
            const SizedBox(width: 88),
            _NavItem(
              icon: Icons.show_chart_rounded,
              label: _titles[2],
              selected: _index == 2,
              onTap: () => setState(() => _index = 2),
            ),
            _NavItem(
              icon: Icons.calendar_month_rounded,
              label: _titles[3],
              selected: _index == 3,
              onTap: () => setState(() => _index = 3),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startPhotoAiFlow(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              subtitle: const Text(
                'Capture a clear photo of the area you track',
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              subtitle: const Text('Upload an existing skin progress photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    XFile? file;
    try {
      file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
    } on PlatformException catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to access camera/photos. Please allow permissions in Settings.',
            ),
          ),
        );
      }
      return;
    }
    if (file == null || !context.mounted) return;

    final notifier = context.read<MoleJourneyNotifier>();
    final wantsAiAnalysis = await requestAiDataSharingConsent(context);
    if (!context.mounted) return;

    try {
      await notifier.addProgressPhotoPath(file.path);
    } on StateError catch (e) {
      if (e.message == 'FREE_UPLOAD_LIMIT_REACHED' && context.mounted) {
        await showPremiumDialog(context);
      }
      return;
    }

    if (!context.mounted) return;

    if (!wantsAiAnalysis) {
      setState(() => _index = 2);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Photo saved. Enable AI data sharing in Settings to analyze it.',
            ),
          ),
        );
      }
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Analyzing dermatology photo...')),
          ],
        ),
      ),
    );

    final entry = await notifier.analyzeMoleFromPhoto(file.path);
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    if (!context.mounted) return;

    setState(() => _index = 2);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoAnalysisResultScreen(entry: entry),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        scheme.primary.withValues(alpha: isDark ? 0.28 : 0.22),
                        scheme.primary.withValues(alpha: isDark ? 0.10 : 0.06),
                      ],
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../providers/skin_journey_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/soft_components.dart';

class PhotoAnalysisResultScreen extends StatelessWidget {
  const PhotoAnalysisResultScreen({super.key, required this.entry});

  final MolePhotoAnalysisEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sections = _buildSections(entry.analysis);
    return PeachBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Skin analysis')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            SoftCard(
              padding: const EdgeInsets.all(0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Image.file(
                    File(entry.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined, size: 40),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              child: Row(
                children: [
                  const Icon(Icons.event_note_outlined, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat.yMMMd().add_jm().format(entry.createdAt),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...sections
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SectionCard(
                      title: s.title,
                      icon: s.icon,
                      bullets: s.bullets,
                      paragraph: s.paragraph,
                    ),
                  ),
                )
                ,
          ],
        ),
      ),
    );
  }

  List<_UiSection> _buildSections(String analysis) {
    final lines = analysis
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final quick = <String>[];
    final improve = <String>[];
    final caution = <String>[];
    final derm = <String>[];

    String current = 'quick';
    for (final line in lines) {
      final normalized = line.toLowerCase();
      if (normalized.contains('quick observation')) {
        current = 'quick';
        continue;
      }
      if (normalized.contains('improve this week') ||
          normalized.contains('what to improve')) {
        current = 'improve';
        continue;
      }
      if (normalized.contains('caution signs')) {
        current = 'caution';
        continue;
      }
      if (normalized.contains('dermatologist') ||
          normalized.contains('see a dermatologist') ||
          normalized.contains('clinician') ||
          normalized.contains('see a doctor')) {
        current = 'derm';
        continue;
      }

      final cleaned = line
          .replaceAll('**', '')
          .replaceAll('__', '')
          .replaceAll('`', '')
          .replaceAll(RegExp(r'^\*+'), '')
          .replaceAll(RegExp(r'^\-+'), '')
          .replaceAll(RegExp(r'^\d+[\)\.\:]\s*'), '')
          .replaceAll(RegExp(r'^"+|"+$'), '')
          .trim();
      if (cleaned.isEmpty) continue;

      switch (current) {
        case 'improve':
          improve.add(cleaned);
          break;
        case 'caution':
          caution.add(cleaned);
          break;
        case 'derm':
          derm.add(cleaned);
          break;
        default:
          quick.add(cleaned);
      }
    }

    final fallback = lines.take(6).toList();
    if (quick.isEmpty && improve.isEmpty && caution.isEmpty && derm.isEmpty) {
      quick.addAll(fallback.take(3));
      improve.addAll(fallback.skip(3).take(3));
    }

    return [
      _UiSection(
        title: 'Quick observation',
        icon: Icons.visibility_outlined,
        bullets: quick.take(3).toList(),
      ),
      _UiSection(
        title: 'What to improve',
        icon: Icons.auto_fix_high_outlined,
        bullets: improve.take(4).toList(),
      ),
      _UiSection(
        title: 'Caution signs',
        icon: Icons.warning_amber_rounded,
        bullets: caution.take(3).toList(),
      ),
      _UiSection(
        title: 'When to consult a professional',
        icon: Icons.local_hospital_outlined,
        bullets: const [],
        paragraph: derm.take(2).join(' '),
      ),
    ];
  }
}

class _UiSection {
  const _UiSection({
    required this.title,
    required this.icon,
    required this.bullets,
    this.paragraph = '',
  });

  final String title;
  final IconData icon;
  final List<String> bullets;
  final String paragraph;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.bullets,
    required this.paragraph,
  });

  final String title;
  final IconData icon;
  final List<String> bullets;
  final String paragraph;

  @override
  Widget build(BuildContext context) {
    final hasContent = bullets.isNotEmpty || paragraph.trim().isNotEmpty;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          if (!hasContent)
            Text(
              'No strong signals in this section.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      _sanitizeText(b),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (paragraph.trim().isNotEmpty)
            Text(
              _sanitizeText(paragraph.trim()),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  String _sanitizeText(String input) {
    return input
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('`', '')
        .replaceAll(RegExp(r'^"+|"+$'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

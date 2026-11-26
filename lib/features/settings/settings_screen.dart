import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_look.dart';
import '../../app/frosted_panel.dart';
import '../../domain/app_settings.dart';
import '../thermos/thermos_theme.dart';
import 'containers_section.dart';
import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return InkTheme(child: Builder(builder: (context) => _build(context)));
  }

  Widget _build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ThemeBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Ayarlar')),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (controller.saveFailed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Ayarlar cihaza saklanamadı; uygulamayı kapatırsan kaybolabilir.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    Text('Günlük hedef', style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text('${controller.goalMl} ml', style: text.headlineSmall),
                    Slider(
                      value: controller.goalMl.toDouble(),
                      min: AppSettings.minGoalMl.toDouble(),
                      max: AppSettings.maxGoalMl.toDouble(),
                      divisions:
                          (AppSettings.maxGoalMl - AppSettings.minGoalMl) ~/
                          AppSettings.goalStepMl,
                      label: '${controller.goalMl} ml',
                      semanticFormatterCallback: (v) => '${v.round()} ml',
                      onChanged: (v) => controller.setGoalMl(v.round()),
                    ),
                    const SizedBox(height: 16),
                    Text('Bardak boyu', style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text('${controller.glassMl} ml', style: text.headlineSmall),
                    Slider(
                      key: const ValueKey('glass-slider'),
                      value: controller.glassMl.toDouble(),
                      min: AppSettings.minGlassMl.toDouble(),
                      max: AppSettings.maxGlassMl.toDouble(),
                      divisions:
                          (AppSettings.maxGlassMl - AppSettings.minGlassMl) ~/
                          AppSettings.glassStepMl,
                      label: '${controller.glassMl} ml',
                      semanticFormatterCallback: (v) => '${v.round()} ml',
                      onChanged: (v) => controller.setGlassMl(v.round()),
                    ),
                    const SizedBox(height: 16),
                    ContainersSection(controller: controller),
                    const SizedBox(height: 16),
                    Text('Termos biçimi', style: text.titleMedium),
                    const SizedBox(height: 8),
                    SegmentedButton<ThermosShape>(
                      segments: [
                        for (final s in ThermosShape.values)
                          ButtonSegment(value: s, label: Text(s.label)),
                      ],
                      selected: {controller.shape},
                      showSelectedIcon: false,
                      onSelectionChanged: (s) => controller.setShape(s.first),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      key: const ValueKey('animated-celebrations-switch'),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Hareketli kutlamalar'),
                      subtitle: const Text(
                        'Hedefe ulaşınca karakter hareket eder',
                      ),
                      value: controller.animatedCelebrations,
                      onChanged: controller.setAnimatedCelebrations,
                    ),
                    const SizedBox(height: 16),
                    Text('Tema', style: text.titleMedium),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, box) {
                        // Dar ekranda 3, geniş ekranda 4+ sütun; kartlar eşit.
                        const gap = 8.0;
                        final cols = math.max(3, (box.maxWidth / 104).floor());
                        final w = (box.maxWidth - gap * (cols - 1)) / cols;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (final t in ThermosTheme.all)
                              _ThemeChoice(
                                theme: t,
                                width: w.floorToDouble(),
                                selected: t == controller.theme,
                                onTap: () => controller.setTheme(t),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Temanın küçük önizlemesi: şerit, cam ve su renkleri.
class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.theme,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  final ThermosTheme theme;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: theme.name,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          key: ValueKey('theme-${theme.id}'),
          width: width,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: clayShadows(context, scale: 0.3),
            border: selected
                ? Border.all(color: scheme.primary, width: 3)
                : null,
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 28,
                  // stretch: çocuksuz ColoredBox yoksa 0 yükseklik alır.
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final c in [
                        theme.band,
                        theme.glass,
                        theme.water,
                        theme.deepWater,
                      ])
                        Expanded(child: ColoredBox(color: c)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                theme.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // Ad, temanın kendi başlık yazı tipiyle: seçmeden önce görülsün.
                style: AppLook.of(theme).typeface.headline
                    .style(Theme.of(context).textTheme.labelLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

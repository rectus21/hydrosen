import 'package:flutter/material.dart';

import '../../domain/app_settings.dart';
import '../thermos/thermos_theme.dart';
import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
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
                  const SizedBox(height: 24),
                  Text('Tema', style: text.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in ThermosTheme.all)
                        _ThemeChoice(
                          theme: t,
                          selected: t == controller.theme,
                          onTap: () => controller.setTheme(t),
                        ),
                    ],
                  ),
                ],
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
    required this.selected,
    required this.onTap,
  });

  final ThermosTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        key: ValueKey('theme-${theme.id}'),
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 28,
              child: Row(
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
            const SizedBox(height: 6),
            Text(theme.name, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

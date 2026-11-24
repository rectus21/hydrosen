import 'package:flutter/material.dart';

import '../../app/frosted_panel.dart';
import '../badges/badges_section.dart';
import '../settings/settings_controller.dart';
import 'water_controller.dart';
import '../thermos/thermos_theme.dart';
import 'theme_catalog.dart';
import '../settings/bottle_name_card.dart';
export '../reminder/reminder_section.dart';
export 'records_section.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.settings,
    required this.onOpenSettings,
    this.controller,
  });

  final SettingsController settings;

  /// Seri ve rozetler için; verilmezse "Rozetlerim" bölümü gösterilmez.
  final WaterController? controller;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Profil', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          BottleNameCard(settings: settings),
          const SizedBox(height: 12),
          FrostedPanel(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.person_outline, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kişisel ayarlar',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Günlük hedef'),
                  trailing: Text('${settings.goalMl} ml'),
                ),
                ListTile(
                  leading: const Icon(Icons.local_drink_outlined),
                  title: const Text('Bardak boyu'),
                  trailing: Text('${settings.glassMl} ml'),
                ),
                ListTile(
                  key: const ValueKey('profile-containers'),
                  leading: const Icon(Icons.local_cafe_outlined),
                  title: const Text('Kaplarım'),
                  subtitle: Text(
                    settings.containers
                        .map((c) => '${c.name} ${c.ml}')
                        .join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onOpenSettings,
                ),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Tema'),
                  trailing: Text(settings.theme.name),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.tune),
                  label: const Text('Ayarları düzenle'),
                ),
              ],
            ),
          ),
          if (controller != null) ...[
            const SizedBox(height: 12),
            BadgesSection(controller: controller!),
          ],
        ],
      ),
    ),
  );
}

class ThemeSection extends StatelessWidget {
  const ThemeSection({
    super.key,
    required this.settings,
    required this.onOpenSettings,
  });

  final SettingsController settings;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: ThemeCatalog(
        settings: settings,
        footer: ListenableBuilder(
          listenable: settings,
          builder: (context, _) => FrostedPanel(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<ThermosShape>(
                  key: const ValueKey('quick-shape'),
                  segments: [
                    for (final v in ThermosShape.values)
                      ButtonSegment(value: v, label: Text(v.label)),
                  ],
                  selected: {settings.shape},
                  showSelectedIcon: false,
                  onSelectionChanged: (v) => settings.setShape(v.first),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(settings.theme.name),
                  subtitle: const Text(
                    'Kutlama, yazı tipi ve ayrıntılı görünüm ayarları',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onOpenSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

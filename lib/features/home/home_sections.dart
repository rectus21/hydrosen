import 'package:flutter/material.dart';

import '../../app/frosted_panel.dart';
import '../badges/badges_section.dart';
import '../settings/settings_controller.dart';
import 'water_controller.dart';
import '../thermos/thermos_theme.dart';
import 'theme_catalog.dart';
import '../settings/bottle_name_card.dart';
import '../../domain/widget_snapshot.dart';
import '../backup/backup_io.dart';
import '../backup/backup_section.dart';
import '../backup/backup_service.dart';
import '../widget/widget_preview.dart';
export '../reminder/reminder_section.dart';
export 'records_section.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.settings,
    required this.onOpenSettings,
    this.controller,
    this.backup,
    this.backupIo,
  });

  final SettingsController settings;

  /// Verilirse "Yedekle ve geri yükle" bölümü gösterilir.
  final BackupService? backup;

  /// Yedek dosya kanalı (verilmezse platformunki).
  final BackupFileIO? backupIo;

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
          if (backup != null) ...[
            const SizedBox(height: 12),
            BackupSection(service: backup!, io: backupIo),
          ],
          if (controller != null) ...[
            const SizedBox(height: 12),
            _WidgetSoonPanel(
              snapshot: WidgetSnapshot(
                todayMl: controller!.totalMl,
                goalMl: controller!.goalMl,
                streakDay: controller!.streak.current,
                themeId: settings.theme.id,
                characterName: settings.bottleName,
              ),
            ),
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

/// Profil'deki "Ana ekran widget'ı (yakında)" bölümü: widget'ın 2x2 ve 4x2
/// önizlemesi ve kısa not.
class _WidgetSoonPanel extends StatelessWidget {
  const _WidgetSoonPanel({required this.snapshot});

  final WidgetSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return FrostedPanel(
      key: const ValueKey('widget-soon'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text("Ana ekran widget'ı (yakında)", style: text.titleLarge),
          ),
          const SizedBox(height: 6),
          Text(
            'Karakterin ve bugünkü suyun telefonun ana ekranında görünecek. '
            'Widget telefon sürümüyle gelecek.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (final s in WidgetPreviewSize.values)
                WidgetPreview(snapshot: snapshot, size: s),
            ],
          ),
        ],
      ),
    );
  }
}

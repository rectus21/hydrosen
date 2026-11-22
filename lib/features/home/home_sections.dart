import 'package:flutter/material.dart';

import '../../app/frosted_panel.dart';
import '../settings/settings_controller.dart';
import 'quick_theme_strip.dart';
import 'reminder_controller.dart';
export 'records_section.dart';

class ReminderSection extends StatelessWidget {
  const ReminderSection({super.key, required this.controller});

  final ReminderController controller;

  Future<void> _pickTime(BuildContext context, bool start) async {
    final minute = start ? controller.startMinute : controller.endMinute;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
      helpText: start ? 'Başlangıç saati' : 'Bitiş saati',
    );
    if (picked == null || !context.mounted) return;
    final value = picked.hour * 60 + picked.minute;
    if ((start && value >= controller.endMinute) ||
        (!start && value <= controller.startMinute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitiş saati başlangıçtan sonra olmalı.')),
      );
      return;
    }
    if (start) {
      await controller.configure(start: value);
    } else {
      await controller.configure(end: value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final next = controller.nextReminder;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Su hatırlatıcısı',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            FrostedPanel(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Hatırlatıcı açık'),
                    subtitle: const Text(
                      'Seçtiğin saatlerde su içmeni hatırlatır',
                    ),
                    value: controller.enabled,
                    onChanged: (value) => controller.configure(active: value),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.wb_sunny_outlined),
                    title: const Text('Başlangıç'),
                    trailing: Text(_minuteClock(controller.startMinute)),
                    onTap: () => _pickTime(context, true),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.nights_stay_outlined),
                    title: const Text('Bitiş'),
                    trailing: Text(_minuteClock(controller.endMinute)),
                    onTap: () => _pickTime(context, false),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: controller.intervalMinute,
                    decoration: const InputDecoration(
                      labelText: 'Tekrarlama sıklığı',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 30,
                        child: Text('30 dakikada bir'),
                      ),
                      DropdownMenuItem(value: 60, child: Text('1 saatte bir')),
                      DropdownMenuItem(
                        value: 90,
                        child: Text('1,5 saatte bir'),
                      ),
                      DropdownMenuItem(value: 120, child: Text('2 saatte bir')),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.configure(interval: value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FrostedPanel(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text(
                  next == null ? 'Hatırlatıcı kapalı' : 'Sıradaki hatırlatma',
                ),
                subtitle: Text(
                  next == null
                      ? 'Açmak için yukarıdaki anahtarı kullan.'
                      : '${DateUtils.isSameDay(next, DateTime.now()) ? 'Bugün' : 'Yarın'} ${_clock(next)}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hatırlatmalar uygulama açıkken görünür. Arka planda bildirim desteğini sonraki sürümde ekleyeceğiz.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.settings,
    required this.onOpenSettings,
  });

  final SettingsController settings;
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
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Tema seç', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Termos biçimini ve karakterini anında değiştir.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          FrostedPanel(child: QuickThemeStrip(settings: settings)),
          const SizedBox(height: 12),
          FrostedPanel(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.palette_outlined),
              title: Text(settings.theme.name),
              subtitle: const Text(
                'Kutlama, yazı tipi ve ayrıntılı görünüm ayarları',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenSettings,
            ),
          ),
        ],
      ),
    ),
  );
}

String _minuteClock(int value) =>
    '${(value ~/ 60).toString().padLeft(2, '0')}:${(value % 60).toString().padLeft(2, '0')}';

String _clock(DateTime t) => _minuteClock(t.hour * 60 + t.minute);

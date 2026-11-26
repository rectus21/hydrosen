import 'package:flutter/material.dart';

import '../../app/frosted_panel.dart';
import '../../domain/reminder_planner.dart';
import '../home/reminder_controller.dart';
import 'reminder_notifier.dart';

/// Hatırlatıcı sekmesi: açma/kapama, uyanık saatler, aralık, akıllı ayarlar
/// ve tarayıcı bildirimi izni.
class ReminderSection extends StatefulWidget {
  const ReminderSection({
    super.key,
    required this.controller,
    this.webNotifier,
  });

  final ReminderController controller;

  /// Tarayıcı bildirim kanalı; verilmezse izin satırı gösterilmez.
  final ReminderNotifier? webNotifier;

  @override
  State<ReminderSection> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends State<ReminderSection> {
  ReminderController get c => widget.controller;
  ReminderPermission? _permission;

  @override
  void initState() {
    super.initState();
    _permission = widget.webNotifier?.permission;
  }

  Future<void> _askPermission() async {
    final n = widget.webNotifier;
    if (n == null) return;
    final result = await n.requestPermission();
    if (mounted) setState(() => _permission = result);
  }

  Future<void> _pickTime(BuildContext context, bool start) async {
    final minute = start ? c.startMinute : c.endMinute;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
      helpText: start ? 'Başlangıç saati' : 'Bitiş saati',
    );
    if (picked == null || !context.mounted) return;
    final value = picked.hour * 60 + picked.minute;
    final error = start
        ? ReminderPlanner.validateWindow(value, c.endMinute)
        : ReminderPlanner.validateWindow(c.startMinute, value);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (start) {
      await c.configure(start: value);
    } else {
      await c.configure(end: value);
    }
  }

  String _nextText(ReminderPlan plan) {
    final at = plan.at;
    if (at == null) return 'Sonraki hatırlatma: yok';
    final now = c.now;
    if (!at.isAfter(now)) return 'Sonraki hatırlatma: şimdi';
    final day = DateUtils.isSameDay(at, now) ? '' : 'Yarın ';
    return 'Sonraki hatırlatma: $day${_clock(at)}';
  }

  String _nextHint(ReminderPlan plan) => switch (plan.reason) {
    ReminderQuiet.goalReached =>
      'Bugünkü hedef tamam, bugün sessiz kalıyorum. Aferin!',
    ReminderQuiet.capReached => 'Bugünlük hatırlatmalar tamam.',
    ReminderQuiet.endOfDay => 'Bugünlük bu kadar, iyi dinlenmeler.',
    ReminderQuiet.invalidWindow =>
      'Uyanık saatleri biraz genişletirsen hatırlatma gelir.',
    ReminderQuiet.none =>
      plan.kind == ReminderKind.retry
          ? 'Yumuşak bir hatırlatma: bir yudum içmediysen sorarım.'
          : 'Son içtiğin andan itibaren sayılır.',
  };

  @override
  Widget build(BuildContext context) {
    final plan = c.plan;
    final perm = _permission;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SceneTitle('Su hatırlatıcısı'),
            const SizedBox(height: 12),
            FrostedPanel(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Hatırlatıcı açık'),
                    subtitle: const Text(
                      'Karakterin susayınca sana nazikçe haber verir',
                    ),
                    value: c.enabled,
                    onChanged: (value) => c.configure(active: value),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.wb_sunny_outlined),
                    title: const Text('Başlangıç'),
                    trailing: Text(_minuteClock(c.startMinute)),
                    onTap: () => _pickTime(context, true),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.nights_stay_outlined),
                    title: const Text('Bitiş'),
                    trailing: Text(_minuteClock(c.endMinute)),
                    onTap: () => _pickTime(context, false),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: c.intervalMinute,
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
                      DropdownMenuItem(value: 180, child: Text('3 saatte bir')),
                    ],
                    onChanged: (value) {
                      if (value != null) c.configure(interval: value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FrostedPanel(
              child: ListTile(
                key: const ValueKey('next-reminder'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text(c.enabled ? _nextText(plan) : 'Hatırlatıcı kapalı'),
                subtitle: Text(
                  c.enabled
                      ? _nextHint(plan)
                      : 'Açmak için yukarıdaki anahtarı kullan.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            FrostedPanel(
              child: Column(
                children: [
                  SwitchListTile(
                    key: const ValueKey('stop-at-goal'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Hedefe ulaşınca sus'),
                    subtitle: const Text(
                      'Günlük hedef tamamlanınca o gün hatırlatma gelmez',
                    ),
                    value: c.stopAtGoal,
                    onChanged: (value) => c.configure(stopAtGoalValue: value),
                  ),
                  const Divider(),
                  ListTile(
                    key: const ValueKey('daily-cap'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Günlük en fazla'),
                    subtitle: Text('${c.dailyCap} hatırlatma'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          key: const ValueKey('daily-cap-minus'),
                          tooltip: 'Azalt',
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: c.dailyCap > ReminderPlanner.minDailyCap
                              ? () => c.configure(cap: c.dailyCap - 1)
                              : null,
                        ),
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${c.dailyCap}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          key: const ValueKey('daily-cap-plus'),
                          tooltip: 'Artır',
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: c.dailyCap < ReminderPlanner.maxDailyCap
                              ? () => c.configure(cap: c.dailyCap + 1)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (perm != null && perm != ReminderPermission.unsupported) ...[
              const SizedBox(height: 12),
              FrostedPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.web_asset_outlined),
                      title: const Text('Tarayıcı bildirimi'),
                      subtitle: Text(switch (perm) {
                        ReminderPermission.granted =>
                          'Açık. Sekme arka plandayken bildirim gelir.',
                        ReminderPermission.denied =>
                          'Tarayıcı bildirimi engelledi. Adres çubuğundaki '
                              'kilit simgesinden izin verebilirsin.',
                        _ =>
                          'Bu sekme arka plandayken de haber vermemi ister '
                              'misin?',
                      }),
                    ),
                    if (perm == ReminderPermission.notAsked)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          key: const ValueKey('ask-notification'),
                          onPressed: _askPermission,
                          icon: const Icon(Icons.notifications_outlined),
                          label: const Text('Bildirimlere izin ver'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            FrostedPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Hatırlatmalar uygulama açıkken görünür. Telefonda arka plan '
                'bildirimi, uygulama telefona kurulunca eklenecek.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _minuteClock(int value) =>
    '${(value ~/ 60).toString().padLeft(2, '0')}:${(value % 60).toString().padLeft(2, '0')}';

String _clock(DateTime t) => _minuteClock(t.hour * 60 + t.minute);

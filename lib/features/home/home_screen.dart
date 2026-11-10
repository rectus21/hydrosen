import 'package:flutter/material.dart';

import '../../app/app_look.dart';
import '../../data/water_repository.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_screen.dart';
import '../thermos/celebration_overlay.dart';
import '../thermos/thermos_theme.dart';
import '../thermos/thermos_view.dart';
import 'water_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.settings,
  });

  final WaterRepository repository;
  final SettingsController settings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WaterController _controller;
  static const _quickAmounts = [150, 250, 330, 500];

  @override
  void initState() {
    super.initState();
    _controller = WaterController(
      repository: widget.repository,
      goalMl: widget.settings.goalMl,
    )..load();
    widget.settings.addListener(_syncGoal);
  }

  void _syncGoal() => _controller.goalMl = widget.settings.goalMl;

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(controller: widget.settings),
      ),
    );
  }

  @override
  void dispose() {
    widget.settings.removeListener(_syncGoal);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addCustom() async {
    final value = await showDialog<int>(
      context: context,
      builder: (context) => const CustomAmountDialog(),
    );
    if (value != null) _controller.add(value);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('HydroSen'),
          actions: [
            IconButton(
              tooltip: 'Ayarlar',
              icon: const Icon(Icons.settings_outlined),
              onPressed: _openSettings,
            ),
          ],
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: Listenable.merge([_controller, widget.settings]),
            builder: (context, _) =>
                !_controller.loaded || !widget.settings.loaded
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (_controller.saveFailed)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Kayıtlar cihaza saklanamadı; uygulamayı kapatırsan kaybolabilir.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          _ThermosSection(
                            controller: _controller,
                            shape: widget.settings.shape,
                            theme: widget.settings.theme,
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final ml in _quickAmounts)
                                FilledButton.tonalIcon(
                                  onPressed: () => _controller.add(ml),
                                  icon: const Icon(Icons.water_drop_outlined),
                                  label: Text('$ml ml'),
                                ),
                              OutlinedButton.icon(
                                onPressed: _addCustom,
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Özel'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Bugün',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Column(
                                children: [
                                  if (_controller.todayEntries.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      child: Text(
                                        'Henüz su kaydı yok. Yukarıdan ilk bardağını ekle.',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    )
                                  else
                                    for (final e in _controller.todayEntries)
                                      ListTile(
                                        key: ValueKey(e.id),
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(Icons.water_drop),
                                        title: Text('${e.amountMl} ml'),
                                        subtitle: Text(_formatTime(e.time)),
                                        trailing: IconButton(
                                          tooltip: 'Sil',
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          onPressed: () =>
                                              _controller.remove(e.id),
                                        ),
                                      ),
                                ],
                              ),
                            ),
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

  static String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

/// Özel miktar penceresi. Metin denetleyicisini kendi ömrüyle yönetir; böylece
/// pencere kapanma animasyonu sürerken denetleyici erken atılmaz.
class CustomAmountDialog extends StatefulWidget {
  const CustomAmountDialog({super.key});

  static const maxMl = 5000;

  @override
  State<CustomAmountDialog> createState() => _CustomAmountDialogState();
}

class _CustomAmountDialogState extends State<CustomAmountDialog> {
  final _text = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final v = int.tryParse(_text.text.trim());
    if (v == null || v <= 0 || v > CustomAmountDialog.maxMl) {
      setState(
        () => _error = '1–${CustomAmountDialog.maxMl} arasında bir sayı gir',
      );
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Özel miktar (ml)'),
      content: TextField(
        controller: _text,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: 'Örn. 200', errorText: _error),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Ekle')),
      ],
    );
  }
}

class _ThermosSection extends StatelessWidget {
  const _ThermosSection({
    required this.controller,
    required this.shape,
    required this.theme,
  });

  final WaterController controller;
  final ThermosShape shape;
  final ThermosTheme theme;

  @override
  Widget build(BuildContext context) {
    final percent = (controller.progress * 100).round();
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        SizedBox(
          height: 380,
          child: Stack(
            children: [
              ThermosView(
                progress: controller.progress,
                goalMl: controller.goalMl,
                totalMl: controller.totalMl,
                celebrations: controller.celebrations,
                shape: shape,
                theme: theme,
                happy: controller.progress >= 1,
              ),
              Positioned.fill(
                child: CelebrationOverlay(
                  trigger: controller.celebrations,
                  theme: theme,
                  shape: shape,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('${controller.totalMl} ml', style: text.headlineMedium),
            const SizedBox(width: 8),
            Text('hedef ${controller.goalMl} ml', style: text.bodyMedium),
          ],
        ),
        Text(
          controller.progress >= 1 ? 'Hedefe ulaştın!' : '%$percent tamamlandı',
          style: text.titleMedium,
        ),
      ],
    );
  }
}

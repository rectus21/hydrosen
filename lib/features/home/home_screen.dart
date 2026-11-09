import 'package:flutter/material.dart';

import '../../data/water_repository.dart';
import '../thermos/thermos_theme.dart';
import '../thermos/thermos_view.dart';
import 'water_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final WaterRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WaterController _controller;
  static const _quickAmounts = [150, 250, 330, 500];

  /// Şimdilik bellekte; ayarlar ekranıyla kalıcı olacak.
  ThermosShape _shape = ThermosShape.chubby;
  ThermosTheme _theme = ThermosTheme.classic;

  @override
  void initState() {
    super.initState();
    _controller = WaterController(repository: widget.repository)..load();
  }

  @override
  void dispose() {
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
    return Scaffold(
      appBar: AppBar(title: const Text('HydroSen')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => !_controller.loaded
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
                          shape: _shape,
                          theme: _theme,
                          onShapeChanged: (s) => setState(() => _shape = s),
                          onThemeChanged: (t) => setState(() => _theme = t),
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
                        if (_controller.todayEntries.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Henüz su kaydı yok. Yukarıdan ilk bardağını ekle.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
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
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _controller.remove(e.id),
                              ),
                            ),
                      ],
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
    required this.onShapeChanged,
    required this.onThemeChanged,
  });

  final WaterController controller;
  final ThermosShape shape;
  final ThermosTheme theme;
  final ValueChanged<ThermosShape> onShapeChanged;
  final ValueChanged<ThermosTheme> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final percent = (controller.progress * 100).round();
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        SizedBox(
          height: 380,
          child: ThermosView(
            progress: controller.progress,
            goalMl: controller.goalMl,
            shape: shape,
            theme: theme,
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
        const SizedBox(height: 12),
        SegmentedButton<ThermosShape>(
          segments: [
            for (final s in ThermosShape.values)
              ButtonSegment(value: s, label: Text(s.label)),
          ],
          selected: {shape},
          showSelectedIcon: false,
          onSelectionChanged: (s) => onShapeChanged(s.first),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final t in ThermosTheme.all)
              ChoiceChip(
                label: Text(t.name),
                selected: t == theme,
                onSelected: (_) => onThemeChanged(t),
              ),
          ],
        ),
      ],
    );
  }
}

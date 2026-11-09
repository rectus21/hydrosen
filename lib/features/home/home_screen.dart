import 'package:flutter/material.dart';

import '../../data/water_repository.dart';
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
                        _ProgressRing(controller: _controller),
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

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.controller});

  final WaterController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (controller.progress * 100).round();
    return Column(
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: controller.progress),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, _) => Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 16,
                  strokeCap: StrokeCap.round,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${controller.totalMl} ml',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'hedef ${controller.goalMl} ml',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          controller.progress >= 1 ? 'Hedefe ulaştın!' : '%$percent tamamlandı',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

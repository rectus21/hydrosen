import 'package:flutter/material.dart';

import 'water_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WaterController _controller = WaterController();
  static const _quickAmounts = [150, 250, 330, 500];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addCustom() async {
    final text = TextEditingController();
    final value = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Özel miktar (ml)'),
        content: TextField(
          controller: text,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Örn. 200'),
          onSubmitted: (v) => Navigator.pop(context, int.tryParse(v)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(text.text)),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
    text.dispose();
    if (value != null) _controller.add(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HydroSen')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
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
                  Text('Bugün', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_controller.entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Henüz su kaydı yok. Yukarıdan ilk bardağını ekle.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    )
                  else
                    for (final e in _controller.entries)
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

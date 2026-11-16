import 'package:flutter/material.dart';

import '../../app/app_look.dart';
import '../../app/frosted_panel.dart';
import '../../data/water_repository.dart';
import '../../domain/glass_math.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_screen.dart';
import '../thermos/celebration_overlay.dart';
import '../thermos/thermos_theme.dart';
import '../thermos/thermos_view.dart';
import 'glass_row.dart';
import 'quick_glass_buttons.dart';
import 'quick_theme_strip.dart';
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
  final _scroll = ScrollController();
  final _thermosKey = GlobalKey();

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
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _addCustom() async {
    final value = await showDialog<int>(
      context: context,
      builder: (context) => const CustomAmountDialog(),
    );
    if (value == null) return;
    _controller.add(value);
    _notify('$value ml eklendi');
  }

  /// Her ekleme/çıkarma/silmeden sonra "Geri al" düğmeli bilgi çubuğu.
  void _notify(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(label: 'Geri al', onPressed: _controller.undo),
        ),
      );
  }

  void _addGlass() {
    _controller.add(widget.settings.glassMl);
    _notify('1 bardak eklendi');
  }

  void _addGlasses(int n) {
    _controller.add(widget.settings.glassMl * n);
    _notify('$n bardak eklendi');
  }

  void _removeGlass() {
    _controller.removeAmount(widget.settings.glassMl);
    _notify('1 bardak çıkarıldı');
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBackdrop(
      thermosKey: _thermosKey,
      scroll: _scroll,
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
                        controller: _scroll,
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
                            thermosKey: _thermosKey,
                            controller: _controller,
                            glassMl: widget.settings.glassMl,
                            shape: widget.settings.shape,
                            theme: widget.settings.theme,
                            animatedCelebrations:
                                widget.settings.animatedCelebrations,
                          ),
                          if (kQuickThemeStrip) ...[
                            const SizedBox(height: 12),
                            QuickThemeStrip(settings: widget.settings),
                          ],
                          const SizedBox(height: 16),
                          FrostedPanel(
                            child: Column(
                              children: [
                                GlassRow(
                                  glass: GlassMath(
                                    goalMl: _controller.goalMl,
                                    glassMl: widget.settings.glassMl,
                                  ),
                                  totalMl: _controller.totalMl,
                                  theme: widget.settings.theme,
                                  onAdd: _addGlass,
                                  onRemove: _removeGlass,
                                ),
                                const SizedBox(height: 12),
                                QuickGlassButtons(
                                  glassMl: widget.settings.glassMl,
                                  onAdd: _addGlasses,
                                  onRemove: _controller.totalMl > 0
                                      ? _removeGlass
                                      : null,
                                ),
                                const SizedBox(height: 4),
                                Center(
                                  child: TextButton.icon(
                                    onPressed: _addCustom,
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Özel miktar'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          FrostedPanel(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bugünün kayıtları',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                if (_controller.todayEntries.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    child: Text(
                                      'Henüz su kaydı yok. Yukarıdaki bardaklara dokunarak ilk bardağını ekle.',
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
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () {
                                          _controller.remove(e.id);
                                          _notify('Kayıt silindi');
                                        },
                                      ),
                                    ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
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

class _ThermosSection extends StatefulWidget {
  const _ThermosSection({
    required this.thermosKey,
    required this.controller,
    required this.glassMl,
    required this.shape,
    required this.theme,
    required this.animatedCelebrations,
  });

  final bool animatedCelebrations;
  final GlobalKey thermosKey;
  final WaterController controller;
  final int glassMl;
  final ThermosShape shape;
  final ThermosTheme theme;

  @override
  State<_ThermosSection> createState() => _ThermosSectionState();
}

class _ThermosSectionState extends State<_ThermosSection> {
  /// Kutlama ilerlemesi: overlay yazar, termos kapak hareketi için okur.
  final _celebrationT = ValueNotifier<double?>(null);

  /// Döngü evresi (hedef aşıldıkça): birikimli tur sayısı, yoksa null.
  final _celebrationLoop = ValueNotifier<double?>(null);

  WaterController get controller => widget.controller;
  int get glassMl => widget.glassMl;
  ThermosShape get shape => widget.shape;
  ThermosTheme get theme => widget.theme;

  @override
  void dispose() {
    _celebrationT.dispose();
    _celebrationLoop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (controller.progress * 100).round();
    final glass = GlassMath(goalMl: controller.goalMl, glassMl: glassMl);
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        SizedBox(
          height: 380,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ThermosView(
                key: widget.thermosKey,
                progress: controller.progress,
                goalMl: controller.goalMl,
                totalMl: controller.totalMl,
                celebrations: controller.celebrations,
                shape: shape,
                theme: theme,
                happy: controller.progress >= 1,
                celebrationT: _celebrationT,
                celebrationLoop: _celebrationLoop,
                animatedCelebrations: widget.animatedCelebrations,
              ),
              Positioned.fill(
                child: CelebrationOverlay(
                  trigger: controller.celebrations,
                  theme: theme,
                  shape: shape,
                  progress: _celebrationT,
                  looping: controller.progress >= 1,
                  loopProgress: _celebrationLoop,
                  animated: widget.animatedCelebrations,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FrostedPanel(
          radius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${GlassMath.format(glass.glassesOf(controller.totalMl))} / '
                    '${glass.goalGlasses}',
                    style: text.headlineMedium,
                  ),
                  const SizedBox(width: 8),
                  Text('bardak', style: text.titleMedium),
                ],
              ),
              Text(
                '${controller.totalMl} / ${controller.goalMl} ml',
                style: text.bodySmall,
              ),
              Text(
                controller.progress >= 1
                    ? 'Hedefe ulaştın!'
                    : '%$percent tamamlandı',
                style: text.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/app_look.dart';
import '../../app/frosted_panel.dart';
import '../../data/water_repository.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_screen.dart';
import '../thermos/celebration_overlay.dart';
import '../thermos/illustrated_artwork.dart';
import '../thermos/thermos_painter.dart' show designRect;
import '../thermos/thermos_theme.dart';
import '../thermos/thermos_view.dart';
import 'home_sections.dart';
import 'quick_glass_buttons.dart';
import 'reminder_controller.dart';
import 'resin_button.dart';
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
  late final ReminderController _reminder;
  final _scroll = ScrollController();
  final _thermosKey = GlobalKey();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _controller = WaterController(
      repository: widget.repository,
      goalMl: widget.settings.goalMl,
    )..load();
    _reminder = ReminderController(onDue: _showReminder)..load();
    widget.settings.addListener(_syncGoal);
  }

  void _showReminder() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Su içme zamanı! Bir bardak su eklemeyi unutma.'),
      ),
    );
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
    _reminder.dispose();
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
  }

  void _addGlasses(int n) {
    _controller.add(widget.settings.glassMl * n);
  }

  void _removeGlass() {
    _controller.removeAmount(widget.settings.glassMl);
  }

  /// Uygulama çubuğu başlık/ikon rengi: sahnenin üst bandı koyuysa açık, açıksa
  /// koyu (+ zıt renkli yumuşak gölge). Sahnesiz temalarda tema rengi.
  (Color, Color) _barForeground(BuildContext context) {
    final luma = IllustratedArtwork.topLuma[widget.settings.theme.id];
    if (luma == null) {
      final c = Theme.of(context).colorScheme.onSurface;
      return (c, Colors.transparent);
    }
    return luma < 0.45
        ? (const Color(0xFFFFFFFF), const Color(0x99000000))
        : (const Color(0xFF1B1B1F), const Color(0x88FFFFFF));
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBackdrop(
      thermosKey: _thermosKey,
      scroll: _scroll,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: ListenableBuilder(
            listenable: widget.settings,
            builder: (context, _) {
              final luma = IllustratedArtwork.topLuma[widget.settings.theme.id];
              if (luma == null) return const SizedBox.shrink();
              // Başlığın arkasına zıt renkli yumuşak perde: orta tonlu
              // sahnelerde de okunur kalır.
              final scrim = luma < 0.45 ? 0xFF000000 : 0xFFFFFFFF;
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(scrim).withValues(alpha: 0.5),
                      Color(scrim).withValues(alpha: 0),
                    ],
                  ),
                ),
              );
            },
          ),
          title: ListenableBuilder(
            listenable: widget.settings,
            builder: (context, _) {
              final fg = _barForeground(context);
              return Text(
                'HydroSen',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: fg.$1,
                  shadows: [Shadow(color: fg.$2, blurRadius: 6)],
                ),
              );
            },
          ),
          actions: [
            ListenableBuilder(
              listenable: widget.settings,
              builder: (context, _) {
                final fg = _barForeground(context);
                return IconButton(
                  tooltip: 'Ayarlar',
                  icon: Icon(
                    Icons.settings_outlined,
                    color: fg.$1,
                    shadows: [Shadow(color: fg.$2, blurRadius: 6)],
                  ),
                  onPressed: _openSettings,
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: Listenable.merge([
              _controller,
              widget.settings,
              _reminder,
            ]),
            builder: (context, _) =>
                !_controller.loaded || !widget.settings.loaded
                ? const Center(child: CircularProgressIndicator())
                : _selectedTab == 1
                ? RecordsSection(
                    controller: _controller,
                    onDelete: (id) {
                      _controller.remove(id);
                    },
                  )
                : _selectedTab == 2
                ? ReminderSection(controller: _reminder)
                : _selectedTab == 3
                ? ThemeSection(
                    settings: widget.settings,
                    onOpenSettings: _openSettings,
                  )
                : _selectedTab == 4
                ? ProfileSection(
                    settings: widget.settings,
                    onOpenSettings: _openSettings,
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
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
                            shape: widget.settings.shape,
                            theme: widget.settings.theme,
                            animatedCelebrations:
                                widget.settings.animatedCelebrations,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        bottomNavigationBar: ListenableBuilder(
          listenable: Listenable.merge([_controller, widget.settings]),
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedTab == 0 &&
                  _controller.loaded &&
                  widget.settings.loaded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: _DailyControlCard(
                        controller: _controller,
                        glassMl: widget.settings.glassMl,
                        onAdd: _addGlasses,
                        onRemove: _controller.totalMl > 0 ? _removeGlass : null,
                        onCustom: _addCustom,
                      ),
                    ),
                  ),
                ),
              _BottomTabs(
                selected: _selectedTab,
                onSelected: (index) => setState(() => _selectedTab = index),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyControlCard extends StatelessWidget {
  const _DailyControlCard({
    required this.controller,
    required this.glassMl,
    required this.onAdd,
    required this.onRemove,
    required this.onCustom,
  });

  final WaterController controller;
  final int glassMl;
  final void Function(int glasses) onAdd;
  final VoidCallback? onRemove;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rawPercent = controller.goalMl == 0
        ? 0
        : (controller.totalMl / controller.goalMl * 100).round();
    return FrostedPanel(
      key: const ValueKey('daily-control-card'),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      radius: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${controller.totalMl} / ${controller.goalMl} ml',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 1),
          Text(
            'Günlük hedefin %$rawPercent’i',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: controller.progress,
              minHeight: 7,
              backgroundColor: scheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
            ),
          ),
          const SizedBox(height: 6),
          QuickGlassButtons(glassMl: glassMl, onAdd: onAdd, onRemove: onRemove),
          const SizedBox(height: 6),
          Semantics(
            label: 'Özel miktar',
            excludeSemantics: true,
            button: true,
            onTap: onCustom,
            child: ResinButton(
              tone: ResinTone.glass,
              width: 220,
              height: 40,
              onPressed: onCustom,
              builder: (context, color) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    'Özel miktar',
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomTabs extends StatelessWidget {
  const _BottomTabs({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  static const _labels = [
    'Günlük',
    'Kayıtlar',
    'Hatırlatıcı',
    'Tema',
    'Profil',
  ];
  static const _icons = [
    Icons.today_outlined,
    Icons.receipt_long_outlined,
    Icons.notifications_outlined,
    Icons.palette_outlined,
    Icons.person_outline,
  ];
  static const _selectedIcons = [
    Icons.today,
    Icons.receipt_long,
    Icons.notifications,
    Icons.palette,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: FrostedPanel(
          key: const ValueKey('bottom-tabs'),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          radius: 20,
          child: Row(
            children: [
              for (var i = 0; i < _labels.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: selected == i,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => onSelected(i),
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          color: selected == i
                              ? scheme.primaryContainer.withValues(alpha: 0.9)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selected == i ? _selectedIcons[i] : _icons[i],
                              size: 22,
                              color: selected == i
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _labels[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: selected == i
                                        ? scheme.onPrimaryContainer
                                        : scheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
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
    required this.shape,
    required this.theme,
    required this.animatedCelebrations,
  });

  final bool animatedCelebrations;
  final GlobalKey thermosKey;
  final WaterController controller;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Geniş ekranda termos önceki sürümden belirgin biçimde daha büyük;
        // telefonda ise sabit 600 px boşluk bırakmadan mevcut genişliği tam
        // kullanır. Tasarım oranı ressamın gerçek tuvaliyle aynı kalır.
        final naturalHeight =
            constraints.maxWidth * designRect.height / designRect.width;
        final baseHeight = naturalHeight.clamp(0.0, 600.0);
        // Termos büyütme katsayısı (Rectus, 2026-11-22): tuvalin kenar
        // boşlukları büyük olduğu için görsel yakınlaştırılır; yerleşim
        // yüksekliği de aynı oranda artar ki alttaki panel üstüne binmesin.
        const zoom = kThermosZoom;
        return SizedBox(
          height: baseHeight,
          child: Center(
            child: Transform.translate(
              // Şişeyi biraz aşağı indir (Rectus, 2026-11-22).
              offset: Offset(0, baseHeight * kThermosDrop),
              child: Transform.scale(
                scale: zoom,
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: baseHeight,
                  width: constraints.maxWidth,
                  child: _thermosStack(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _thermosStack() {
    final controller = widget.controller;
    final shape = widget.shape;
    final theme = widget.theme;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
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
    );
  }
}

/// Ana ekrandaki termosun büyütme katsayısı (1.0 = ChatGPT sürümünün ilk hâli).
const double kThermosZoom = 1.375;

/// Şişenin aşağı kayma oranı (taban yüksekliğinin kesri).
const double kThermosDrop = 0.16;

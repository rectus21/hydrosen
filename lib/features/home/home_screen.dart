import 'package:flutter/material.dart';

import '../../app/app_look.dart';
import '../../app/frosted_panel.dart';
import '../../data/streak_repository.dart';
import '../../data/water_repository.dart';
import '../../domain/app_settings.dart';
import '../../domain/drink_type.dart';
import '../../domain/saved_container.dart';
import '../badges/badge_popup.dart';
import '../badges/streak_line.dart';
import '../../domain/streak.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_screen.dart';
import '../thermos/celebration_overlay.dart';
import '../thermos/illustrated_artwork.dart';
import '../thermos/thermos_painter.dart' show designRect;
import '../thermos/thermos_theme.dart';
import '../thermos/thermos_view.dart';
import 'drink_widgets.dart';
import 'home_sections.dart';
import 'quick_glass_buttons.dart';
import '../../domain/reminder_messages.dart';
import '../reminder/reminder_banner.dart';
import '../reminder/reminder_notifier.dart';
import '../reminder/web_notifier.dart';
import 'reminder_controller.dart';
import 'resin_button.dart';
import 'water_controller.dart';
import '../../services/widget_bridge.dart';
import '../backup/backup_io_base.dart';
import '../backup/backup_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.settings,
    this.streakRepository,
    this.widgetBridge,
    this.backupIo,
  });

  final WaterRepository repository;
  final StreakRepository? streakRepository;
  final SettingsController settings;

  /// Ana ekran widget köprüsü (varsayılan: boş).
  final WidgetBridge? widgetBridge;
  final BackupFileIO? backupIo;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final WaterController _controller;
  late final ReminderController _reminder;
  late final ReminderNotifier _webNotifier = createWebNotifier();
  late final ReminderDelivery _delivery;
  late final WidgetSnapshotPublisher _widgetPublisher;
  late final BackupService _backup;
  final _scroll = ScrollController();
  final _thermosKey = GlobalKey();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _controller = WaterController(
      repository: widget.repository,
      goalMl: widget.settings.goalMl,
      streakRepository: widget.streakRepository,
    )..load();
    WidgetsBinding.instance.addObserver(this);
    _delivery = ReminderDelivery([
      InAppReminderNotifier(_showBanner),
      _webNotifier,
    ]);
    _reminder = ReminderController(
      onDue: _showReminder,
      contextProvider: _reminderContext,
    )..load();
    widget.settings.addListener(_syncGoal);
    _widgetPublisher = WidgetSnapshotPublisher(
      water: _controller,
      settings: widget.settings,
      bridge: widget.widgetBridge ?? const NoopWidgetBridge(),
    );
    _backup = BackupService(
      water: _controller,
      settings: widget.settings,
      reminder: _reminder,
    );
  }

  /// Hatırlatıcının bilmesi gereken bugünkü durum: son kayıt ve hedef.
  ReminderContext _reminderContext() {
    final today = _controller.todayEntries;
    return ReminderContext(
      lastDrink: today.isEmpty ? null : today.first.time,
      goalReached:
          _controller.goalMl > 0 && _controller.totalMl >= _controller.goalMl,
    );
  }

  void _showReminder() {
    if (!mounted) return;
    final theme = widget.settings.theme;
    final kind = _reminder.lastKind;
    _delivery.deliver(
      ReminderMessage(
        title: 'HydroSen',
        body: ReminderMessages.pick(
          themeId: theme.id,
          name: widget.settings.bottleName,
          kind: kind,
          index: _reminder.sentToday - 1,
        ),
        themeId: theme.id,
        kind: kind,
      ),
    );
  }

  void _showBanner(ReminderMessage message) {
    if (!mounted) return;
    showReminderBanner(context, message, widget.settings.theme);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Gece yarısı geçmiş olabilir: seriyi yeni güne getir.
    if (state == AppLifecycleState.resumed) _controller.refresh();
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
    WidgetsBinding.instance.removeObserver(this);
    widget.settings.removeListener(_syncGoal);
    _widgetPublisher.dispose();
    _controller.dispose();
    _reminder.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _addCustom() async {
    final value = await showDialog<CustomAmountResult>(
      context: context,
      builder: (context) =>
          CustomAmountDialog(containers: widget.settings.containers),
    );
    if (value == null) return;
    _controller.add(value.amountMl, drink: value.drink);
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
      final theme = Theme.of(context);
      final c =
          (theme.extension<ClayColors>()?.look.scheme ?? theme.colorScheme)
              .onSurface;
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
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              flexibleSpace: ListenableBuilder(
                listenable: widget.settings,
                builder: (context, _) {
                  final luma =
                      IllustratedArtwork.topLuma[widget.settings.theme.id];
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
            body: Stack(
              children: [
                Positioned.fill(
                  child: SafeArea(
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
                              containers: widget.settings.containers,
                              onDelete: (id) {
                                _controller.remove(id);
                              },
                            )
                          : _selectedTab == 2
                          ? ReminderSection(
                              controller: _reminder,
                              webNotifier: _webNotifier,
                            )
                          : _selectedTab == 3
                          ? ThemeSection(
                              settings: widget.settings,
                              onOpenSettings: _openSettings,
                            )
                          : _selectedTab == 4
                          ? ProfileSection(
                              settings: widget.settings,
                              controller: _controller,
                              onOpenSettings: _openSettings,
                              backup: _backup,
                              backupIo: widget.backupIo,
                            )
                          : Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 560,
                                ),
                                child: ListView(
                                  controller: _scroll,
                                  padding: const EdgeInsets.all(16),
                                  children: [
                                    if (_controller.saveFailed)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: Text(
                                          'Kayıtlar cihaza saklanamadı; uygulamayı kapatırsan kaybolabilir.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                (Theme.of(context)
                                                            .extension<
                                                              ClayColors
                                                            >()
                                                            ?.look
                                                            .scheme ??
                                                        Theme.of(context)
                                                            .colorScheme)
                                                    .error,
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
                                      celebrationText:
                                          ReminderMessages.celebration(
                                            widget.settings.customBottleName,
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
              ],
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
                            themeId: widget.settings.theme.id,
                            glassMl: widget.settings.glassMl,
                            streak: _controller.streak,
                            onAdd: _addGlasses,
                            onRemove: _controller.totalMl > 0
                                ? _removeGlass
                                : null,
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
          // Kutlama her sekmenin ve alt çubuğun üstünde, dokunuşu engellemeden.
          Positioned.fill(child: BadgePopupHost(controller: _controller)),
        ],
      ),
    );
  }
}

class _DailyControlCard extends StatelessWidget {
  const _DailyControlCard({
    required this.controller,
    required this.themeId,
    required this.glassMl,
    required this.streak,
    required this.onAdd,
    required this.onRemove,
    required this.onCustom,
  });

  final StreakStatus streak;

  final WaterController controller;
  final String themeId;
  final int glassMl;
  final void Function(int glasses) onAdd;
  final VoidCallback? onRemove;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final rawPercent = controller.goalMl == 0
        ? 0
        : (controller.totalMl / controller.goalMl * 100).round();
    // Kart zemini yok: metin çıplak sahne üstünde, "mürekkep" temasıyla okunur.
    // Düğmeler panel temasında kalır (reçine renkleri ona göre türetilir).
    return Padding(
      key: const ValueKey('daily-control-card'),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkTheme(
            child: Builder(
              builder: (context) {
                final scheme = Theme.of(context).colorScheme;
                // Sahnenin alt bandı koyuysa (ör. karaejderha) mürekkep teması
                // okunmaz: açık yazı + koyu gölge; aksi halde mürekkep rengi.
                final luma = IllustratedArtwork.bottomLuma[themeId];
                final dark = luma != null && luma < 0.45;
                final fg = dark ? const Color(0xFFFFFFFF) : scheme.onSurface;
                final shadows = dark
                    ? const [Shadow(color: Color(0xCC000000), blurRadius: 6)]
                    : const <Shadow>[];
                final fill = dark
                    ? Color.lerp(scheme.primary, Colors.white, 0.65)!
                    : scheme.primary;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${controller.totalMl} / ${controller.goalMl} ml',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: fg,
                        shadows: shadows,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Günlük hedefin %$rawPercent’i',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                        shadows: shadows,
                      ),
                    ),
                    const SizedBox(height: 2),
                    StreakLine(status: streak, fg: fg, shadows: shadows),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: controller.progress,
                        minHeight: 7,
                        color: fill,
                        backgroundColor: fg.withValues(alpha: 0.16),
                      ),
                    ),
                  ],
                );
              },
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
              height: 48,
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

  /// Seçili sekme içeri basılmış (iç gölgeli) görünür; diğerleri düz.
  Widget _tabBody(BuildContext context, int i) {
    final scheme = Theme.of(context).colorScheme;
    final sel = selected == i;
    final fg = sel ? scheme.primary : scheme.onSurface;
    final body = Container(
      height: 58,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(sel ? _selectedIcons[i] : _icons[i], size: 22, color: fg),
          const SizedBox(height: 2),
          Text(
            _labels[i],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // Küçük etiket kenar yumuşatmasıyla silikleşmesin: kalın yazı.
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: sel ? FontWeight.w800 : FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
    return sel ? ClaySurface(inset: true, radius: 14, child: body) : body;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
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
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => onSelected(i),
                      child: _tabBody(context, i),
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

/// Özel miktar penceresinin sonucu: ham miktar ve içecek türü.
class CustomAmountResult {
  const CustomAmountResult(this.amountMl, this.drink);

  final int amountMl;
  final DrinkType drink;
}

/// Özel miktar penceresi: miktar, kayıtlı kap düğmeleri ve içecek türü.
/// Metin denetleyicisini kendi ömrüyle yönetir; böylece pencere kapanma
/// animasyonu sürerken denetleyici erken atılmaz.
class CustomAmountDialog extends StatefulWidget {
  const CustomAmountDialog({
    super.key,
    this.containers = AppSettings.defaultContainers,
  });

  static const maxMl = SavedContainer.maxMl;

  final List<SavedContainer> containers;

  @override
  State<CustomAmountDialog> createState() => _CustomAmountDialogState();
}

class _CustomAmountDialogState extends State<CustomAmountDialog> {
  final _text = TextEditingController();
  DrinkType _drink = DrinkType.water;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final v = parseAmount(_text.text, max: CustomAmountDialog.maxMl);
    if (v == null) {
      setState(
        () => _error = '1–${CustomAmountDialog.maxMl} arasında bir sayı gir',
      );
      return;
    }
    Navigator.pop(context, CustomAmountResult(v, _drink));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text('Özel miktar (ml)'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _text,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Örn. 200',
                errorText: _error,
              ),
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => _submit(),
            ),
            const FieldLabel('Kaplarım'),
            ContainerChips(
              containers: widget.containers,
              onPick: (c) => setState(() {
                _text.text = '${c.ml}';
                _error = null;
              }),
            ),
            const FieldLabel('İçecek'),
            DrinkChips(
              selected: _drink,
              onSelected: (d) => setState(() => _drink = d),
            ),
            CountedHint(amountText: _text.text, drink: _drink),
          ],
        ),
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
    required this.celebrationText,
  });

  final bool animatedCelebrations;
  final String celebrationText;
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
        // Uzun boyunlu zürafa daha yüksek durur; başı kırpılmasın diye
        // termos bu temada biraz küçülür.
        final zoom = widget.theme.id == 'zurafa'
            ? kZurafaThermosZoom
            : kThermosZoom;
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
            bannerText: widget.celebrationText,
          ),
        ),
      ],
    );
  }
}

/// Ana ekrandaki termosun büyütme katsayısı (1.0 = ChatGPT sürümünün ilk hâli).
const double kThermosZoom = 1.375;

/// Zürafa temasında termos büyütme katsayısı (uzun boyunlu kapak için).
const double kZurafaThermosZoom = 1.15;

/// Şişenin aşağı kayma oranı (taban yüksekliğinin kesri).
const double kThermosDrop = 0.16;

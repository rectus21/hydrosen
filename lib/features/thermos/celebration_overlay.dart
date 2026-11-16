import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'celebration_painter.dart';
import 'thermos_theme.dart';

/// Termosun üstüne yerleşen kutlama katmanı. [trigger] her değiştiğinde bir kez
/// oynar ([duration] sonra kendiliğinden kaybolur); ilk değerinde oynamaz.
/// Dokunmaları engellemez. "Animasyonları azalt" açıksa parçacık çizilmez,
/// parçacıklar hareket etmez; sabit tek kare ve kısa bir tebrik yazısı görünür.
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.trigger,
    required this.theme,
    required this.shape,
    this.duration = const Duration(milliseconds: 2600),
    this.progress,
    this.looping = false,
    this.loopProgress,
    this.animated = false,
  });

  /// Hedef aşılmış durumda mı: true oldukça giriş bittikten sonra (ya da
  /// açılışta hemen, girişsiz/yazısız) döngü evresi sürekli oynar.
  final bool looping;

  /// Döngü sırasında birikimli tur sayısı (tam kısım = tur, kesir = evre);
  /// döngü yokken null. ThermosView.celebrationLoop ile paylaşılır.
  final ValueNotifier<double?>? loopProgress;

  /// "Hareketli kutlamalar" ayarı: true ise sistem "animasyonları azalt"
  /// dese de kutlama tam oynar ve döngü çalışır.
  final bool animated;

  final int trigger;
  final ThermosTheme theme;
  final ThermosShape shape;
  final Duration duration;

  /// Verilirse kutlama süresince t (0..1), bitince null yazılır; ThermosView'ın
  /// celebrationT'si ile paylaşılarak kapak hareketi senkronlanır.
  final ValueNotifier<double?>? progress;

  static const message = 'Tebrikler! Günlük hedefe ulaştın.';

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  // preserve: "animasyonları azalt" süreyi kısaltmasın; yazı yine ~2,6 sn kalır.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
    animationBehavior: AnimationBehavior.preserve,
  );

  // Döngü: yalnız hedef aşılmışken ve görünürken çalışır (TickerMode ile
  // rota görünmezken otomatik susar).
  late final Ticker _loopTicker = createTicker(_onLoopTick);
  final _cycles = ValueNotifier<double>(0);
  bool _loopOn = false;
  bool _reduceMotion = false;

  bool get _animate => !_reduceMotion || widget.animated;

  static const _loopPeriodUs = CelebrationPainter.loopPeriod * 1e6;

  void _onLoopTick(Duration e) {
    _cycles.value = e.inMicroseconds / _loopPeriodUs;
    _publishLoop(_cycles.value);
  }

  void _setLoopOut(double? v) {
    final n = widget.loopProgress;
    if (n == null || n.value == v) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) n.value = v;
      });
    } else {
      n.value = v;
    }
  }

  void _publishLoop(double v) => _setLoopOut(v);

  /// Döngüyü gerekene göre başlatır/durdurur (giriş oynarken durur).
  void _syncLoop() {
    final want = widget.looping && _animate && !_c.isAnimating;
    if (want && !_loopOn) {
      _loopOn = true;
      _cycles.value = 0;
      _loopTicker.start();
      _publishLoop(0);
      if (mounted) setState(() {});
    } else if (!want && _loopOn) {
      _loopOn = false;
      _loopTicker.stop();
      _cycles.value = 0;
      _setLoopOut(null);
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _c.addListener(_publish);
    _c.addStatusListener((_) {
      _publish();
      _syncLoop();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    _syncLoop();
  }

  void _publish() {
    final n = widget.progress;
    if (n == null) return;
    final v = _c.isAnimating ? _c.value : null;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      // Build sırasında dinleyicileri tetikleme: kareden sonra yaz.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) n.value = _c.isAnimating ? _c.value : null;
      });
    } else {
      n.value = v;
    }
  }

  @override
  void didUpdateWidget(CelebrationOverlay old) {
    super.didUpdateWidget(old);
    if (widget.duration != old.duration) _c.duration = widget.duration;
    if (widget.trigger != old.trigger) _c.forward(from: 0);
    _syncLoop();
  }

  @override
  void dispose() {
    _loopTicker.dispose();
    _cycles.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ayar açıksa sistem "azalt" dese de tam hareket.
    final reduceMotion = _reduceMotion && !widget.animated;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([_c, _cycles]),
        builder: (context, _) {
          if (!_c.isAnimating) {
            if (!_loopOn) return const SizedBox.shrink();
            final cy = _cycles.value;
            return CustomPaint(
              size: Size.infinite,
              painter: CelebrationPainter.looping(
                theme: widget.theme,
                shape: widget.shape,
                loop: cy,
                loopCount: cy.floor(),
              ),
            );
          }
          final t = _c.value;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Animasyonları azalt açıkken hareket yok: kutlamanın ortasından
              // tek, sabit bir kare gösterilir (parıltılar, yazı).
              CustomPaint(
                painter: CelebrationPainter(
                  theme: widget.theme,
                  shape: widget.shape,
                  t: reduceMotion ? 0.5 : t,
                  reduceMotion: reduceMotion,
                ),
              ),
              Align(
                alignment: const Alignment(0, 0.82),
                child: Opacity(
                  opacity: reduceMotion ? 1 : _bannerOpacity(t),
                  child: Transform.scale(
                    scale: reduceMotion ? 1 : _bannerScale(t),
                    child: _Banner(theme: widget.theme),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static double _bannerOpacity(double t) {
    if (t < 0.1) return t / 0.1;
    if (t > 0.82) return ((1 - t) / 0.18).clamp(0.0, 1.0);
    return 1;
  }

  static double _bannerScale(double t) =>
      0.7 + 0.3 * Curves.elasticOut.transform((t / 0.35).clamp(0.0, 1.0));
}

class _Banner extends StatelessWidget {
  const _Banner({required this.theme});

  final ThermosTheme theme;

  @override
  Widget build(BuildContext context) {
    // Astronot gibi koyu temalarda label açık renk; beyaz zeminde görünmez
    // olurdu. Okunaklı değilse (kontrast < 4.5) koyu mürekkep kullanılır.
    const bg = Color(0xEBFFFFFF);
    final ink = _contrast(theme.label, Colors.white) >= 4.5
        ? theme.label
        : const Color(0xFF0B1F3A);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.edge, width: 2),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8)],
        ),
        child: Text(
          CelebrationOverlay.message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: ink, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

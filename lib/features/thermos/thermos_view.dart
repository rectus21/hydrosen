import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'celebration_painter.dart';
import 'celebrations/celebration_registry.dart';
import 'slosh_model.dart';
import 'thermos_painter.dart';
import 'thermos_theme.dart';
import 'wolf_artwork.dart';

/// Animasyonlu termos: su seviyesi yumuşakça yükselir, yüzey hafifçe dalgalanır.
/// Sensör kullanılmaz; su olaylarla çalkalanır ([SloshModel]):
/// - su eklenince (miktar büyüdükçe daha güçlü), silinince (daha hafif),
/// - termosa dokununca sallanır; yatay sürükleyince su o yöne eğilir,
///   bırakınca sönümlenerek durulur,
/// - hedef kutlaması başlayınca ([celebrations] artınca).
/// Cihazda "animasyonları azalt" açıksa su yine hareket eder (yoksa web'de
/// tarayıcı/işletim sistemi bu tercihi bildirdiğinde hiçbir tepki görünmezdi)
/// ama çok daha hafif ([_reducedGain]); sürekli yüzey titreşimi kapanır ve
/// seviye anında güncellenir.
class ThermosView extends StatefulWidget {
  const ThermosView({
    super.key,
    required this.progress,
    required this.goalMl,
    this.totalMl,
    this.celebrations = 0,
    this.shape = ThermosShape.chubby,
    this.theme = ThermosTheme.classic,
    this.happy = false,
    this.celebrationT,
    this.celebrationLoop,
    this.animatedCelebrations = false,
  });

  /// Döngü evresinde birikimli tur (tam kısım tur, kesir evre); yoksa null.
  /// CelebrationOverlay.loopProgress ile paylaşılır; kapak pozunu sürer.
  final ValueListenable<double?>? celebrationLoop;

  /// "Hareketli kutlamalar": açıksa sistem "azalt" dese de kapak pozu uygulanır.
  final bool animatedCelebrations;

  final double progress;
  final int goalMl;

  /// Bugünün toplamı (ml). Değişimi çalkalanmanın gücünü belirler; verilmezse
  /// [progress] değişiminden tahmin edilir. Yalnız hedef değişirse çalkalanmaz.
  final int? totalMl;

  /// Kutlama sayacı; her artışında su bir kez coşkuyla çalkalanır.
  final int celebrations;
  final ThermosShape shape;
  final ThermosTheme theme;

  /// Hedefe ulaşıldı: kapaktaki karakter mutlu ifadeye geçer.
  final bool happy;

  /// Kutlama ilerlemesi (0..1; kutlama yoksa null). İmza animasyonunun
  /// kapak hareketini sürer; CelebrationOverlay.progress ile paylaşılır.
  final ValueListenable<double?>? celebrationT;

  @override
  State<ThermosView> createState() => _ThermosViewState();
}

class _ThermosViewState extends State<ThermosView>
    with SingleTickerProviderStateMixin {
  /// "Animasyonları azalt" açıkken çalkalanma gücünün çarpanı.
  static const _reducedGain = 0.35;

  static final _noCelebration = ValueNotifier<double?>(null);

  late final Ticker _ticker = createTicker(_tick);
  final _slosh = SloshModel();
  Duration _last = Duration.zero;
  double _time = 0;
  late double _shown = widget.progress;
  bool _reduceMotion = false;

  /// Çalkalanma yönü her itkide değişir (rastgelelik yok, deterministik).
  double _side = 1;
  double _dragDx = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion) {
      _shown = widget.progress;
      // Sürekli titreşim yok: ticker yalnız su hareket ederken çalışır.
      if (_slosh.isAtRest) _ticker.stop();
    } else {
      _wake();
    }
  }

  void _wake() {
    if (_ticker.isActive) return;
    _last = Duration.zero;
    _ticker.start();
  }

  @override
  void didUpdateWidget(ThermosView old) {
    super.didUpdateWidget(old);
    if (_reduceMotion) _shown = widget.progress;
    final now = widget.totalMl, before = old.totalMl;
    final deltaMl = now != null && before != null
        ? now - before
        : ((widget.progress - old.progress) * widget.goalMl).round();
    if (deltaMl > 0) {
      // Eklenen miktar büyüdükçe daha güçlü (250 ml ≈ 1, 1 L ≈ 2).
      final s = math.sqrt(deltaMl / 250).clamp(0.5, 2.2);
      _push(tilt: 0.55 * s, wave: -45 * s);
    } else if (deltaMl < 0) {
      _push(tilt: 0.35, wave: 22);
    }
    if (widget.celebrations > old.celebrations) {
      _push(tilt: 0.9, wave: -80);
    }
  }

  /// Çalkalanma itkisi; yön sırayla değişir.
  void _push({required double tilt, required double wave}) {
    final g = _reduceMotion ? _reducedGain : 1.0;
    _side = -_side;
    _slosh.impulse(tiltVelocity: _side * tilt * g, waveVelocity: wave * g);
    _wake();
  }

  void _onTap() => _push(tilt: 0.8, wave: 30);

  void _onDragStart(DragStartDetails _) {
    _dragDx = 0;
    _wake();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _dragDx += d.delta.dx;
    final width = math.max(1.0, context.size?.width ?? 300);
    final g = _reduceMotion ? _reducedGain : 1.0;
    _slosh.hold(_dragDx / width * 1.2 * g);
  }

  void _onDragEnd(DragEndDetails d) {
    final width = math.max(1.0, context.size?.width ?? 300);
    final g = _reduceMotion ? _reducedGain : 1.0;
    _slosh.release(
      flingVelocity:
          (d.velocity.pixelsPerSecond.dx / width * 0.8).clamp(-3.0, 3.0) * g,
    );
  }

  void _onDragCancel() => _slosh.release();

  void _tick(Duration elapsed) {
    final dt = math.min(0.05, (elapsed - _last).inMicroseconds / 1e6);
    _last = elapsed;
    setState(() {
      if (_reduceMotion) {
        _shown = widget.progress; // sürekli yüzey titreşimi yok
      } else {
        _time += dt;
        _shown += (widget.progress - _shown) * math.min(1, dt * 3);
      }
      _slosh.step(dt); // durgunken hiçbir şey yapmaz
    });
    if (_reduceMotion && _slosh.isAtRest) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: designRect.width / designRect.height,
      child: GestureDetector(
        excludeFromSemantics: true,
        onTap: _onTap,
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onHorizontalDragCancel: _onDragCancel,
        child: ListenableBuilder(
          listenable: Listenable.merge([
            widget.celebrationT ?? _noCelebration,
            widget.celebrationLoop ?? _noCelebration,
          ]),
          builder: (context, _) {
            final ct = (widget.celebrationT ?? _noCelebration).value;
            final lp = (widget.celebrationLoop ?? _noCelebration).value;
            final poseOff = _reduceMotion && !widget.animatedCelebrations;
            CelebrationPainter? posePainter;
            if (!poseOff) {
              if (ct != null) {
                posePainter = CelebrationPainter(
                  theme: widget.theme,
                  shape: widget.shape,
                  t: ct,
                  level: _shown,
                );
              } else if (lp != null) {
                posePainter = CelebrationPainter.looping(
                  theme: widget.theme,
                  shape: widget.shape,
                  loop: lp,
                  loopCount: lp.floor(),
                  level: _shown,
                );
              }
            }
            // Limon: limonata rengi ve duran/hareketli şemsiye durumu.
            var lemonade = 0.0, sway = 0.0;
            var umbrella = true;
            if (widget.theme.id == 'limon') {
              double sp(double t, double a, double b) =>
                  ((t - a) / (b - a)).clamp(0.0, 1.0);
              if (poseOff) {
                lemonade = (ct != null || lp != null || widget.happy) ? 1 : 0;
              } else if (ct != null) {
                lemonade =
                    sp(ct, 0, 0.3) *
                    (widget.happy ? 1 : 1 - sp(ct, 0.9, 1));
                umbrella = !(ct > 0.35 && ct < 0.84);
              } else if (lp != null || widget.happy) {
                lemonade = 1;
                if (lp != null) sway = 0.07 * math.sin(lp * 2 * math.pi);
              }
            }
            return CustomPaint(
              painter: ThermosPainter(
                lemonade: lemonade,
                umbrellaOn: umbrella,
                umbrellaSway: sway,
                shape: widget.shape,
                theme: widget.theme,
                level: _shown,
                goalMl: widget.goalMl,
                time: _time,
                slosh: _slosh.agitation * 4,
                tilt: _slosh.tilt,
                wave: _slosh.wave,
                happy: widget.happy,
                headLift: poseOff
                    ? 1
                    : WolfArtwork.howlLift(intro: ct, loop: lp),
                labelStyle: Theme.of(context).textTheme.labelSmall,
                capPose: posePainter == null
                    ? CapPose.identity
                    : resolveCapPose(posePainter),
              ),
            );
          },
        ),
      ),
    );
  }
}

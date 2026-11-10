import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'slosh_model.dart';
import 'thermos_painter.dart';
import 'thermos_theme.dart';

/// Animasyonlu termos: su seviyesi yumuşakça yükselir, yüzey hafifçe dalgalanır.
/// Sensör kullanılmaz; su olaylarla çalkalanır ([SloshModel]):
/// - su eklenince (miktar büyüdükçe daha güçlü), silinince (daha hafif),
/// - termosa dokununca sallanır; yatay sürükleyince su o yöne eğilir,
///   bırakınca sönümlenerek durulur,
/// - hedef kutlaması başlayınca ([celebrations] artınca).
/// Cihazda "animasyonları azalt" açıksa durağan çizilir, çalkalanma olmaz.
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
  });

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

  @override
  State<ThermosView> createState() => _ThermosViewState();
}

class _ThermosViewState extends State<ThermosView>
    with SingleTickerProviderStateMixin {
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
      _ticker.stop();
      _shown = widget.progress;
      _slosh.reset();
    } else if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(ThermosView old) {
    super.didUpdateWidget(old);
    if (_reduceMotion) {
      _shown = widget.progress;
      return;
    }
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
    if (_reduceMotion) return;
    _side = -_side;
    _slosh.impulse(tiltVelocity: _side * tilt, waveVelocity: wave);
  }

  void _onTap() => _push(tilt: 0.8, wave: 30);

  void _onDragStart(DragStartDetails _) {
    if (_reduceMotion) return;
    _dragDx = 0;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_reduceMotion) return;
    _dragDx += d.delta.dx;
    final width = math.max(1.0, context.size?.width ?? 300);
    _slosh.hold(_dragDx / width * 1.2);
  }

  void _onDragEnd(DragEndDetails d) {
    if (_reduceMotion) return;
    final width = math.max(1.0, context.size?.width ?? 300);
    _slosh.release(
      flingVelocity: (d.velocity.pixelsPerSecond.dx / width * 0.8).clamp(
        -3.0,
        3.0,
      ),
    );
  }

  void _onDragCancel() => _slosh.release();

  void _tick(Duration elapsed) {
    final dt = math.min(0.05, (elapsed - _last).inMicroseconds / 1e6);
    _last = elapsed;
    setState(() {
      _time += dt;
      _shown += (widget.progress - _shown) * math.min(1, dt * 3);
      _slosh.step(dt); // durgunken hiçbir şey yapmaz
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = _reduceMotion;
    return AspectRatio(
      aspectRatio: designRect.width / designRect.height,
      child: GestureDetector(
        excludeFromSemantics: true,
        onTap: still ? null : _onTap,
        onHorizontalDragStart: still ? null : _onDragStart,
        onHorizontalDragUpdate: still ? null : _onDragUpdate,
        onHorizontalDragEnd: still ? null : _onDragEnd,
        onHorizontalDragCancel: still ? null : _onDragCancel,
        child: CustomPaint(
          painter: ThermosPainter(
            shape: widget.shape,
            theme: widget.theme,
            level: _shown,
            goalMl: widget.goalMl,
            time: _time,
            slosh: still ? 0 : _slosh.agitation * 4,
            tilt: still ? 0 : _slosh.tilt,
            wave: still ? 0 : _slosh.wave,
            happy: widget.happy,
          ),
        ),
      ),
    );
  }
}

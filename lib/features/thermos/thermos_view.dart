import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'thermos_painter.dart';
import 'thermos_theme.dart';

/// Animasyonlu termos: su seviyesi yumuşakça yükselir, yüzey dalgalanır,
/// su eklenince çalkalanır. Cihazda "animasyonları azalt" açıksa durağan çizilir.
class ThermosView extends StatefulWidget {
  const ThermosView({
    super.key,
    required this.progress,
    required this.goalMl,
    this.shape = ThermosShape.chubby,
    this.theme = ThermosTheme.classic,
  });

  final double progress;
  final int goalMl;
  final ThermosShape shape;
  final ThermosTheme theme;

  @override
  State<ThermosView> createState() => _ThermosViewState();
}

class _ThermosViewState extends State<ThermosView>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  Duration _last = Duration.zero;
  double _time = 0;
  late double _shown = widget.progress;
  double _slosh = 0;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion) {
      _ticker.stop();
      _shown = widget.progress;
    } else if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(ThermosView old) {
    super.didUpdateWidget(old);
    if (widget.progress != old.progress) {
      if (_reduceMotion) {
        _shown = widget.progress;
      } else {
        _slosh += 6;
      }
    }
  }

  void _tick(Duration elapsed) {
    final dt = math.min(0.05, (elapsed - _last).inMicroseconds / 1e6);
    _last = elapsed;
    setState(() {
      _time += dt;
      _shown += (widget.progress - _shown) * math.min(1, dt * 3);
      _slosh *= math.exp(-dt * 2);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.theme.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: AspectRatio(
          aspectRatio: designRect.width / designRect.height,
          child: CustomPaint(
            painter: ThermosPainter(
              shape: widget.shape,
              theme: widget.theme,
              level: _shown,
              goalMl: widget.goalMl,
              time: _time,
              slosh: _slosh,
            ),
          ),
        ),
      ),
    );
  }
}

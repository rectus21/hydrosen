import 'package:flutter/material.dart';

import 'celebration_painter.dart';
import 'thermos_theme.dart';

/// Termosun üstüne yerleşen kutlama katmanı. [trigger] her değiştiğinde bir kez
/// oynar ([duration] sonra kendiliğinden kaybolur); ilk değerinde oynamaz.
/// Dokunmaları engellemez. "Animasyonları azalt" açıksa parçacık çizilmez,
/// yalnızca kısa bir tebrik yazısı görünür.
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.trigger,
    required this.theme,
    required this.shape,
    this.duration = const Duration(milliseconds: 2600),
  });

  final int trigger;
  final ThermosTheme theme;
  final ThermosShape shape;
  final Duration duration;

  static const message = 'Tebrikler! Günlük hedefe ulaştın.';

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  // preserve: "animasyonları azalt" süreyi kısaltmasın; yazı yine ~2,6 sn kalır.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
    animationBehavior: AnimationBehavior.preserve,
  );

  @override
  void didUpdateWidget(CelebrationOverlay old) {
    super.didUpdateWidget(old);
    if (widget.duration != old.duration) _c.duration = widget.duration;
    if (widget.trigger != old.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          if (!_c.isAnimating) return const SizedBox.shrink();
          final t = _c.value;
          return Stack(
            fit: StackFit.expand,
            children: [
              if (!reduceMotion)
                CustomPaint(
                  painter: CelebrationPainter(
                    theme: widget.theme,
                    shape: widget.shape,
                    t: t,
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
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.edge, width: 2),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8)],
        ),
        child: Text(
          CelebrationOverlay.message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: theme.label, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

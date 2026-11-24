import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/badges.dart';
import '../home/water_controller.dart';
import 'badge_medallion.dart';

/// "Yeni rozet" kutlamasının tek karesi: madalyon belirir (yaylanarak),
/// konfeti saçılır, yazı gelir. [progress] 0..1 arası; tamamen çizimdir,
/// sahne/animasyon bilgisi dışarıdan verilir (render testi de kullanır).
class NewBadgeCelebration extends StatelessWidget {
  const NewBadgeCelebration({
    super.key,
    required this.badge,
    required this.progress,
  });

  final BadgeDef badge;
  final double progress;

  static String messageFor(BadgeDef b) => 'Yeni rozet: ${b.popupName}!';

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    // 0..0.3 yaylanarak belir; 0.88'den sonra sön.
    final pop = Curves.elasticOut.transform((p / 0.32).clamp(0.0, 1.0));
    final fadeOut = 1 - ((p - 0.86) / 0.14).clamp(0.0, 1.0);
    final fadeIn = (p / 0.1).clamp(0.0, 1.0);
    final textIn = ((p - 0.22) / 0.14).clamp(0.0, 1.0);
    final opacity = fadeIn * fadeOut;
    final shine = ((p - 0.3) / 0.45).clamp(0.0, 1.0);
    // Material: tema yazı tipi ve metin stili (Scaffold'un dışında çiziliyor).
    return Material(
      type: MaterialType.transparency,
      child: Semantics(
        liveRegion: true,
        label: messageFor(badge),
        child: Opacity(
          opacity: opacity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.58 * opacity),
                ),
              ),
              Positioned.fill(child: CustomPaint(painter: _ConfettiPainter(p))),
              Align(
                alignment: const Alignment(0, -0.42),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.2 + 0.8 * pop,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Yumuşak altın hale (kenarsız radyal geçiş).
                          SizedBox(
                            width: 360,
                            height: 360,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFFFE08A)
                                        .withValues(alpha: 0.9),
                                    const Color(0xFFFFE08A)
                                        .withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          BadgeMedallion(badge: badge, size: 168, shine: shine),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Opacity(
                      opacity: textIn,
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - textIn)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xE610223A),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            messageFor(badge),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.p);

  final double p;

  static const _colors = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD166),
    Color(0xFF06D6A0),
    Color(0xFF4CC9F0),
    Color(0xFFB388FF),
    Color(0xFFFF9A3C),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(11);
    // Patlama noktası: madalyonun olduğu yer (ekranın ortası, biraz yukarı).
    final origin = Offset(size.width / 2, size.height * 0.29 - 70);
    final t = ((p - 0.05) / 0.8).clamp(0.0, 1.0);
    if (t <= 0) return;
    final ease = 1 - math.pow(1 - t, 2.2).toDouble();
    final fade = 1 - ((t - 0.7) / 0.3).clamp(0.0, 1.0);
    for (var i = 0; i < 80; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final speed = (0.35 + rnd.nextDouble() * 0.65) * size.shortestSide * 0.62;
      final w = 7 + rnd.nextDouble() * 8;
      final color = _colors[i % _colors.length];
      final spin = rnd.nextDouble() * 6 + t * (3 + rnd.nextDouble() * 8);
      final pos =
          origin +
          Offset(math.cos(a), math.sin(a) * 0.8) * speed * ease +
          Offset(0, 120 * t * t * (0.6 + rnd.nextDouble() * 0.6));
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(spin);
      final paint = Paint()..color = color.withValues(alpha: fade);
      if (i % 5 == 0) {
        canvas.drawCircle(Offset.zero, w * 0.45, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: w, height: w * 0.55),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.p != p;
}

/// Kazanılmış ama kutlanmamış rozetleri sırayla, dokunuşu engellemeden gösterir.
/// Hedef kutlaması bitsin diye hedef/seri rozetleri kısa bir gecikmeyle açılır.
class BadgePopupHost extends StatefulWidget {
  const BadgePopupHost({super.key, required this.controller});

  final WaterController controller;

  @override
  State<BadgePopupHost> createState() => _BadgePopupHostState();
}

class _BadgePopupHostState extends State<BadgePopupHost>
    with SingleTickerProviderStateMixin {
  static const _life = Duration(milliseconds: 3600);

  // "Animasyonları azalt" açıkken de kısa kutlama görünür kalsın (yoksa
  // rozet hiç görülmeden kutlanmış sayılırdı).
  late final AnimationController _anim = AnimationController(
    vsync: this,
    animationBehavior: AnimationBehavior.preserve,
  );
  BadgeDef? _current;
  Duration _delay = Duration.zero;

  @override
  void initState() {
    super.initState();
    _anim.addStatusListener((s) {
      if (s == AnimationStatus.completed) _finish();
    });
    widget.controller.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_check);
    _anim.dispose();
    super.dispose();
  }

  void _check() {
    if (!mounted || _current != null || !widget.controller.loaded) return;
    final pending = widget.controller.pendingBadges;
    if (pending.isEmpty) return;
    // Önce en değerli rozet; diğerleri sırayla.
    final badge = pending.reduce(
      (a, b) => Badges.rank(a) >= Badges.rank(b) ? a : b,
    );
    // İlk kayıt anında hemen; hedefle gelenler kutlama bitince.
    _delay = badge.id == Badges.firstEntryId
        ? const Duration(milliseconds: 300)
        : const Duration(milliseconds: 2400);
    final total = _delay + _life;
    setState(() => _current = badge);
    _anim
      ..duration = total
      ..forward(from: 0);
  }

  void _finish() {
    final b = _current;
    if (b == null) return;
    setState(() => _current = null);
    widget.controller.markBadgeCelebrated(b.id).then((_) => _check());
  }

  @override
  Widget build(BuildContext context) {
    final badge = _current;
    if (badge == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final total = (_delay + _life).inMilliseconds;
          final ms = _anim.value * total - _delay.inMilliseconds;
          if (ms < 0) return const SizedBox.shrink();
          return NewBadgeCelebration(
            key: const ValueKey('new-badge-popup'),
            badge: badge,
            progress: ms / _life.inMilliseconds,
          );
        },
      ),
    );
  }
}

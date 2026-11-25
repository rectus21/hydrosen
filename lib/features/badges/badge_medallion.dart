import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/badges.dart';

/// Rozet sanatı: `assets/badges/<id>.png` varsa o kullanılır, yoksa kodla
/// çizilen madalyon. Yeni PNG eklemek için dosyayı bu klasöre koymak yeter
/// (pubspec zaten `assets/badges/` klasörünü kapsar).
abstract final class BadgeArt {
  static Set<String> _png = {};

  /// Uygulama açılışında bir kez çağrılır; asset listesinden PNG'leri bulur.
  static Future<void> load([AssetBundle? bundle]) async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(
        bundle ?? rootBundle,
      );
      _png = {
        for (final a in manifest.listAssets())
          if (RegExp(r'^assets/badges/[^/]+\.png$').hasMatch(a))
            a.substring('assets/badges/'.length, a.length - '.png'.length),
      };
    } catch (_) {
      _png = {};
    }
  }

  static bool hasPng(String id) => _png.isEmpty || _png.contains(id);

  /// Testler için.
  static void debugSetPng(Set<String> ids) => _png = ids;

  static String assetOf(String id) => 'assets/badges/$id.png';
}

class _Palette {
  const _Palette(this.light, this.mid, this.dark, this.ribbon, this.ribbonDark);
  final Color light;
  final Color mid;
  final Color dark;
  final Color ribbon;
  final Color ribbonDark;
}

const _bronze = _Palette(
  Color(0xFFF2C597),
  Color(0xFFCD7F3A),
  Color(0xFF8A4A1B),
  Color(0xFFD9503F),
  Color(0xFFA33326),
);
const _silver = _Palette(
  Color(0xFFFAFBFD),
  Color(0xFFBCC5D2),
  Color(0xFF7B8798),
  Color(0xFFD9503F),
  Color(0xFFA33326),
);
const _gold = _Palette(
  Color(0xFFFFEBA3),
  Color(0xFFF3B72F),
  Color(0xFFB5790C),
  Color(0xFFD9503F),
  Color(0xFFA33326),
);
const _diamond = _Palette(
  Color(0xFFE6FAFF),
  Color(0xFF5DCBF6),
  Color(0xFF1E78C2),
  Color(0xFF2F63C8),
  Color(0xFF1E428F),
);
const _milestone = _Palette(
  Color(0xFFC4F5E6),
  Color(0xFF3FC0A0),
  Color(0xFF1B7A66),
  Color(0xFFEF8F3A),
  Color(0xFFB8641A),
);
const _locked = _Palette(
  Color(0xFFE9ECF0),
  Color(0xFFBBC1CA),
  Color(0xFF8D95A1),
  Color(0xFFA6ADB8),
  Color(0xFF8A919D),
);

_Palette _paletteFor(BadgeTier tier, bool locked) {
  if (locked) return _locked;
  switch (tier) {
    case BadgeTier.bronze:
      return _bronze;
    case BadgeTier.silver:
      return _silver;
    case BadgeTier.gold:
      return _gold;
    case BadgeTier.diamond:
      return _diamond;
    case BadgeTier.milestone:
      return _milestone;
  }
}

/// Kurdeleli yuvarlak madalyon. Kare alanın üst kısmına çizilir;
/// kurdele tuvalin altına uzanır (yükseklik = genişlik * [aspect]).
class BadgeMedallion extends StatelessWidget {
  const BadgeMedallion({
    super.key,
    required this.badge,
    this.size = 84,
    this.locked = false,
    this.shine = 0.3,
  });

  /// Yükseklik / genişlik.
  static const aspect = 1.2;

  final BadgeDef badge;
  final double size;
  final bool locked;

  /// Parıltı şeridinin konumu (0..1, çapraz); popup bunu kaydırır.
  final double shine;

  @override
  Widget build(BuildContext context) {
    final pal = _paletteFor(badge.tier, locked);
    // Rozet resimleri kare; resim yoksa kodla çizilen madalyon (kurdeleli,
    // daha uzun) yedek olarak kullanılır.
    var height = size;
    Widget art;
    if (BadgeArt.hasPng(badge.id)) {
      art = Image.asset(
        BadgeArt.assetOf(badge.id),
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => _painted(pal),
      );
      if (locked) {
        art = ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.2126, 0.7152, 0.0722, 0, 30, //
            0.2126, 0.7152, 0.0722, 0, 30,
            0.2126, 0.7152, 0.0722, 0, 30,
            0, 0, 0, 0.55, 0,
          ]),
          child: art,
        );
      }
    } else {
      height = size * aspect;
      art = _painted(pal);
    }
    return SizedBox(
      width: size,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: art),
          if (locked)
            Positioned(
              right: size * 0.02,
              top: size * 0.62,
              child: Container(
                width: size * 0.30,
                height: size * 0.30,
                decoration: BoxDecoration(
                  color: const Color(0xFF59616E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: size * 0.025),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: size * 0.17,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _painted(_Palette pal) {
    final r = size * 0.40;
    final inner = r * 1.5;
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _MedallionPainter(pal, shine: locked ? null : shine),
          ),
        ),
        Positioned(
          left: (size - inner) / 2,
          top: size * 0.5 - inner / 2,
          width: inner,
          height: inner,
          child: Center(child: _center(pal, inner)),
        ),
      ],
    );
  }

  Widget _center(_Palette pal, double box) {
    final ink = locked ? const Color(0xFF6E7683) : pal.dark;
    final glow = Shadow(
      color: Colors.white.withValues(alpha: locked ? 0.4 : 0.6),
      offset: const Offset(0, 1.2),
    );
    final days = badge.days;
    if (days == null) {
      final icon = badge.id == Badges.firstEntryId
          ? Icons.water_drop_rounded
          : Icons.emoji_events_rounded;
      return Icon(icon, size: box * 0.62, color: ink, shadows: [glow]);
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$days',
            style: TextStyle(
              fontSize: box * (days >= 100 ? 0.5 : 0.6),
              height: 1.0,
              fontWeight: FontWeight.w900,
              color: ink,
              shadows: [glow],
            ),
          ),
          Text(
            'GÜN',
            style: TextStyle(
              fontSize: box * 0.2,
              height: 1.0,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
              color: ink,
              shadows: [glow],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedallionPainter extends CustomPainter {
  _MedallionPainter(this.pal, {required this.shine});

  final _Palette pal;

  /// null: parıltı yok (kilitli).
  final double? shine;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s * 0.5);
    final r = s * 0.40;

    // Kurdele kuyrukları (madalyonun arkasında).
    void tail(double dx, double sign, Color a, Color b) {
      final top = c.dy + r * 0.45;
      final bottom = s * 1.17;
      final path = Path()
        ..moveTo(c.dx + dx - sign * s * 0.02, top)
        ..lineTo(c.dx + dx + sign * s * 0.20, top + s * 0.02)
        ..lineTo(c.dx + dx + sign * s * 0.20, bottom)
        ..lineTo(c.dx + dx + sign * s * 0.095, bottom - s * 0.075)
        ..lineTo(c.dx + dx - sign * s * 0.02, bottom)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            colors: [a, b],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(path.getBounds()),
      );
    }

    tail(-s * 0.19, -1, pal.ribbon, pal.ribbonDark);
    tail(s * 0.19, 1, pal.ribbon, pal.ribbonDark);

    // Yumuşak gölge.
    canvas.drawCircle(
      c.translate(0, s * 0.03),
      r * 1.02,
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.025),
    );

    // Tırtıklı dış kenar.
    const bumps = 20;
    final rim = Path();
    for (var i = 0; i < bumps; i++) {
      final a = i / bumps * math.pi * 2;
      rim.addOval(
        Rect.fromCircle(
          center: c + Offset(math.cos(a), math.sin(a)) * (r * 0.97),
          radius: r * 0.085,
        ),
      );
    }
    final rimPaint = Paint()..color = pal.dark;
    canvas.drawPath(rim, rimPaint);

    // Dış halka.
    final outer = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = LinearGradient(
          colors: [pal.light, pal.mid, pal.dark],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(outer),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.012
        ..color = pal.dark.withValues(alpha: 0.7),
    );

    // İç halka (ters eğimli: kabartma hissi).
    final ringR = r * 0.84;
    canvas.drawCircle(
      c,
      ringR,
      Paint()
        ..shader = LinearGradient(
          colors: [pal.dark, pal.light],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: c, radius: ringR)),
    );
    final disc = r * 0.78;
    canvas.drawCircle(
      c,
      disc,
      Paint()
        ..shader = RadialGradient(
          colors: [pal.light, pal.mid],
          center: const Alignment(-0.3, -0.4),
          radius: 1.0,
        ).createShader(Rect.fromCircle(center: c, radius: disc)),
    );

    final sh = shine;
    if (sh == null) return;

    // Parıltı: madalyona kırpılmış çapraz yumuşak şerit + küçük yansıma.
    canvas.save();
    canvas.clipPath(Path()..addOval(outer));
    final t = (sh - 0.5) * 2.4; // şeridin yatay konumu (yarıçap birimi)
    canvas.translate(c.dx + t * r, c.dy);
    canvas.rotate(-0.6);
    final bandRect = Rect.fromCenter(
      center: Offset.zero,
      width: r * 0.55,
      height: r * 3,
    );
    canvas.drawRect(
      bandRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.42),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(bandRect),
    );
    canvas.restore();
    // Üst sol küçük cam yansıması.
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(-r * 0.42, -r * 0.55),
        width: r * 0.5,
        height: r * 0.2,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(_MedallionPainter old) =>
      old.pal != pal || old.shine != shine;
}

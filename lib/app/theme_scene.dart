import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../features/thermos/art.dart';
import '../features/thermos/scene_geometry.dart';
import '../features/thermos/thermos_painter.dart' show designRect;
import '../features/thermos/thermos_theme.dart';
import '../features/thermos/wolf_artwork.dart';
import '../features/thermos/illustrated_artwork.dart';

/// Temanın arka plan sahnesini tüm ekrana yayar. Sahne termosla aynı ölçekte
/// çizilir (termos sahnede durur, kutlama çizimleri aynı yere oturur); çizimin
/// ulaşmadığı yerler doğal biçimde uzatılır: dört yanda çizimin kendi kenar
/// satırı/sütunu yumuşatılarak sürülür (çizim kopyalanmaz).
class ThemeScene extends StatefulWidget {
  const ThemeScene({
    super.key,
    required this.theme,
    required this.child,
    this.thermosKey,
    this.scroll,
  });

  final ThermosTheme theme;
  final Widget child;

  /// Termosun bulunduğu widget; yoksa sahne sabit bir konuma oturur.
  final GlobalKey? thermosKey;

  /// Sahne içerikle kayıyorsa kaydırma denetleyicisi.
  final Listenable? scroll;

  @override
  State<ThemeScene> createState() => _ThemeSceneState();
}

class _ThemeSceneState extends State<ThemeScene>
    with SingleTickerProviderStateMixin {
  final _sceneKey = GlobalKey();
  late final _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );

  void _syncAmbient() {
    final active =
        const {
          'kurt',
          'boga',
          'bulut',
          'kaplan',
          'panda',
          'baykus',
          'tilki',
          'civciv',
          'tavsan',
          'penguen',
          'ejderha',
          'sincap',
          'aslan',
          'ayi',
          'kirpi',
          'astronot',
          'kardanadam',
          'kopek',
        }.contains(widget.theme.id) &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (active && !_ambient.isAnimating) {
      _ambient.repeat();
    } else if (!active) {
      _ambient.stop();
      _ambient.value = 0;
    }
  }

  late Listenable _repaint = _buildRepaint();

  Listenable _buildRepaint() => widget.scroll == null
      ? _ambient
      : Listenable.merge([_ambient, widget.scroll!]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAmbient();
  }

  @override
  void didUpdateWidget(ThemeScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scroll != widget.scroll) _repaint = _buildRepaint();
    _syncAmbient();
  }

  @override
  void dispose() {
    if (SceneGeometry.sceneKey == _sceneKey) SceneGeometry.sceneKey = null;
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.thermosKey != null) SceneGeometry.sceneKey = _sceneKey;
    return SceneGeometryScope(
      sceneKey: _sceneKey,
      child: CustomPaint(
        key: _sceneKey,
        painter: _ScenePainter(
          theme: widget.theme,
          sceneKey: _sceneKey,
          thermosKey: widget.thermosKey,
          ambient: _ambient,
          repaint: _repaint,
        ),
        child: widget.child,
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.theme,
    required this.sceneKey,
    required this.thermosKey,
    required this.ambient,
    super.repaint,
  });

  final ThermosTheme theme;
  final Animation<double> ambient;
  final GlobalKey sceneKey;
  final GlobalKey? thermosKey;

  /// Tema başına kaydedilmiş sahne;
  /// yalnız tema değişince yeniden kaydedilir.
  static final _pictures = <String, ui.Picture>{};

  static const _far = 3000.0;

  /// Çizimin alt/üst kenarındaki yarı saydam kenar yumuşatmaları (AA) uzatma
  /// ile birleşirken çizgi bırakmasın diye çizim kenardan bu kadar içeriden
  /// kesilir; uzatma o noktadaki tam renkten başlar.
  static const _inset = 2.0;

  /// Çizimin yan kenarında, uzatmaya geçişi yumuşatan çözülme genişliği.
  static const _fade = 18.0;

  /// Üst/alt uzatmanın çizimin içine taşan, yan uzatmayla harmanlanan kısmı.
  static const _blend = 120.0;

  /// Yan uzatmada keskin (az bulanık) katmanın kenardan erişimi.
  static const _nearReach = 140.0;

  static ui.Picture _picture(ThermosTheme t) {
    final hit = _pictures[t.id];
    if (hit != null) return hit;
    if (_pictures.length >= 8) {
      for (final p in _pictures.values) {
        p.dispose();
      }
      _pictures.clear();
    }
    return _pictures[t.id] = _record(t);
  }

  static ui.Picture _record(ThermosTheme t) {
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    final xl = designRect.left + _inset;
    final xr = designRect.right - _inset;
    final yt = designRect.top + _inset;
    final yb = designRect.bottom - _inset;

    // [src] dikdörtgenindeki çizimi [dst]'ye doğrusal olarak gererek çizer.
    void stretch(Rect src, Rect dst) {
      c.save();
      c.translate(dst.left, dst.top);
      c.scale(dst.width / src.width, dst.height / src.height);
      c.translate(-src.left, -src.top);
      c.clipRect(src, doAntiAlias: false);
      t.background(Art(c));
      c.restore();
    }

    // [r] içinde [a]'dan [b]'ye giden saydamlık maskesi (dstIn).
    Paint fadeMask(
      Offset a,
      Offset b,
      List<Color> colors,
      List<double> stops,
    ) => Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = ui.Gradient.linear(a, b, colors, stops);
    const clear = Color(0x00000000);
    const solid = Color(0xFF000000);

    // Yanlar: çizimin kenar sütununu dışa doğru uzat, dikeyde bulanıklaştır
    // (kenarda kesilen nesneler çizgi bırakmasın). Çizim kopyalanmaz. Kenara
    // yakın kısım az, uzak kısım çok bulanık; üst/alt uçlar köşe renginden
    // yumuşakça başlar.
    void side({required bool left}) {
      final e = left ? xl : xr;
      final x0 = left ? e - _far : e - _fade;
      final x1 = left ? e + _fade : e + _far;
      final area = Rect.fromLTRB(x0, yt, x1, yb);
      final src = left
          ? Rect.fromLTRB(e, yt, e + 1, yb)
          : Rect.fromLTRB(e - 1, yt, e, yb);
      final h = yb - yt;
      void layer(double sigma, {required bool near}) {
        c.saveLayer(area, Paint());
        c.saveLayer(
          area,
          Paint()
            ..imageFilter = ui.ImageFilter.blur(
              sigmaX: 0.01,
              sigmaY: sigma,
              tileMode: TileMode.clamp,
            ),
        );
        stretch(src, area);
        c.restore();
        c.drawRect(
          area,
          fadeMask(
            Offset(0, yt),
            Offset(0, yb),
            const [clear, solid, solid, clear],
            [0, _blend / h, 1 - _blend / h, 1],
          ),
        );
        if (near) {
          final a = e;
          final b = left ? e - _nearReach : e + _nearReach;
          c.drawRect(
            area,
            fadeMask(Offset(a, 0), Offset(b, 0), const [solid, clear], [0, 1]),
          );
        }
        c.restore();
      }

      c.save();
      c.clipRect(area);
      layer(64, near: false);
      layer(18, near: true);
      c.restore();
    }

    // Yukarı ve aşağı (köşeler dahil): çizimin en kenar satırını sonsuza uzat,
    // yatayda bulanıklaştır (yıldız, bulut gibi ayrıntılar çizgi bırakmasın).
    // Satırın iki ucu yanlara kenar pikseliyle sürülür; bulanıklık geçişi eritir.
    void extend({required bool top}) {
      final e = top ? yt : yb;
      final y0 = top ? e - _far : e - _blend;
      final y1 = top ? e + _blend : e + _far;
      final area = Rect.fromLTRB(xl - _far, y0, xr + _far, y1);
      c.save();
      c.clipRect(area);
      c.saveLayer(
        area,
        Paint()
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: 110,
            sigmaY: 0.01,
            tileMode: TileMode.clamp,
          ),
      );
      Rect row(double l, double r) =>
          top ? Rect.fromLTRB(l, e, r, e + 1) : Rect.fromLTRB(l, e - 1, r, e);
      stretch(row(xl, xr), Rect.fromLTRB(xl, y0, xr, y1));
      stretch(row(xl, xl + 1), Rect.fromLTRB(xl - _far, y0, xl, y1));
      stretch(row(xr - 1, xr), Rect.fromLTRB(xr, y0, xr + _far, y1));
      c.restore();
      c.restore();
    }

    extend(top: true);
    extend(top: false);
    side(left: true);
    side(left: false);

    // Çizimin kendisi; kenarları uzatmaya yumuşakça çözülür.
    final art = Rect.fromLTRB(xl, yt, xr, yb);
    c.saveLayer(art, Paint());
    c.save();
    c.clipRect(art, doAntiAlias: false);
    t.background(Art(c));
    c.restore();
    Paint mask(Offset a, Offset b, double f) => Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = ui.Gradient.linear(
        a,
        b,
        const [clear, solid, solid, clear],
        [0, _fade / f, 1 - _fade / f, 1],
      );
    c.drawRect(art, mask(Offset(xl, 0), Offset(xr, 0), xr - xl));
    c.drawRect(art, mask(Offset(0, yt), Offset(0, yb), yb - yt));
    c.restore();
    return rec.endRecording();
  }

  /// Termosun sahnedeki konumu (kaydırmayla birlikte).
  Rect _thermosRect(Size size) {
    try {
      final tb = thermosKey?.currentContext?.findRenderObject();
      final sb = sceneKey.currentContext?.findRenderObject();
      if (tb is RenderBox &&
          sb is RenderBox &&
          tb.attached &&
          sb.attached &&
          tb.hasSize &&
          sb.hasSize) {
        return tb.localToGlobal(Offset.zero, ancestor: sb) & tb.size;
      }
    } catch (_) {
      // Sekme geçişinde eski termos bağlamı kısa süreliğine pasif olabilir.
    }
    final w = math.min(
      math.max(1.0, size.width - 32),
      380 * designRect.width / designRect.height,
    );
    final h = w * designRect.height / designRect.width;
    return Rect.fromLTWH((size.width - w) / 2, 96, w, h);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final box = _thermosRect(size);
    final s = math.min(
      box.width / designRect.width,
      box.height / designRect.height,
    );
    final ox = box.center.dx - designRect.width * s / 2;
    final oy = box.center.dy - designRect.height * s / 2;
    final sceneImage = theme.id == 'kurt'
        ? WolfArtwork.current?.scene
        : IllustratedArtwork.byId[theme.id]?.scene;
    if (sceneImage != null) {
      // Sahneler farklı kaynak oranlarında çizildi. Sabit 1080x2340'a
      // esnetmek karakterleri ve dekoru yatayda eziyordu; oranı koruyarak
      // ekranı kapla ve üst merkez odağını sabit tut. Arka plan böylece
      // termos büyüdüğünde de bozulmaz veya onunla birlikte ölçeklenmez.
      final image = sceneImage;
      paintImage(
        canvas: canvas,
        rect: Offset.zero & size,
        image: image,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        filterQuality: FilterQuality.medium,
      );
      canvas.save();
      canvas.clipRect(Offset.zero & size);
      canvas.translate(ox, oy);
      canvas.scale(s);
      canvas.translate(-designRect.left, -designRect.top);
      if (theme.id == 'kurt') {
        _forestAtmosphere(canvas, ambient.value);
      } else {
        _dayAtmosphere(
          canvas,
          ambient.value,
          theme.id == 'bulut' || theme.id == 'penguen',
        );
      }
      canvas.restore();
      return;
    }
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(ox, oy);
    canvas.scale(s);
    canvas.translate(-designRect.left, -designRect.top);
    canvas.drawPicture(_picture(theme));
    canvas.restore();
  }

  void _dayAtmosphere(Canvas canvas, double phase, bool cloud) {
    final t = phase * 2 * math.pi;
    final paint = Paint()
      ..color = (cloud ? const Color(0xFFEDF9FF) : const Color(0xFFFFE7AA))
          .withValues(alpha: 0.18);
    // Slow wisps and sunlight stay on the side margins of the bottle.
    for (var i = 0; i < 5; i++) {
      final left = i.isEven;
      final center = Offset(
        (left ? 160.0 : 495.0) + math.sin(t + i * 1.3) * 12,
        155.0 + i * 57 + math.cos(t + i) * 4,
      );
      canvas.drawCircle(center, cloud ? 11 : 3, paint);
    }
  }

  /// Quiet layers stay outside the face and the bottle's center column.
  void _forestAtmosphere(Canvas canvas, double phase) {
    final time = phase * 2 * math.pi;
    const moon = Offset(197, 178);
    final haloRadius = 46 + 3 * math.sin(time);
    canvas.drawCircle(
      moon,
      haloRadius,
      Paint()
        ..shader = ui.Gradient.radial(moon, haloRadius, [
          const Color(0xFFDCD6FF)
              .withValues(alpha: 0.045 + 0.02 * math.sin(time)),
          const Color(0x00DCD6FF),
        ]),
    );

    const stars = [
      Offset(162, 62),
      Offset(218, 38),
      Offset(250, 120),
      Offset(440, 64),
      Offset(496, 102),
      Offset(525, 212),
      Offset(465, 264),
      Offset(150, 282),
      Offset(228, 234),
    ];
    for (var i = 0; i < stars.length; i++) {
      final shimmer = 0.5 + 0.5 * math.sin(time * (i % 3 + 1) + i * 1.7);
      final point = stars[i];
      final paint = Paint()
        ..color = const Color(0xFFECE7FF)
            .withValues(alpha: 0.18 + 0.48 * shimmer);
      canvas.drawCircle(point, 0.9 + shimmer * 0.65, paint);
      if (i % 3 == 0) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7;
        final r = 2.5 + shimmer;
        canvas.drawLine(point - Offset(r, 0), point + Offset(r, 0), paint);
        canvas.drawLine(point - Offset(0, r), point + Offset(0, r), paint);
      }
    }

    // Fireflies drift around the trees, never across the water counter.
    for (var i = 0; i < 8; i++) {
      final left = i.isEven;
      final x = (left ? 155.0 : 470.0) + (i % 4) * 13 + math.sin(time + i) * 9;
      final y = 350 + (i % 4) * 27.0 + math.cos(time * 2 + i) * 7;
      final point = Offset(x, y);
      final alpha = 0.3 + 0.25 * math.sin(time * 2 + i);
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..shader = ui.Gradient.radial(point, 6, [
            const Color(0xFFE2DBFF).withValues(alpha: alpha),
            const Color(0x00E2DBFF),
          ]),
      );
      canvas.drawCircle(
        point,
        1.2,
        Paint()..color = const Color(0xFFEFEAFF).withValues(alpha: alpha + 0.2),
      );
    }

    for (var i = 0; i < 2; i++) {
      final center = Offset(
        210 + i * 240 + math.sin(time + i * math.pi) * 28,
        443 + i * 18.0,
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(5, 0.4);
      canvas.drawCircle(
        Offset.zero,
        31,
        Paint()
          ..shader = ui.Gradient.radial(Offset.zero, 31, [
            const Color(0xFFC5BCF0).withValues(alpha: 0.10),
            const Color(0x00C5BCF0),
          ]),
      );
      canvas.restore();
    }

    // One short shooting star per twelve-second scene cycle.
    final shooting = ((phase - 0.52) / 0.09);
    if (shooting > 0 && shooting < 1) {
      final point = Offset(435 + shooting * 65, 42 + shooting * 40);
      final tail = point - const Offset(23, 14);
      canvas.drawLine(
        tail,
        point,
        Paint()
          ..shader = ui.Gradient.linear(tail, point, [
            const Color(0x00EDE7FF),
            const Color(0xFFEDE7FF)
                .withValues(alpha: math.sin(shooting * math.pi) * 0.7),
          ])
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => true;
}

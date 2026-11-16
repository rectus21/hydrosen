import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../features/thermos/art.dart';
import '../features/thermos/thermos_painter.dart' show designRect;
import '../features/thermos/thermos_theme.dart';

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

class _ThemeSceneState extends State<ThemeScene> {
  final _sceneKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: _sceneKey,
      painter: _ScenePainter(
        theme: widget.theme,
        sceneKey: _sceneKey,
        thermosKey: widget.thermosKey,
        repaint: widget.scroll,
      ),
      child: widget.child,
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.theme,
    required this.sceneKey,
    required this.thermosKey,
    super.repaint,
  });

  final ThermosTheme theme;
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
    final tb = thermosKey?.currentContext?.findRenderObject();
    final sb = sceneKey.currentContext?.findRenderObject();
    if (tb is RenderBox &&
        sb is RenderBox &&
        tb.attached &&
        sb.attached &&
        tb.hasSize &&
        sb.hasSize) {
      try {
        return tb.localToGlobal(Offset.zero, ancestor: sb) & tb.size;
      } catch (_) {
        // Yerleşim henüz bitmediyse sabit konuma düşülür.
      }
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
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(ox, oy);
    canvas.scale(s);
    canvas.translate(-designRect.left, -designRect.top);
    canvas.drawPicture(_picture(theme));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScenePainter old) => true;
}

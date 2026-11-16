import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../features/thermos/art.dart';
import '../features/thermos/thermos_painter.dart' show designRect;
import '../features/thermos/thermos_theme.dart';

/// Temanın arka plan sahnesini tüm ekrana yayar. Sahne termosla aynı ölçekte
/// çizilir (termos sahnede durur, kutlama çizimleri aynı yere oturur); çizimin
/// ulaşmadığı yerler doğal biçimde uzatılır: yanlara aynalanır, yukarı ve
/// aşağı çizimin kendi kenar satırı yumuşatılarak sürülür.
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

  /// Tema başına (ve gereken yan döşeme sayısına göre) kaydedilmiş sahne;
  /// yalnız tema değişince yeniden kaydedilir.
  static final _pictures = <String, ui.Picture>{};

  static const _far = 3000.0;

  /// Çizimin alt/üst kenarındaki yarı saydam kenar yumuşatmaları (AA) uzatma
  /// ile birleşirken çizgi bırakmasın diye çizim kenardan bu kadar içeriden
  /// kesilir; uzatma o noktadaki tam renkten başlar.
  static const _inset = 2.0;

  /// Yan döşemenin genişliği: kenar yumuşatması döşeme sınırına düşmesin diye
  /// çizimin her iki yanından [_inset] içeriden aynalanır.
  static final _period = designRect.width - 2 * _inset;

  static ui.Picture _picture(ThermosTheme t, int n) {
    final key = '${t.id}:$n';
    final hit = _pictures[key];
    if (hit != null) return hit;
    if (_pictures.length >= 8) {
      for (final p in _pictures.values) {
        p.dispose();
      }
      _pictures.clear();
    }
    return _pictures[key] = _record(t, n);
  }

  static ui.Picture _record(ThermosTheme t, int n) {
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    final xl = designRect.center.dx - (n + 0.5) * _period;
    final xr = designRect.center.dx + (n + 0.5) * _period;

    void row(Canvas cv) {
      // Dıştan içe: ortadaki döşeme en üstte kalır; komşular 1 birim taşar
      // (kenarda ince çizgi kalmasın).
      final order = [for (var i = -n; i <= n; i++) i]
        ..sort((a, b) => b.abs().compareTo(a.abs()));
      for (final i in order) {
        final cx = designRect.center.dx + i * _period;
        cv.save();
        cv.clipRect(
          Rect.fromLTRB(
            cx - _period / 2 - (i == 0 ? 0 : 1),
            designRect.top + _inset,
            cx + _period / 2 + (i == 0 ? 0 : 1),
            designRect.bottom - _inset,
          ),
          doAntiAlias: false,
        );
        cv.translate(cx, 0);
        if (i.isOdd) cv.scale(-1, 1);
        cv.translate(-designRect.center.dx, 0);
        t.background(Art(cv));
        cv.restore();
      }
    }

    // Yukarı ve aşağı: çizimin en kenar satırını sonsuza uzat, yatayda
    // bulanıklaştır (yıldız, bulut gibi ayrıntılar çizgi bırakmasın).
    void extend({required bool top}) {
      final edge = top ? designRect.top + _inset : designRect.bottom - _inset;
      final area = top
          ? Rect.fromLTRB(xl, edge - _far, xr, edge + 1)
          : Rect.fromLTRB(xl, edge - 1, xr, edge + _far);
      c.save();
      c.clipRect(area);
      c.saveLayer(
        area,
        Paint()
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: 80,
            sigmaY: 0.01,
            tileMode: TileMode.clamp,
          ),
      );
      // Şerit (1 birim) kenardan 1 birim içeri taşacak biçimde uzatılır; çizimin
      // kendisi üstüne bindiği için kenarda çizgi kalmaz.
      final src = top ? edge : edge - 1;
      c.translate(0, top ? edge + 1 : edge - 1);
      c.scale(1, top ? -(_far + 1) : _far + 1);
      c.translate(0, -src);
      // Kenar satırı: çizimin kenarındaki 1 birimlik şerit.
      c.clipRect(
        top
            ? Rect.fromLTRB(xl, edge, xr, edge + 1)
            : Rect.fromLTRB(xl, edge - 1, xr, edge),
      );
      row(c);
      c.restore();
      c.restore();
    }

    extend(top: true);
    extend(top: false);
    row(c);
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
    // Ekran kenarlarının tasarım koordinatındaki karşılığı.
    final left = designRect.left - ox / s;
    final right = designRect.left + (size.width - ox) / s;
    final n = math.min(
      3,
      math.max(
        0,
        math.max(
          ((designRect.center.dx - left) / _period - 0.5).ceil(),
          ((right - designRect.center.dx) / _period - 0.5).ceil(),
        ),
      ),
    );

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(ox, oy);
    canvas.scale(s);
    canvas.translate(-designRect.left, -designRect.top);
    canvas.drawPicture(_picture(theme, n));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScenePainter old) => true;
}

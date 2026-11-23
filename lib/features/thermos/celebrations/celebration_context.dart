import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import '../celebration_painter.dart';
import '../celebration_style.dart';
import '../illustrated_artwork.dart';
import '../thermos_painter.dart';
import '../thermos_theme.dart';
import '../wolf_artwork.dart';

/// Tema imza kutlaması: [ctx] ile tasarım koordinatlarında (440x504 kart,
/// bkz. [designRect]) doğrudan [canvas]'a çizer. Kart kırpması ve ölçek
/// çağıran tarafından uygulanmıştır.
typedef SignatureCelebration = void Function(
  Canvas canvas,
  CelebrationContext ctx,
);

/// İmza kutlamasının kapağa uyguladığı küçük hareket (zıplama/sallanma).
/// Kapağın alt-orta noktası etrafında [dx],[dy] (tasarım birimi), [rotation]
/// (radyan) ve [scale] uygulanır.
class CapPose {
  const CapPose({this.dx = 0, this.dy = 0, this.rotation = 0, this.scale = 1});

  static const identity = CapPose();

  final double dx, dy, rotation, scale;

  bool get isIdentity => dx == 0 && dy == 0 && rotation == 0 && scale == 1;

  @override
  bool operator ==(Object other) =>
      other is CapPose &&
      other.dx == dx &&
      other.dy == dy &&
      other.rotation == rotation &&
      other.scale == scale;

  @override
  int get hashCode => Object.hash(dx, dy, rotation, scale);
}

/// Kapak pozu: bağlam (t, şekil...) -> poz. Yalnız kutlama sırasında uygulanır;
/// "animasyonları azalt" açıkken hiç çağrılmaz.
typedef CapPoseFn = CapPose Function(CelebrationContext ctx);

/// Kapak çapa noktaları, kapak çiziminin ham koordinatlarında (tombul için
/// ThermosPainter'ın [chubbyCapScale] küçültmesi ctx tarafından uygulanır).
class _CapRaw {
  const _CapRaw({
    required this.center,
    required this.top,
    required this.width,
    required this.eyeL,
    required this.eyeR,
    required this.nose,
    required this.mouth,
  });

  final Offset center, eyeL, eyeR, nose, mouth;
  final double top, width;

  static const chubby = _CapRaw(
    center: Offset(340, 130),
    top: 50,
    width: 192,
    eyeL: Offset(298, 124),
    eyeR: Offset(382, 124),
    nose: Offset(340, 166),
    mouth: Offset(340, 194),
  );
  static const slim = _CapRaw(
    center: Offset(340, 127),
    top: 90,
    width: 112,
    eyeL: Offset(312, 118),
    eyeR: Offset(368, 118),
    nose: Offset(340, 146),
    mouth: Offset(340, 157),
  );
}

/// İmza kutlamasına verilen her şey. Tüm konumlar tasarım koordinatlarında ve
/// (varsa) kapak pozu uygulanmış hâlidir.
class CelebrationContext {
  CelebrationContext({
    required this.painter,
    this.level = 1.0,
    this.pose = CapPose.identity,
  });

  /// Genel çizicileri (konfeti, kalp...) yeniden kullanmak için.
  final CelebrationPainter painter;

  /// Suyun doluluğu 0..1 (kutlama hedefte olduğundan genelde 1).
  final double level;

  /// Uygulanmış kapak pozu (çapalar buna göre kayar).
  final CapPose pose;

  /// Temaya göre sabit tohumlu rastgele (her kare aynı diziyi verir).
  /// Parçacık başına sabit değer için [rand] daha uygundur.
  math.Random get rng => math.Random(painter.theme.id.hashCode);

  ThermosTheme get theme => painter.theme;
  ThermosShape get shape => painter.shape;
  bool get chubby => shape == ThermosShape.chubby;
  bool get reduceMotion => painter.reduceMotion;

  /// Hedef aşıldığı sürece oynayan döngü evresinde mi?
  bool get looping => painter.looping;

  /// Döngü evresi 0..1 (tekrarlar; giriş sırasında 0).
  double get loop => painter.loop ?? 0;

  /// Kaçıncı döngü turu (0'dan).
  int get loopCount => painter.loopCount;

  /// Efekt şiddeti: giriş 1.0, döngü ~0.8.
  double get intensity => painter.intensity;

  /// Kutlama ilerlemesi 0..1 (overlay süresi boyunca; döngüde ~0.18..0.88).
  double get t => painter.t;

  /// Overlay süresi, saniye.
  static const duration = 2.6;

  /// Geçen süre, saniye.
  double get elapsed => painter.t * duration;

  /// Başta hızlı belirip sonda sönen genel zarf (0..1).
  double get alpha => painter.alphaEnvelope;

  /// Tema sahnesindeki normalleştirilmiş noktanın (u, v) kart koordinatı.
  Offset? sceneUv(double u, double v) => painter.sceneToDesign(u, v);

  bool get hasIllustratedCap => IllustratedArtwork.byId.containsKey(theme.id);

  /// Resimli kapakların yüzü eski vektör kapaklardan daha büyük ve daha
  /// yukarıdadır. Efektleri eski sabit noktalardan başlatmak suyu, alevi,
  /// dili ve topu çenenin altına taşıyordu. Çapaları, çizicinin kullandığı
  /// gerçek hedef dikdörtgenden türet; tombul ölçeği [capPt] içinde uygulanır.
  _CapRaw get _raw {
    if (!hasIllustratedCap) return chubby ? _CapRaw.chubby : _CapRaw.slim;
    final illustrated = IllustratedArtwork.byId[theme.id]!;
    final r = IllustratedArtwork.capDestinationRect(
      shape,
      id: theme.id,
      happy: true,
      image: illustrated.happy,
    );
    Offset p(double x, double y) =>
        Offset(r.left + r.width * x, r.top + r.height * y);
    return _CapRaw(
      center: p(0.5, 0.5),
      top: r.top,
      width: r.width,
      eyeL: p(0.34, 0.48),
      eyeR: p(0.66, 0.48),
      nose: p(0.5, 0.61),
      mouth: p(0.5, 0.72),
    );
  }

  /// Ham kapak çizim koordinatını tasarım koordinatına çevirir (tombulda
  /// küçültme, ardından kapak pozu).
  Offset capPt(double x, double y) {
    var dx = x, dy = y;
    if (chubby) {
      dx = 340 + (x - 340) * chubbyCapScale;
      dy = 208 + (y - 208) * chubbyCapScale;
    }
    if (pose.isIdentity) return Offset(dx, dy);
    final pivot = Offset(340, chubby ? 208 : 178);
    final v = Offset(dx, dy) - pivot;
    final c = math.cos(pose.rotation), s = math.sin(pose.rotation);
    return pivot +
        Offset(
          (v.dx * c - v.dy * s) * pose.scale + pose.dx,
          (v.dx * s + v.dy * c) * pose.scale + pose.dy,
        );
  }

  double get _k => chubby ? chubbyCapScale : 1.0;

  /// Resimli kapak görselinin (u, v) noktası (0..1; sol-üst = 0,0), tasarım
  /// koordinatında (tombul ölçeği ve kapak pozu dahil). Resimli kapak yoksa
  /// kapak merkezi.
  Offset capImagePt(double u, double v) {
    final art = IllustratedArtwork.byId[theme.id];
    if (art == null) return capCenter;
    final r = IllustratedArtwork.capDestinationRect(
      shape,
      id: theme.id,
      happy: true,
      image: art.happy,
    );
    return capPt(r.left + r.width * u, r.top + r.height * v);
  }

  /// Resimli kapağı, [ThermosPainter]'ın çizdiği gibi (kapak pozu ve tombul
  /// ölçeği dahil) kutlama katmanının üstüne yeniden çizer. Kapağın ARKASINDA
  /// kalması gereken efektler (gökkuşağı, bayrak direği...) için: efekti çiz,
  /// sonra bunu çağır. Resimli kapak yoksa hiçbir şey yapmaz.
  void drawCapOver(Canvas canvas) {
    final art = IllustratedArtwork.byId[theme.id];
    if (art == null) return;
    final image = art.happy;
    final rect = IllustratedArtwork.capDestinationRect(
      shape,
      id: theme.id,
      happy: true,
      image: image,
    );
    canvas.save();
    if (!pose.isIdentity) {
      final pivotY = chubby ? 208.0 : 178.0;
      canvas.translate(340 + pose.dx, pivotY + pose.dy);
      canvas.rotate(pose.rotation);
      canvas.scale(pose.scale);
      canvas.translate(-340, -pivotY);
    }
    if (chubby) {
      canvas.translate(340, 208);
      canvas.scale(chubbyCapScale);
      canvas.translate(-340, -208);
    }
    canvas.drawImageRect(
      image,
      IllustratedArtwork.capSourceRect(theme.id, image, happy: true),
      rect,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }

  Offset get capCenter => capPt(_raw.center.dx, _raw.center.dy);
  Offset get capTop => capPt(_raw.center.dx, _raw.top);

  /// Kapağın yaklaşık genişliği (tasarım birimi).
  double get capWidth => _raw.width * _k * pose.scale;
  Offset get eyeLeft => capPt(_raw.eyeL.dx, _raw.eyeL.dy);
  Offset get eyeRight => capPt(_raw.eyeR.dx, _raw.eyeR.dy);

  /// Göz hattının yaklaşık y'si.
  double get eyeLine => (eyeLeft.dy + eyeRight.dy) / 2;
  Offset get nose => capPt(_raw.nose.dx, _raw.nose.dy);
  Offset get mouth {
    final point = theme.id == 'kurt' && WolfArtwork.current != null
        ? WolfArtwork.mouth(
            shape,
            lift: WolfArtwork.howlLift(
              intro: looping ? null : t,
              loop: looping ? loop : null,
            ),
          )
        : _raw.mouth;
    return capPt(point.dx, point.dy);
  }

  /// Cam gövdesi dikdörtgeni.
  Rect get glass => chubby
      ? const Rect.fromLTRB(274, 200, 406, 478)
      : const Rect.fromLTRB(290, 178, 390, 482);

  /// Su yüzeyinin (düz) y'si.
  double get waterY {
    final top = chubby ? 222.0 : 196.0, bottom = chubby ? 450.0 : 456.0;
    return bottom - level.clamp(0.0, 1.0) * (bottom - top);
  }

  // --- Yardımcılar -----------------------------------------------------------

  static double easeOut(double x) =>
      Curves.easeOutCubic.transform(x.clamp(0.0, 1.0));
  static double easeInOut(double x) =>
      Curves.easeInOut.transform(x.clamp(0.0, 1.0));

  /// 0..1..0 yumuşak tepe (x: 0..1).
  static double pulse(double x) => math.sin(x.clamp(0.0, 1.0) * math.pi);

  static double lerp(double a, double b, double x) => a + (b - a) * x;

  /// t'yi [start]..[end] penceresinde 0..1'e eşler.
  double span(double start, double end) =>
      ((t - start) / (end - start)).clamp(0.0, 1.0);

  /// Parçacık başına sabit rastgele değer (0..1); aynı (i, salt) hep aynı.
  double rand(int i, [int salt = 0]) => CelebrationPainter.rnd(i, salt + 500);

  /// Zarfla ([alpha]) çarpılmış boya; [hex] 0xRRGGBB.
  Paint paintOf(int hex, [double opacity = 1]) => painter.paintOf(hex, opacity);

  /// Zarfsız boya.
  Paint solid(int hex, [double opacity = 1]) =>
      Paint()
        ..color = Color(0xFF000000 | hex)
            .withValues(alpha: opacity.clamp(0.0, 1.0));

  /// 8 köşeli yıldız.
  void star(Canvas canvas, Offset c, double r, int hex, [double op = 1]) =>
      painter.drawStar(canvas, c, r, hex, op);

  /// Mevcut genel parçacık efektlerinden birini çizer (konfeti, kalp,
  /// kıvılcım, kar, baloncuk, yıldız tozu, yaprak, damla halkası...).
  void kind(Canvas canvas, CelebrationKind k, List<int> colors) =>
      painter.drawKind(canvas, k, colors);
}

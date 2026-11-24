import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import 'thermos_theme.dart';

/// Raster artwork for illustrated themes.
class IllustratedArtwork {
  const IllustratedArtwork(this.normal, this.happy, this.scene);
  final ui.Image normal, happy;
  final ui.Image? scene;
  static final byId = <String, IllustratedArtwork>{};

  /// Sahnenin üst bandının (uygulama çubuğunun arkası) ortalama parlaklığı
  /// 0..1; başlık/ikon rengini seçmek için. Sahnesiz temalarda yoktur.
  static final topLuma = <String, double>{};

  /// Sahnenin alt bandının (günlük kontrol alanının arkası) ortalama
  /// parlaklığı 0..1; toplam metni rengini seçmek için.
  static final bottomLuma = <String, double>{};

  /// Sahnenin orta bandı (şişenin sağındaki ölçek yazıları); 0..1.
  static final midLuma = <String, double>{};

  static Future<double> _sampleTopLuma(ui.Image scene) =>
      _sampleBandLuma(scene, 0, 0.08);

  /// Bir sahne görselinin üst, alt ve orta bant parlaklıklarını örnekler.
  /// [WolfArtwork] gibi ayrı yüklenen sahneler de bunu kullanır.
  static Future<void> sampleSceneLuma(String id, ui.Image scene) async {
    try {
      topLuma[id] = await _sampleTopLuma(scene);
      bottomLuma[id] = await _sampleBandLuma(scene, 0.72, 0.94);
      midLuma[id] = await _sampleBandLuma(scene, 0.30, 0.70);
    } catch (_) {
      // Parlaklık örneği alınamazsa tema varsayılan renkte kalır.
    }
  }

  static Future<double> _sampleBandLuma(
    ui.Image scene,
    double fromFrac,
    double toFrac,
  ) async {
    const w = 16, h = 3;
    final rec = ui.PictureRecorder();
    ui.Canvas(rec).drawImageRect(
      scene,
      ui.Rect.fromLTRB(
        0,
        scene.height * fromFrac,
        scene.width.toDouble(),
        scene.height * toFrac,
      ),
      ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
    final picture = rec.endRecording();
    final ui.Image small;
    try {
      small = await picture.toImage(w, h);
    } finally {
      picture.dispose();
    }
    final data = await small.toByteData();
    small.dispose();
    if (data == null) return 0.5;
    var sum = 0.0;
    for (var i = 0; i < w * h; i++) {
      sum +=
          0.2126 * data.getUint8(i * 4) +
          0.7152 * data.getUint8(i * 4 + 1) +
          0.0722 * data.getUint8(i * 4 + 2);
    }
    return sum / (w * h * 255);
  }

  /// Some generated caps have much wider transparent margins than the others.
  /// Crop those margins while keeping the collar at the same bottle position.
  static ui.Rect capSourceRect(
    String id,
    ui.Image image, {
    required bool happy,
  }) {
    if (id == 'panda') {
      // Kapaksız başların çene altını kaynak karesinin altına sabitle.
      final side = image.width * (480 / 512);
      final opaqueBottom = image.height * ((happy ? 468 : 462) / 512);
      return ui.Rect.fromLTWH(
        image.width * (16 / 512),
        opaqueBottom - side,
        side,
        side,
      );
    }
    if (id == 'baykus') {
      // İki ifade için aynı kareyi kullan; göz kırpınca baş ölçeği değişmez.
      final side = image.width * (380 / 512);
      final opaqueBottom = image.height * ((happy ? 401 : 403) / 512);
      return ui.Rect.fromLTWH(
        image.width * (65 / 512),
        opaqueBottom - side,
        side,
        side,
      );
    }
    if (id == 'astronot') {
      // Kaskın PNG'sinde kenarlarda (x=0 sütunu, son satır) yarı saydam bir
      // çerçeve izi ve çenenin altında boş pay var; yalnız kask gövdesini al.
      final k = image.width / 512;
      return ui.Rect.fromLTWH(6 * k, 0, 500 * k, 430 * k);
    }
    return ui.Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
  }

  /// Bazı kapak çizimleri ekrana sığması ya da termosa oranı için kare
  /// hedefin içinde küçültülür/büyütülür (tutamak: boyun çizgisi, yani
  /// görünür alt sınırın orta noktası; kapak boyunda sabit kalır).
  static const capScaleOf = <String, double>{
    // Boynuz/kulaklar ana ekranda üstten kırpılıyordu.
    'tekboynuz': 0.78,
    // Şapka ve bayrak üst çubuğun altında kalsın.
    'korsan': 0.80,
    // Kafa ve kulaklar termosa göre biraz daha iri (+%12).
    'fil': 1.12,
    // Cam damla kapağın halkası (422 px) boyun genişliğini aşıyordu; halka
    // boyun genişliğine (slim: 320 kaynak px) denk gelsin.
    'klasik': 0.78,
    // Rectus: limon başı %20 büyüsün (0.78 × 1.2).
    'limon': 0.94,
  };

  /// Ham kapak dikdörtgeni. Tombul termosun çizicisi bu dikdörtgeni daha
  /// sonra [chubbyCapScale] ile küçültür. Her iki şeklin de görsel bileziği
  /// cam gövdenin omzunda biter; böylece kapak ne gövdenin içine gömülür ne
  /// de boynun üstünde yüzer.
  static ui.Rect capDestinationRect(
    ThermosShape shape, {
    String? id,
    bool happy = false,
    ui.Image? image,
  }) {
    final base = shape == ThermosShape.chubby
        ? const ui.Rect.fromLTWH(230, -23, 220, 220)
        : const ui.Rect.fromLTWH(260, 18, 160, 160);
    if (id == null || image == null || id == 'panda' || id == 'baykus') {
      return base;
    }
    final scale = capScaleOf[id] ?? 1.0;
    ui.Rect fit(ui.Rect r) {
      if (scale == 1.0) return r;
      // Boyun çizgisi: base.bottom (görünür alt sınır hep orada).
      final ax = base.center.dx, ay = base.bottom;
      return ui.Rect.fromLTRB(
        ax + (r.left - ax) * scale,
        ay + (r.top - ay) * scale,
        ax + (r.right - ax) * scale,
        ay + (r.bottom - ay) * scale,
      );
    }

    if (id == 'astronot') {
      // Kaynak: kask gövdesi (6..506 x 0..430); görünür alt sınır y=421.
      final k = base.width / 512;
      final r = ui.Rect.fromLTWH(
        base.left + 6 * k,
        base.bottom - 421 * k,
        500 * k,
        430 * k,
      );
      return fit(r);
    }

    // Kapaksız görsellerin görünür alt sınırları farklı yüksekliklerde. Görseli
    // esnetmeden bu sınırı termos boynuna sabitle; tüm başlar Tilki ile aynı
    // doğal birleşim çizgisinde otursun.
    const opaqueBottom = <String, (double, double)>{
      // Balina ve Tekboynuz artık ayrı bir kapak halkası taşımaz. Görünür
      // çene altını termos boynunun üst çizgisine sabitle; iki ifade arasında
      // başın zıplamasını ve boyunla arada boşluk oluşmasını engelle.
      'balina': (456, 450),
      'ahtapot': (489, 489),
      'aslan': (487, 483),
      'avokado': (491, 485),
      'ayi': (421, 421),
      'boga': (478, 480),
      'bulut': (427, 426),
      'cilek': (496, 496),
      'civciv': (500, 512),
      'dondurma': (512, 512),
      'ejderha': (460, 475),
      // Görünür alt sınır gerçekte 438; eski 485 başı boyunun üstünde
      // yüzdürüyordu.
      'fil': (439, 438),
      'fok': (482, 484),
      'geyik': (491, 491),
      'gece': (475, 465),
      'inek': (471, 471),
      'kaktus': (442, 443),
      'kamp': (491, 491),
      'klasik': (401, 401),
      'kaplan': (477, 474),
      'kardanadam': (505, 504),
      'karpuz': (484, 484),
      'kirpi': (422, 422),
      'kopek': (503, 501),
      'koala': (472, 466),
      'korsan': (486, 491),
      'koyun': (491, 489),
      'limon': (492, 492),
      'maviejderha': (478, 482),
      'maymun': (473, 474),
      'okyanus': (492, 492),
      'penguen': (475, 486),
      'rakun': (472, 472),
      'robot': (474, 480),
      'sihirbaz': (487, 483),
      'sincap': (485, 489),
      'susamuru': (488, 487),
      'tavsan': (512, 512),
      'tilki': (506, 508),
      'tekboynuz': (501, 502),
      'yesilelma': (492, 492),
      'futbol': (492, 492),
      'basketbol': (492, 492),
      'voleybol': (492, 492),
      'kedi': (492, 492),
      'pofuduk': (492, 492),
      'karaejderha': (492, 492),
      'yarisarabasi': (492, 492),
    };
    final bottoms = opaqueBottom[id];
    if (bottoms == null) return base;
    final bottom = happy ? bottoms.$2 : bottoms.$1;
    final transparentBottom = image.height - image.height * (bottom / 512);
    final dy = base.height * transparentBottom / image.height;
    return fit(base.shift(ui.Offset(0, dy)));
  }

  static Future<void> load() async {
    for (final id in [
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
      'klasik',
      'cilek',
      'tekboynuz',
      'kamp',
      'susamuru',
      'fok',
      'balina',
      'okyanus',
      'ahtapot',
      'kaktus',
      'koala',
      'fil',
      'rakun',
      'geyik',
      'inek',
      'koyun',
      'maymun',
      'robot',
      'korsan',
      'gece',
      'sihirbaz',
      'maviejderha',
      'karpuz',
      'limon',
      'avokado',
      'dondurma',
      'yesilelma',
      'futbol',
      'basketbol',
      'voleybol',
      'karaejderha',
      'yarisarabasi',
      'kedi',
      'pofuduk',
    ]) {
      if (byId.containsKey(id)) continue;
      final images = <ui.Image>[];
      try {
        Future<ui.Image> decode(String path) async {
          final bytes = await rootBundle.load(path);
          final codec = await ui.instantiateImageCodec(
            bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
          );
          try {
            return (await codec.getNextFrame()).image;
          } finally {
            codec.dispose();
          }
        }

        final normal = await decode('assets/caps/${id}_normal.png');
        images.add(normal);
        ui.Image happy;
        try {
          happy = await decode('assets/caps/${id}_happy.png');
          images.add(happy);
        } catch (_) {
          // The signature celebration remains animated even when a separate
          // expression is not available yet.
          happy = normal;
        }
        ui.Image? scene;
        try {
          scene = await decode('assets/scenes/$id.png');
          images.add(scene);
          await sampleSceneLuma(id, scene);
        } catch (_) {
          // New illustrated caps inherit the theme's existing vector scene.
        }
        byId[id] = IllustratedArtwork(normal, happy, scene);
      } catch (_) {
        for (final image in images) {
          image.dispose();
        }
      }
    }
  }
}

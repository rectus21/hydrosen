import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import 'thermos_theme.dart';

/// Raster artwork for illustrated themes.
class IllustratedArtwork {
  const IllustratedArtwork(this.normal, this.happy, this.scene);
  final ui.Image normal, happy;
  final ui.Image? scene;
  static final byId = <String, IllustratedArtwork>{};

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
    return ui.Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
  }

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
      'astronot': (510, 510),
      'avokado': (491, 485),
      'ayi': (421, 421),
      'boga': (478, 480),
      'bulut': (427, 426),
      'cilek': (496, 496),
      'civciv': (500, 512),
      'dondurma': (512, 512),
      'ejderha': (460, 475),
      'fil': (485, 485),
      'fok': (482, 484),
      'geyik': (491, 491),
      'gece': (475, 465),
      'inek': (471, 471),
      'kaktus': (442, 443),
      'kamp': (499, 504),
      'kaplan': (477, 474),
      'kardanadam': (505, 504),
      'karpuz': (484, 484),
      'kirpi': (422, 422),
      'kopek': (503, 501),
      'koala': (472, 466),
      'korsan': (486, 491),
      'koyun': (491, 489),
      'limon': (468, 466),
      'maviejderha': (478, 482),
      'maymun': (473, 474),
      'okyanus': (480, 489),
      'penguen': (475, 486),
      'rakun': (472, 472),
      'robot': (474, 480),
      'seftali': (410, 410),
      'sihirbaz': (487, 483),
      'sincap': (485, 489),
      'susamuru': (488, 487),
      'tavsan': (512, 512),
      'tilki': (506, 508),
      'tekboynuz': (501, 502),
    };
    final bottoms = opaqueBottom[id];
    if (bottoms == null) return base;
    final bottom = happy ? bottoms.$2 : bottoms.$1;
    final transparentBottom = image.height - image.height * (bottom / 512);
    final dy = base.height * transparentBottom / image.height;
    return base.shift(ui.Offset(0, dy));
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
      'seftali',
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

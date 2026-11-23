import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Kutlama sprite'ları (assets/fx/*.png): bir kez yüklenir, bellekte tutulur.
/// Yüklenmemişse (ör. testte) çizimler sessizce atlanır.
class FxSprites {
  FxSprites._();

  static const names = <String>[
    'kopek_bone',
    'kopek_paw',
    'penguen_aurora',
    'penguen_mini_slide',
    'penguen_snowflake',
    'koala_leaf_1',
    'koala_leaf_2',
    'koyun_wool_puff',
    'koyun_mini_jump',
    'koyun_fence',
    'avokado_sprout_1',
    'avokado_sprout_2',
    'avokado_flower',
    'kaktus_cloud',
    'kaktus_raindrop',
    'kaktus_flower',
    'kaktus_petal',
    'kaktus_rainbow',
    'baykus_book_open',
    'baykus_book_closed',
    'civciv_mini_mic_r',
    'civciv_mini_mic_l',
    'civciv_mic',
    'rakun_apple',
    'rakun_apple_wet',
    'rakun_bubble',
    'rakun_tub',
    'avokado_disco_ball',
    'avokado_note',
    'kamp_fire',
    'kamp_marshmallow',
    'okyanus_fin',
    'okyanus_wave',
    'okyanus_fish1',
    'okyanus_fish2',
    'okyanus_bubble',
    'limon_umbrella_side',
    'limon_umbrella_top',
    'limon_slice',
    'limon_ice',
    'limon_foam',
    'limon_bubble',
    'kedi_paw',
    'kedi_tail',
    'kedi_heart',
    'pofuduk_paw',
    'pofuduk_tail',
    'pofuduk_yarn',
    'okyanus_splash',
  ];

  static final _images = <String, ui.Image>{};
  static Future<void>? _loading;

  static ui.Image? get(String name) => _images[name];

  static bool get loaded => _images.length == names.length;

  /// Tüm sprite'ları (bir kez) yükler; eksik dosya diğerlerini engellemez.
  static Future<void> load() => _loading ??= _loadAll();

  static Future<void> _loadAll() async {
    for (final n in names) {
      if (_images.containsKey(n)) continue;
      try {
        final bytes = await rootBundle.load('assets/fx/$n.png');
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        );
        try {
          _images[n] = (await codec.getNextFrame()).image;
        } finally {
          codec.dispose();
        }
      } catch (_) {
        // Sprite yoksa o parça çizilmez.
      }
    }
  }
}

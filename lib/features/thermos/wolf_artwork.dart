import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import 'thermos_theme.dart';

/// First illustrated theme. Vector artwork remains the loading/error fallback.
class WolfArtwork {
  WolfArtwork._(this.normal, this.howl, this.scene);

  final ui.Image normal, howl, scene;
  static WolfArtwork? current;

  static Future<WolfArtwork?> load() async {
    if (current != null) return current;
    final images = <ui.Image>[];
    try {
      for (final path in const [
        'assets/caps/kurt_normal.png',
        'assets/caps/kurt_howl.png',
        'assets/scenes/kurt.png',
      ]) {
        final bytes = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        );
        try {
          images.add((await codec.getNextFrame()).image);
        } finally {
          codec.dispose();
        }
      }
      return current = WolfArtwork._(images[0], images[1], images[2]);
    } catch (_) {
      for (final image in images) {
        image.dispose();
      }
      return null;
    }
  }

  /// Raw cap coordinates; the painter subsequently applies chubby scaling/pose.
  static ui.Rect capRect(ThermosShape shape) => shape == ThermosShape.chubby
      ? const ui.Rect.fromLTWH(230, -8, 220, 220)
      : const ui.Rect.fromLTWH(260, 10, 160, 160);

  /// Blend the lifted face in during each howl and settle between howls.
  static double howlLift({double? intro, double? loop}) {
    double smooth(double x) {
      final v = x.clamp(0.0, 1.0);
      return v * v * (3 - 2 * v);
    }

    if (loop != null) {
      final phase = loop % 1;
      return smooth((phase - 0.04) / 0.20) *
          (1 - smooth((phase - 0.80) / 0.16));
    }
    if (intro != null) {
      return smooth((intro - 0.08) / 0.20) *
          (1 - smooth((intro - 0.86) / 0.14));
    }
    return 1;
  }

  static ui.Offset mouth(ThermosShape shape, {double lift = 1}) {
    final rect = capRect(shape);
    final fraction = 0.79 + (0.49 - 0.79) * lift;
    return ui.Offset(rect.center.dx, rect.top + rect.height * fraction);
  }
}

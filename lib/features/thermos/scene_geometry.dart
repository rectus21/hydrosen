import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'illustrated_artwork.dart';

/// Tema sahnesinin (cover-fit, üst-orta hizalı) konumunu kutlama katmanına
/// verir: sahne görselindeki normalleştirilmiş bir noktanın kutlama
/// katmanındaki yerel konumunu hesaplar.
class SceneGeometry {
  static GlobalKey? sceneKey;

  static Offset? toLocal(BuildContext overlay, String themeId, double u, double v) {
    try {
      final image = IllustratedArtwork.byId[themeId]?.scene;
      final sb = sceneKey?.currentContext?.findRenderObject();
      final ob = overlay.findRenderObject();
      if (image == null || sb is! RenderBox || ob is! RenderBox) return null;
      if (!sb.attached || !ob.attached || !sb.hasSize || !ob.hasSize) {
        return null;
      }
      final iw = image.width.toDouble(), ih = image.height.toDouble();
      final sc = math.max(sb.size.width / iw, sb.size.height / ih);
      final dx = (sb.size.width - iw * sc) / 2;
      final inScene = Offset(dx + u * iw * sc, v * ih * sc);
      return ob.globalToLocal(sb.localToGlobal(inScene));
    } catch (_) {
      return null;
    }
  }
}

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'illustrated_artwork.dart';
import 'wolf_artwork.dart';

/// Yakın ata [ThemeScene]'in anahtarını alt ağaca iletir; ikinci bir ekran
/// (ör. Ayarlar) açılıp kapanınca ana ekranın sahne anahtarını ezmez.
class SceneGeometryScope extends InheritedWidget {
  const SceneGeometryScope({
    super.key,
    required this.sceneKey,
    required super.child,
  });

  final GlobalKey sceneKey;

  static GlobalKey? maybeKeyOf(BuildContext context) => context
      .getInheritedWidgetOfExactType<SceneGeometryScope>()
      ?.sceneKey;

  @override
  bool updateShouldNotify(SceneGeometryScope oldWidget) =>
      oldWidget.sceneKey != sceneKey;
}

/// Tema sahnesinin (cover-fit, üst-orta hizalı) konumunu kutlama katmanına
/// verir: sahne görselindeki normalleştirilmiş bir noktanın kutlama
/// katmanındaki yerel konumunu hesaplar.
class SceneGeometry {
  static GlobalKey? sceneKey;

  static Offset? toLocal(
    BuildContext overlay,
    String themeId,
    double u,
    double v,
  ) {
    try {
      final image = themeId == 'kurt'
          ? WolfArtwork.current?.scene
          : IllustratedArtwork.byId[themeId]?.scene;
      final key = SceneGeometryScope.maybeKeyOf(overlay) ?? sceneKey;
      final sb = key?.currentContext?.findRenderObject();
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

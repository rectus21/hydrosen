import '../celebration_painter.dart';
import 'celebration_context.dart';
import 'celebrations_g1.dart';
import 'celebrations_g2.dart';
import 'celebrations_g3.dart';
import 'celebrations_g4.dart';

export 'celebration_context.dart';

/// Tüm imza kutlamaları (tema id -> çizim). Yeni giriş g1..g4 dosyalarına eklenir.
final Map<String, SignatureCelebration> signatureCelebrations = {
  ...g1Celebrations,
  ...g2Celebrations,
  ...g3Celebrations,
  ...g4Celebrations,
};

/// İsteğe bağlı kapak hareketleri (tema id -> poz).
final Map<String, CapPoseFn> signatureCapPoses = {
  ...g1CapPoses,
  ...g2CapPoses,
  ...g3CapPoses,
  ...g4CapPoses,
};

/// [painter] için (t'ye göre) kapak pozu; kayıtlı poz yoksa ya da hareket
/// azaltılmışsa [CapPose.identity].
CapPose resolveCapPose(CelebrationPainter painter) {
  final fn = signatureCapPoses[painter.theme.id];
  if (fn == null || painter.reduceMotion) return CapPose.identity;
  return fn(CelebrationContext(painter: painter, level: painter.level));
}

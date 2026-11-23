import '../celebration_painter.dart';
import 'celebration_context.dart';
import 'celebrations_g1.dart';
import 'celebrations_g2.dart';
import 'celebrations_g3.dart';
import 'celebrations_fx.dart';
import 'celebrations_g4.dart';
import 'celebrations_sports.dart';
import 'celebrations_cats.dart';

export 'celebration_context.dart';
export 'celebrations_fx.dart' show fxThemeIds;

/// Tüm imza kutlamaları (tema id -> çizim). Yeni giriş g1..g4 dosyalarına eklenir.
final Map<String, SignatureCelebration> signatureCelebrations = {
  ...g1Celebrations,
  ...g2Celebrations,
  ...g3Celebrations,
  ...g4Celebrations,
  ...sportsCelebrations,
  ...catsCelebrations,
  ...fxCelebrations,
};

/// İsteğe bağlı kapak hareketleri (tema id -> poz).
final Map<String, CapPoseFn> signatureCapPoses = {
  ...g1CapPoses,
  ...g2CapPoses,
  ...g3CapPoses,
  ...g4CapPoses,
  ...sportsCapPoses,
  ...catsCapPoses,
  ...fxCapPoses,
};

/// Döngü evresinde (hedef aşıldığı sürece) giriş yerine çizilen isteğe bağlı
/// imza kutlamaları (tema id -> çizim). Yoksa imzanın orta bölümü döngülenir.
/// Bağlamda `ctx.looping`, `ctx.loop` (0..1), `ctx.loopCount`, `ctx.intensity`.
final Map<String, SignatureCelebration> signatureLoops = {
  ...g1Loops,
  ...g2Loops,
  ...g3Loops,
  ...g4Loops,
  ...sportsLoops,
  ...catsLoops,
  ...fxLoops,
};

/// Döngü evresi için isteğe bağlı kapak pozları (yoksa [signatureCapPoses]
/// kullanılır, döngü eşlemesiyle).
final Map<String, CapPoseFn> signatureLoopPoses = {
  ...g1LoopPoses,
  ...g2LoopPoses,
  ...g3LoopPoses,
  ...g4LoopPoses,
  ...sportsLoopPoses,
  ...catsLoopPoses,
  ...fxLoopPoses,
};

/// [painter] için (t'ye göre) kapak pozu; kayıtlı poz yoksa ya da hareket
/// azaltılmışsa [CapPose.identity].
CapPose resolveCapPose(CelebrationPainter painter) {
  final id = painter.theme.id;
  final fn =
      (painter.looping ? signatureLoopPoses[id] : null) ??
      signatureCapPoses[id];
  if (fn == null || painter.reduceMotion) return CapPose.identity;
  final pose = fn(CelebrationContext(painter: painter, level: painter.level));
  final l = painter.loop;
  if (l == null) return pose;
  // Tur başı/sonunda kapak yumuşakça normale döner (sıçrama olmaz).
  final f = CelebrationPainter.loopFade(l);
  if (f >= 1) return pose;
  return CapPose(
    dx: pose.dx * f,
    dy: pose.dy * f,
    rotation: pose.rotation * f,
    scale: 1 + (pose.scale - 1) * f,
  );
}

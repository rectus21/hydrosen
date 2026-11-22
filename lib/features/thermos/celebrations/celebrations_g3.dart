import 'celebration_context.dart';
import 'celebrations_g3_land.dart';
import 'celebrations_g3_loops.dart';
import 'celebrations_g3_loops_sea.dart';
import 'celebrations_g3_sea.dart';

// TEMA IMZA KUTLAMALARI - GRUP 3 (vahsi, orman ve deniz)
//
// Cizimler celebrations_g3_land.dart (kara hayvanlari) ve
// celebrations_g3_sea.dart (kutup/deniz) dosyalarinda, ortak yardimcilar
// celebrations_g3_kit.dart icindedir. Konumlar kapak cizimlerinin ham
// koordinatlarindan ctx.capPt ile alinir. Pozlar reduceMotion'da cagrilmaz.

const Map<String, SignatureCelebration> g3Celebrations = {
  'aslan': aslan,
  'fil': fil,
  'maymun': maymun,
  'geyik': geyik,
  'rakun': rakun,
  'kirpi': kirpi,
  'sincap': sincap,
  'baykus': baykus,
  'penguen': penguen,
  'fok': fok,
  'susamuru': susamuru,
  'balina': balina,
  'okyanus': okyanus,
  'ahtapot': ahtapot,
};

const Map<String, CapPoseFn> g3CapPoses = {
  'aslan': aslanPose,
  'fil': filPose,
  'maymun': maymunPose,
  'rakun': rakunPose,
  'kirpi': kirpiPose,
  'sincap': sincapPose,
  'baykus': baykusPose,
  'penguen': penguenPose,
  'fok': fokPose,
  'susamuru': samuruPose,
  'balina': balinaPose,
  'okyanus': okyanusPose,
  'ahtapot': ahtapotPose,
};

/// Döngü evresi (hedef aşıldığı sürece) için isteğe bağlı özel imzalar; boşsa
/// giriş imzasının orta bölümü döngülenir. Bkz. celebration_registry.dart.
final Map<String, SignatureCelebration> g3Loops = {
  ...g3LandLoops,
  ...g3SeaLoops,
};

/// Döngü evresi için isteğe bağlı kapak pozları (boşsa giriş pozu döngülenir).
final Map<String, CapPoseFn> g3LoopPoses = {
  ...g3LandLoopPoses,
  ...g3SeaLoopPoses,
};

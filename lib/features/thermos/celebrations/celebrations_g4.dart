// ignore: unused_import
import 'package:flutter/rendering.dart';

import 'celebration_context.dart';

// TEMA IMZA KUTLAMASI NASIL EKLENIR (grup 4)
//
// 1. Asagidaki g4Celebrations haritasina tema id'siyle bir giris ekle:
//      'boga': _bogaSteam,
//    ve `void _bogaSteam(Canvas canvas, CelebrationContext ctx)` yaz.
// 2. Konumlar icin ctx capalarini kullan: ctx.capCenter, ctx.capTop,
//    ctx.capWidth, ctx.eyeLeft/eyeRight/eyeLine, ctx.nose, ctx.mouth,
//    ctx.glass, ctx.waterY. Temaya ozgu bir nokta gerekiyorsa ctx.capPt(hamX,
//    hamY) ile kapak cizimindeki (themes/pack_*.dart) ham koordinati ver;
//    tombul kucultme ve kapak pozu otomatik uygulanir.
// 3. Sure ~2,6 sn: ctx.t (0..1) ve ctx.elapsed (sn) ile ilerle. Yardimcilar:
//    CelebrationContext.easeOut/easeInOut/pulse/lerp, ctx.span(a, b),
//    ctx.rand(i, salt), ctx.paintOf(hex, op) (ctx.alpha zarfi uygulanir),
//    ctx.solid, ctx.star, ctx.kind(canvas, CelebrationKind.x, renkler).
// 4. Hem tombul hem ince termosta iyi gorunmeli (ctx.chubby); kart disina
//    tasan cizim kirpilir. Kutlama kapagin USTUNDE cizilir.
// 5. ctx.reduceMotion true ise hareket yok: tek, duragan, temsili bir kare
//    ciz (t sabit 0.5 gelir; zamana bagli titresim/kayma kullanma).
// 6. Istersen kapaga ziplama/sallanma ekle: g4CapPoses haritasina ayni id ile
//    `CapPose Function(CelebrationContext)` ver (reduceMotion'da cagrilmaz).
// 7. test/celebrations_test.dart haritalari otomatik dolasir (iki sekil,
//    t=0..1, reduceMotion); ayrica test gerekmez.

const Map<String, SignatureCelebration> g4Celebrations = {};

const Map<String, CapPoseFn> g4CapPoses = {};

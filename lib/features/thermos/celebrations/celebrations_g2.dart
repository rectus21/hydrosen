import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../thermos_painter.dart';
import 'celebration_context.dart';

// TEMA IMZA KUTLAMASI NASIL EKLENIR (grup 2)
//
// 1. Asagidaki g2Celebrations haritasina tema id'siyle bir giris ekle:
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
// 6. Istersen kapaga ziplama/sallanma ekle: g2CapPoses haritasina ayni id ile
//    `CapPose Function(CelebrationContext)` ver (reduceMotion'da cagrilmaz).
// 7. test/celebrations_test.dart haritalari otomatik dolasir (iki sekil,
//    t=0..1, reduceMotion); ayrica test gerekmez.

const Map<String, SignatureCelebration> g2Celebrations = {
  'boga': _bogaSteam,
};

const Map<String, CapPoseFn> g2CapPoses = {
  'boga': _bogaShake,
};

// --- Boga: burun deliklerinden buhar ---------------------------------------

/// Boga kapaginin burun delikleri, ham kapak koordinatinda (tombul, ince).
const _bogaNostrilsChubby = [Offset(322, 160), Offset(358, 160)];
const _bogaNostrilsSlim = [Offset(329, 143), Offset(351, 143)];

/// Kafa sallama: hizli yatay-donus titresimi, sona dogru sonumlenir.
CapPose _bogaShake(CelebrationContext ctx) {
  final t = ctx.t;
  final env = CelebrationContext.pulse(CelebrationContext.easeOut(t * 1.1)) *
      (1 - t * 0.5);
  final s = math.sin(t * math.pi * 2 * 6);
  return CapPose(rotation: s * 0.07 * env, dx: s * 2.2 * env);
}

void _bogaSteam(Canvas canvas, CelebrationContext ctx) {
  final nostrils = ctx.chubby ? _bogaNostrilsChubby : _bogaNostrilsSlim;
  final k = ctx.chubby ? chubbyCapScale : 1.0;
  const puffs = 5;
  for (var side = 0; side < 2; side++) {
    final base = ctx.capPt(nostrils[side].dx, nostrils[side].dy);
    final dir = side == 0 ? -1.0 : 1.0;
    for (var i = 0; i < puffs; i++) {
      // Her buhar topu kendi gecikmesiyle baslar; hareketsizde sabit kare.
      final delay = (i / puffs) * 0.55 + side * 0.04;
      final p = ctx.reduceMotion
          ? (i + 1) / (puffs + 1) * 0.9
          : ((ctx.t - delay) / 0.4).clamp(0.0, 1.0);
      if (p <= 0 || p >= 1) continue;
      final e = CelebrationContext.easeOut(p);
      final r = (5 + 17 * e) * (ctx.chubby ? 1.0 : 0.85) * (0.8 + k * 0.2);
      final c = base +
          Offset(
            dir * (6 + 26 * e) + math.sin(p * 5 + i + side) * 5,
            -4 - 78 * e,
          );
      final fade = math.sin(p * math.pi).clamp(0.0, 1.0);
      final o = 0.75 * fade;
      canvas.drawCircle(c, r, ctx.solid(0xFFFFFF, o));
      canvas.drawCircle(
        c + Offset(-r * 0.45, r * 0.25),
        r * 0.6,
        ctx.solid(0xF3F6F8, o * 0.9),
      );
      canvas.drawCircle(
        c + Offset(r * 0.5, r * 0.2),
        r * 0.55,
        ctx.solid(0xE6EDF2, o * 0.8),
      );
    }
  }
}

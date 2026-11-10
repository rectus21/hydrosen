import 'dart:math' as math;

/// Termostaki suyun çalkalanması: sensörsüz, olaylarla sürülen iki sönümlü yay.
///
/// - [tilt]: yüzeyin eğim açısı (radyan). Pozitif: sağ taraf yüksek.
/// - [wave]: ortası inip kalkan duran dalganın genliği (tasarım birimi).
///
/// Saf Dart'tır (Flutter'a bağlı değil): [step] ile zamanda ilerletilir, aynı
/// girdilerle her zaman aynı sonucu verir. Su ekleme, silme, dokunma ve
/// kutlama birer itki ([impulse]) verir; sürükleme [hold] ile yüzeyi parmağın
/// yönüne eğer, [release] ile bırakılınca su sönümlenerek durulur (~2 sn).
class SloshModel {
  /// Eğim yayının doğal frekansı (rad/sn, ~1,2 Hz) ve sönüm oranı.
  static const tiltOmega = 2 * math.pi * 1.2;
  static const tiltDamping = 0.2;

  /// Tutulurken (sürükleme) eğim parmağı yumuşakça izler.
  static const holdDamping = 0.7;

  /// Dalga yayının doğal frekansı (~1,8 Hz) ve sönüm oranı.
  static const waveOmega = 2 * math.pi * 1.8;
  static const waveDamping = 0.15;

  /// Sınırlar: yüzey en çok ~17° eğilir, dalga en çok 12 birim olur.
  static const maxTilt = 0.3;
  static const maxWave = 12.0;
  static const maxTiltVelocity = 4.0;
  static const maxWaveVelocity = 140.0;

  /// Bu eşiklerin altında su durgun sayılır ve [step] hiçbir şey yapmaz.
  static const _restTilt = 0.003;
  static const _restTiltVelocity = 0.02;
  static const _restWave = 0.05;
  static const _restWaveVelocity = 0.3;

  double tilt = 0;
  double tiltVelocity = 0;
  double wave = 0;
  double waveVelocity = 0;

  double? _anchor;

  /// Sürükleme sürüyor mu?
  bool get isHeld => _anchor != null;

  /// Su durgun mu (tutulmuyor ve tüm hareket eşiklerin altında)?
  bool get isAtRest =>
      !isHeld &&
      tilt.abs() < _restTilt &&
      tiltVelocity.abs() < _restTiltVelocity &&
      wave.abs() < _restWave &&
      waveVelocity.abs() < _restWaveVelocity;

  /// Yüzeydeki küçük dalgacıkları büyütmek için 0..1 arası çalkantı ölçüsü.
  double get agitation =>
      math.min(1.0, tilt.abs() / maxTilt + wave.abs() / maxWave);

  /// Ani bir itki: hızlara eklenir (sınırlı).
  void impulse({double tiltVelocity = 0, double waveVelocity = 0}) {
    this.tiltVelocity = _clamp(
      this.tiltVelocity + tiltVelocity,
      maxTiltVelocity,
    );
    this.waveVelocity = _clamp(
      this.waveVelocity + waveVelocity,
      maxWaveVelocity,
    );
  }

  /// Yüzeyi [targetTilt] eğimine doğru çeker (sürükleme sırasında).
  void hold(double targetTilt) => _anchor = _clamp(targetTilt, maxTilt);

  /// Sürüklemeyi bırakır; [flingVelocity] (rad/sn) eğim hızına eklenir.
  void release({double flingVelocity = 0}) {
    if (!isHeld) return;
    _anchor = null;
    impulse(
      tiltVelocity: flingVelocity,
      waveVelocity: flingVelocity.abs() * 12 + tilt.abs() * 60,
    );
  }

  /// Her şeyi durgun hâle getirir.
  void reset() {
    tilt = tiltVelocity = wave = waveVelocity = 0;
    _anchor = null;
  }

  /// Modeli [dt] saniye ilerletir (yarı örtük Euler, küçük alt adımlarla).
  void step(double dt) {
    if (dt <= 0 || isAtRest) return;
    var left = math.min(dt, 0.1);
    while (left > 0) {
      final h = math.min(left, 1 / 240);
      left -= h;
      final anchor = _anchor ?? 0;
      final zt = isHeld ? holdDamping : tiltDamping;
      tiltVelocity +=
          (-tiltOmega * tiltOmega * (tilt - anchor) -
              2 * zt * tiltOmega * tiltVelocity) *
          h;
      tilt += tiltVelocity * h;
      if (tilt.abs() > maxTilt) {
        tilt = _clamp(tilt, maxTilt);
        if (tilt * tiltVelocity > 0) tiltVelocity = -tiltVelocity * 0.3;
      }

      waveVelocity +=
          (-waveOmega * waveOmega * wave -
              2 * waveDamping * waveOmega * waveVelocity) *
          h;
      wave += waveVelocity * h;
      if (wave.abs() > maxWave) {
        wave = _clamp(wave, maxWave);
        if (wave * waveVelocity > 0) waveVelocity = -waveVelocity * 0.3;
      }
    }
    if (isAtRest) reset();
  }

  static double _clamp(double v, double limit) => v.clamp(-limit, limit);
}

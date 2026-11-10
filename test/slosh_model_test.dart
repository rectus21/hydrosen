import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/features/thermos/slosh_model.dart';

/// [seconds] boyunca 60 fps adımlarla ilerletir; görülen en büyük eğim ve dalga.
({double tilt, double wave}) run(SloshModel m, double seconds) {
  var maxTilt = 0.0, maxWave = 0.0;
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    m.step(1 / 60);
    if (m.tilt.abs() > maxTilt) maxTilt = m.tilt.abs();
    if (m.wave.abs() > maxWave) maxWave = m.wave.abs();
  }
  return (tilt: maxTilt, wave: maxWave);
}

void main() {
  test('başlangıçta durgun, step hiçbir şey değiştirmez', () {
    final m = SloshModel();
    expect(m.isAtRest, isTrue);
    m.step(1);
    expect(m.tilt, 0);
    expect(m.wave, 0);
    expect(m.agitation, 0);
  });

  test('itki çalkalar, ~2,5 sn içinde belirgin söner, sonunda durulur', () {
    final m = SloshModel()..impulse(tiltVelocity: 1.0, waveVelocity: -60);
    expect(m.isAtRest, isFalse);
    final first = run(m, 0.5);
    expect(first.tilt, greaterThan(0.05));
    expect(first.wave, greaterThan(2));

    run(m, 2.0); // 0,5..2,5 sn
    // 2,5 sn'de genlik başlangıcın küçük bir kesrine iner.
    final tail = run(m, 0.5); // 2,5..3 sn
    expect(tail.tilt, lessThan(first.tilt * 0.15));
    expect(tail.wave, lessThan(first.wave * 0.15));

    run(m, 3);
    expect(m.isAtRest, isTrue);
    expect(m.tilt, 0);
    expect(m.wave, 0);
  });

  test('eğim yön değiştirir (salınır), yalnız sönmez', () {
    final m = SloshModel()..impulse(tiltVelocity: 1.0);
    var sawNegative = false;
    for (var i = 0; i < 120; i++) {
      m.step(1 / 60);
      if (m.tilt < -0.01) sawNegative = true;
    }
    expect(sawNegative, isTrue);
  });

  test('çok büyük ve üst üste itkilerde eğim ve dalga sınırlı kalır', () {
    final m = SloshModel();
    var maxTilt = 0.0, maxWave = 0.0;
    for (var i = 0; i < 300; i++) {
      if (i % 5 == 0) m.impulse(tiltVelocity: 1e6, waveVelocity: -1e6);
      m.step(1 / 60);
      maxTilt = maxTilt > m.tilt.abs() ? maxTilt : m.tilt.abs();
      maxWave = maxWave > m.wave.abs() ? maxWave : m.wave.abs();
      expect(m.tilt.isFinite && m.wave.isFinite, isTrue);
    }
    expect(maxTilt, lessThanOrEqualTo(SloshModel.maxTilt));
    expect(maxWave, lessThanOrEqualTo(SloshModel.maxWave));
    expect(m.agitation, inInclusiveRange(0, 1));
  });

  test('deterministik: aynı girdiler aynı sonucu verir', () {
    SloshModel play() {
      final m = SloshModel()..impulse(tiltVelocity: 0.7, waveVelocity: 40);
      for (var i = 0; i < 50; i++) {
        m.step(i.isEven ? 1 / 60 : 1 / 30);
        if (i == 20) m.impulse(tiltVelocity: -0.4);
      }
      return m;
    }

    final a = play(), b = play();
    expect(a.tilt, b.tilt);
    expect(a.wave, b.wave);
    expect(a.tiltVelocity, b.tiltVelocity);
  });

  test('tutma eğimi hedefe çeker, bırakınca durulur', () {
    final m = SloshModel()..hold(0.2);
    expect(m.isHeld, isTrue);
    run(m, 1.5);
    expect(m.tilt, closeTo(0.2, 0.02));
    expect(m.isAtRest, isFalse); // tutulurken durgun sayılmaz

    m.hold(-5); // sınır dışı hedef kırpılır
    run(m, 1.5);
    expect(m.tilt, closeTo(-SloshModel.maxTilt, 0.02));

    m.release(flingVelocity: 2);
    expect(m.isHeld, isFalse);
    final after = run(m, 0.6);
    expect(after.wave, greaterThan(1)); // bırakınca su çalkalanır
    run(m, 5);
    expect(m.isAtRest, isTrue);
  });

  test('geçersiz adımlar yok sayılır; reset durgunlaştırır', () {
    final m = SloshModel()..impulse(tiltVelocity: 1);
    m.step(0);
    m.step(-1);
    expect(m.tilt, 0);
    m.step(10); // tek seferde en çok 0,1 sn ilerler
    expect(m.tilt.isFinite, isTrue);
    m.reset();
    expect(m.isAtRest, isTrue);
  });
}

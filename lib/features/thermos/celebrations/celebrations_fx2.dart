part of 'celebrations_fx.dart';

// SPRITE TABANLI KUTLAMALAR (2): baykus (okuma), civciv (konser), rakun
// (elma yıkama), avokado (disko), kamp (gece kamp ateşi), okyanus (köpekbalığı).
// Hem giriş hem döngü aynı çizimi kullanır: döngüde ve hareket azaltılmışken
// tüm sahneler "tam görünür" durumdadır, giriş sırasında pencereler açılır.
// Konumlar kapak görselinin (u, v) noktalarından ve camdan türer.

const _loopSecs = 3.2;

/// Saniye cinsinden sahne zamanı (hareket azaltılmışken 0 = donuk kare).
double _sec(CelebrationContext c) {
  if (c.reduceMotion) return 0;
  return c.looping ? c.loop * _loopSecs : c.t * 2.6;
}

/// Döngü başına [n] tam tur: döngüde kesintisiz, girişte aynı hızda.
double _cyc(CelebrationContext c, double n) => _sec(c) / _loopSecs * n;
double _phs(CelebrationContext c, double n) => _cyc(c, n) * _tau;

/// Girişte [a]..[b] penceresinde 0..1; döngüde ve hareket azaltılmışken 1.
double _pr(CelebrationContext c, double a, double b) =>
    (c.looping || c.reduceMotion) ? 1.0 : _sp(c.t, a, b);

double _fl(double x) => x - x.floorToDouble();

Color _col(int hex, [double op = 1]) =>
    Color(0xFF000000 | hex).withValues(alpha: op.clamp(0.0, 1.0));

/// Dört uçlu parıltı.
void _glint(Canvas cv, Offset p, double r, int hex, double op, double a) {
  final o = (op * a).clamp(0.0, 1.0);
  if (o <= 0.02 || r <= 0.3) return;
  final k = r * 0.14;
  final path = Path()
    ..moveTo(0, -r)
    ..quadraticBezierTo(k, -k, r, 0)
    ..quadraticBezierTo(k, k, 0, r)
    ..quadraticBezierTo(-k, k, -r, 0)
    ..quadraticBezierTo(-k, -k, 0, -r)
    ..close();
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.drawPath(path, Paint()..color = _col(hex, o));
  cv.drawCircle(Offset.zero, r * 0.18, Paint()..color = _col(0xFFFFFF, o));
  cv.restore();
}

/// Yumuşak dairesel ışık (merkez [op], kenar 0).
void _soft(
  Canvas cv,
  Offset p,
  double r,
  int hex,
  double op, {
  BlendMode blend = BlendMode.srcOver,
}) {
  if (op <= 0.01 || r <= 1) return;
  cv.drawCircle(
    p,
    r,
    Paint()
      ..blendMode = blend
      ..shader = RadialGradient(
        colors: [_col(hex, op), _col(hex, op * 0.45), _col(hex, 0)],
        stops: const [0, 0.55, 1],
      ).createShader(Rect.fromCircle(center: p, radius: r)),
  );
}

final _glyphCache = <String, TextPainter>{};

void _letter(
  Canvas cv,
  String ch,
  Offset p,
  double size,
  int hex,
  double op,
  double rot,
) {
  final bucket = (op.clamp(0.0, 1.0) * 8).round();
  if (bucket <= 0) return;
  final tp = _glyphCache.putIfAbsent('$ch|$hex|$bucket', () {
    return TextPainter(
      text: TextSpan(
        text: ch,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: _col(hex, bucket / 8),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  });
  cv.save();
  cv.translate(p.dx, p.dy);
  cv.rotate(rot);
  final s = size / 24;
  cv.scale(s);
  tp.paint(cv, Offset(-tp.width / 2, -tp.height / 2));
  cv.restore();
}

// ================================================================ BAYKUŞ ===

CapPose _baykusPose(CelebrationContext c) {
  final k = _pr(c, 0.3, 0.42);
  final w = _phs(c, 3);
  final nod = (0.5 + 0.5 * math.sin(w)) * k;
  return CapPose(dy: 3.5 * nod, rotation: 0.03 * math.sin(w * 0.5) * k);
}

void _baykus(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  final w = c.capWidth;
  final bk = _pr(c, 0.02, 0.2);
  final open = _pr(c, 0.16, 0.3);
  final bw = 0.64 * w;
  final base = Offset(
    340 + c.pose.dx * 0.5,
    c.glass.top + 0.12 * w + c.pose.dy * 0.6,
  );
  final lift = (1 - _back(bk)) * 60;
  final tilt = math.sin(_phs(c, 2)) * 0.035 * open;
  final bookH = bw * 149 / 243;

  cv.save();
  cv.translate(base.dx, base.dy + lift);
  cv.rotate(tilt);
  final closedOp = bk * (1 - open);
  if (closedOp > 0.02) {
    f.spr('baykus_book_closed', Offset.zero, bw * 0.8, op: closedOp);
  }
  if (open > 0.02) {
    f.spr(
      'baykus_book_open',
      Offset.zero,
      bw * (0.7 + 0.3 * _back(open)),
      op: open * bk,
    );
  }
  // Sayfa çevirme.
  if (!c.reduceMotion && open >= 1) {
    final x = c.looping ? c.loop : c.t;
    final windows = c.looping
        ? const [
            [0.1, 0.28],
            [0.6, 0.78],
          ]
        : const [
            [0.36, 0.5],
            [0.56, 0.7],
          ];
    for (final win in windows) {
      final p = _sp(x, win[0], win[1]);
      if (p <= 0 || p >= 1) continue;
      final th = p * math.pi;
      final hw = 0.455 * bw;
      final top = -bookH / 2 + 0.07 * bookH;
      final bot = -bookH / 2 + 0.74 * bookH;
      final edge = math.cos(th) * hw;
      final up = math.sin(th) * 0.1 * bookH;
      final page = Path()
        ..moveTo(0, top + 0.05 * bookH)
        ..quadraticBezierTo(edge * 0.5, top - up - 2, edge, top - up * 0.6)
        ..lineTo(edge, bot - up * 0.3)
        ..quadraticBezierTo(edge * 0.5, bot + 3, 0, bot + 0.08 * bookH)
        ..close();
      cv.drawPath(page, Paint()..color = _col(0xFFF3D8, 0.96 * f.a));
      cv.drawPath(
        page,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = _col(0xC9A875, 0.9 * f.a),
      );
    }
  }
  cv.restore();

  // Kitaptan yükselen harf ve parıltılar (yüzün iki yanından).
  for (var i = 0; i < 6; i++) {
    final gate = _pr(c, 0.3 + 0.04 * i, 0.36 + 0.04 * i);
    if (gate <= 0) continue;
    final r = c.rand(i, 41);
    final k = _fl(_cyc(c, 1) + i / 6.0);
    final side = i.isEven ? -1.0 : 1.0;
    final x = 340 + side * (0.58 * w + 12 * r + math.sin(k * 5 + i) * 5);
    final y = math.max(base.dy - 20 - 120 * k * (0.8 + 0.4 * r), 84.0);
    final op = _life(k, 0.12, 0.3) * gate;
    if (i % 3 == 0) {
      _letter(
        cv,
        const ['A', 'B', 'a'][i ~/ 3],
        Offset(x, y),
        17 + 4 * r,
        const [0xE0623A, 0x3D7BD9, 0x2FA36B][i ~/ 3],
        op * f.a,
        side * 0.25,
      );
    } else {
      _glint(cv, Offset(x, y), 8 + 4 * r, 0xFFD34D, op, f.a);
    }
  }
}

// ================================================================ CİVCİV ===

CapPose _civcivPose(CelebrationContext c) {
  final k = _pr(c, 0.1, 0.25);
  final w = _phs(c, 6);
  return CapPose(
    dy: -3 * math.sin(w).abs() * k,
    rotation: 0.04 * math.sin(w * 0.5) * k,
  );
}

void _civciv(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  final w = c.capWidth;
  final beat = _phs(c, 6);

  // Mini civcivler iki yanda zeminde (cam kenarlarının dışında).
  final floorY = c.glass.bottom + 14;
  final lx = c.glass.left - 58, rx = c.glass.right + 58;
  for (var i = 0; i < 2; i++) {
    final left = i == 0;
    final k = _pr(c, 0.06 + 0.1 * i, 0.22 + 0.1 * i);
    if (k <= 0) continue;
    final x = left ? lx : rx;
    final ph = beat + i * 1.7;
    final hop = math.sin(ph).abs() * 6 * k;
    // Ayak ışığı (sahne).
    _soft(cv, Offset(x, floorY - 2), 40, 0xFFE27A, 0.35 * k * f.a);
    f.spr(
      left ? 'civciv_mini_mic_r' : 'civciv_mini_mic_l',
      Offset(x, floorY - hop),
      96 * _back(k),
      at: Alignment.bottomCenter,
      rot: math.sin(ph * 0.5) * 0.07,
      op: k,
    );
  }

  // Ana civcivin mikrofonu gagasının yanında.
  final beak = c.capImagePt(0.485, 0.627);
  final mk = _pr(c, 0.1, 0.24);
  final head = beak + Offset(0.17 * w, 0.07 * w);
  final mw = 0.21 * w;
  f.spr(
    'civciv_mic',
    head + Offset(-0.07 * mw, 0.27 * mw * 226 / 172),
    mw * (0.5 + 0.5 * _back(mk)),
    rot: -0.28 + math.sin(beat * 0.5) * 0.05,
    op: mk,
  );

  // Notalar: ana civcivden ve mini civcivlerden yükselir.
  for (var i = 0; i < 7; i++) {
    final gate = _pr(c, 0.22 + 0.05 * i, 0.3 + 0.05 * i);
    if (gate <= 0) continue;
    final r = c.rand(i, 52);
    final k = _fl(_cyc(c, 1) + i / 7.0);
    Offset p;
    if (i < 3) {
      p = head + Offset(20 + 40 * r * k + math.sin(k * 6 + i) * 8, -8 - 70 * k);
      p = Offset(p.dx, math.max(p.dy, 84.0));
    } else {
      final left = i.isEven;
      final x0 = left ? lx : rx;
      p = Offset(
        x0 + (left ? -1 : 1) * (6 + 20 * k) + math.sin(k * 6 + i) * 8,
        floorY - 92 - 80 * k,
      );
    }
    f.spr(
      'avokado_note',
      p,
      20 + 8 * r,
      rot: math.sin(k * 5 + i) * 0.35,
      op: _life(k, 0.15, 0.3) * gate,
    );
  }
}

// ================================================================= RAKUN ===

void _rakun(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  final w = c.capWidth;
  final tubW = 0.8 * w;
  final tubH = tubW * 159 / 241;
  final tubX = 346.0;
  final tubY = c.glass.top + 0.25 * w; // merkez
  final tubTop = tubY - tubH / 2;
  final water = Offset(tubX, tubTop + 0.3 * tubH);
  final tk = _pr(c, 0.02, 0.18);
  final lift = (1 - _back(tk)) * 70;

  // Elma: tekneye iner, yarısı suya batar, sonra ıslak hâliyle yukarı çıkar.
  final dipK = _pr(c, 0.2, 0.42);
  final upK = _pr(c, 0.62, 0.84);
  final aw = 0.28 * w;
  final dipPos = Offset(tubX, tubTop + 0.3 * tubH);
  final startPos = Offset(tubX + 4, tubTop - 0.5 * w);
  final liftedPos = Offset(c.glass.right + 8, tubTop - 0.15 * w);
  final bob = math.sin(_phs(c, 3)) * 2.5;

  cv.save();
  cv.translate(0, lift);
  f.spr(
    'rakun_tub',
    Offset(tubX, tubY),
    tubW * (0.6 + 0.4 * _back(tk)),
    op: tk,
  );
  cv.restore();

  if (tk >= 1) {
    if (upK < 1) {
      // Su içindeki elma (tekne ağzında kırpılır).
      final pos =
          Offset.lerp(
            Offset.lerp(startPos, dipPos, _eo(dipK)),
            dipPos + Offset(0, -0.18 * tubH),
            _eo(upK * 2),
          )! +
          Offset(0, upK < 0.01 ? bob : 0);
      if (dipK > 0 && upK < 0.5) {
        cv.save();
        cv.clipRect(Rect.fromLTRB(0, 0, 800, tubTop + 0.4 * tubH));
        f.spr('rakun_apple', pos, aw, op: _sp(dipK, 0, 0.2) * (1 - upK * 2));
        f.spr(
          'rakun_apple_wet',
          pos,
          aw,
          op: _sp(upK, 0, 0.5) * (1 - upK * 2).clamp(0.0, 1.0),
        );
        cv.restore();
      }
      if (upK > 0.35) {
        final k = _sp(upK, 0.35, 1);
        final p =
            Offset.lerp(dipPos, liftedPos, _eo(k))! +
            Offset(0, -math.sin(k * math.pi) * 14);
        f.spr(
          'rakun_apple_wet',
          p,
          aw * (0.85 + 0.15 * _back(k)),
          rot: (1 - k) * 0.4,
          op: _sp(k, 0, 0.3),
        );
      }
    } else {
      f.spr(
        'rakun_apple_wet',
        liftedPos + Offset(0, bob),
        aw,
        rot: math.sin(_phs(c, 3) + 1) * 0.06,
      );
    }
  }

  // Sıçrama: elma suya girerken damlalar ve halka.
  final sp = c.looping ? 0.0 : _sp(c.t, 0.34, 0.5);
  if (sp > 0 && sp < 1) {
    for (var i = 0; i < 9; i++) {
      final ang = -math.pi * (0.1 + 0.8 * i / 8);
      final d = 10 + 44 * _eo(sp) * (0.7 + 0.5 * c.rand(i, 61));
      final p =
          water +
          Offset(math.cos(ang) * d * 1.2, math.sin(ang) * d + 26 * sp * sp);
      cv.drawCircle(
        p,
        3.2 * (1 - sp * 0.5),
        Paint()..color = _col(0x7CCBFF, (1 - sp) * f.a),
      );
    }
  }
  final ring = c.looping
      ? _fl(_cyc(c, 1) + 0.2)
      : (sp > 0 ? sp : (c.reduceMotion ? 0.0 : -1.0));
  if (ring >= 0 && ring < 1 && tk >= 1) {
    cv.drawOval(
      Rect.fromCenter(
        center: water,
        width: tubW * (0.2 + 0.3 * ring),
        height: tubH * (0.07 + 0.1 * ring),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _col(0xFFFFFF, (1 - ring) * 0.8 * f.a),
    );
  }

  // Sabun köpükleri tekneden yükselir, kenarlara savrulup patlar.
  if (tk >= 1) {
    for (var i = 0; i < 8; i++) {
      final gate = _pr(c, 0.4 + 0.035 * i, 0.46 + 0.035 * i);
      if (gate <= 0) continue;
      final r = c.rand(i, 71);
      final k = _fl(_cyc(c, 1) + i / 8.0);
      final side = i.isEven ? -1.0 : 1.0;
      final x = tubX + side * (14 + 90 * k + 14 * r) + math.sin(k * 5 + i) * 7;
      final y = math.max(
        water.dy - 6 - (water.dy - 96) * math.pow(k, 0.9).toDouble(),
        90.0,
      );
      final size = 14 + 20 * r;
      final pop = _sp(k, 0.86, 1.0);
      f.spr(
        'rakun_bubble',
        Offset(x, y),
        size * (1 + 0.35 * pop),
        op: 0.72 * (1 - pop) * _sp(k, 0, 0.1) * gate,
      );
      if (pop > 0.05 && pop < 0.9) {
        cv.drawCircle(
          Offset(x, y),
          size * (0.6 + 0.6 * pop),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = _col(0xFFFFFF, (1 - pop) * 0.7 * f.a * gate),
        );
      }
    }
  }

  // Islak elmadan damlalar ve parıltı.
  if (upK >= 1 || c.reduceMotion) {
    final ap = liftedPos + Offset(0, bob);
    for (var i = 0; i < 2; i++) {
      final k = _fl(_cyc(c, 2) + i * 0.5);
      cv.drawCircle(
        Offset(ap.dx - 6 + 12 * i, ap.dy + aw * 0.42 + 40 * k),
        2.4,
        Paint()..color = _col(0x7CCBFF, _life(k, 0.1, 0.4) * 0.9 * f.a),
      );
    }
    final gl = _fl(_cyc(c, 1) + 0.1);
    _glint(
      cv,
      ap + Offset(-aw * 0.28, -aw * 0.18),
      5 + 9 * _hump(gl * 2),
      0xFFFFFF,
      gl < 0.5 ? 1 : 0,
      f.a,
    );
    _glint(
      cv,
      ap + Offset(aw * 0.45, -aw * 0.5),
      4 + 7 * _hump(gl),
      0xFFE680,
      0.9,
      f.a,
    );
  }
}

// ============================================================== AVOKADO ===

CapPose _avokadoPose(CelebrationContext c) {
  final k = _pr(c, 0.18, 0.32);
  final w = _phs(c, 4);
  return CapPose(
    dx: math.sin(w) * 5 * k,
    dy: -math.sin(w * 2).abs() * 1.5 * k,
    rotation: math.sin(w) * 0.06 * k,
  );
}

const _discoSpots = [
  0xFF5FA8,
  0x4FD8FF,
  0xFFE04F,
  0xA66BFF,
  0x6BFF9A,
  0xFF9A4F,
];

void _avokadoDisco(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);

  final ph = _phs(c, 1);

  // Renkli ışık lekeleri: yumuşak, düşük opaklıkta süzülür.
  final lk = _pr(c, 0.2, 0.4);
  for (var i = 0; i < _discoSpots.length; i++) {
    final a = ph + i * math.pi / 3 * 2;
    final x = 340 + (110 + 20 * (i % 2)) * math.sin(a + i);
    final y =
        215 + 120 * math.sin(a * 1.0 + i * 1.9) * (i.isEven ? 1 : -1) * 0.9;
    _soft(
      cv,
      Offset(x, math.max(y, 110)),
      58 + 12 * (i % 3),
      _discoSpots[i],
      0.55 * lk * f.a,
    );
  }

  // Topun saçtığı ışık huzmeleri (yumuşak, yavaş dönen).
  final bc = Offset(452, 76 + 34 + 46);
  if (lk > 0) {
    for (var i = 0; i < 4; i++) {
      final a = ph + i * math.pi / 2 + 0.4;
      final hex = _discoSpots[(i * 2) % _discoSpots.length];
      final p = Path()
        ..moveTo(bc.dx, bc.dy)
        ..lineTo(
          bc.dx + 260 * math.cos(a - 0.1),
          bc.dy + 260 * math.sin(a - 0.1),
        )
        ..lineTo(
          bc.dx + 260 * math.cos(a + 0.1),
          bc.dy + 260 * math.sin(a + 0.1),
        )
        ..close();
      cv.drawPath(
        p,
        Paint()
          ..shader = RadialGradient(
            colors: [_col(hex, 0.38 * lk * f.a), _col(hex, 0)],
          ).createShader(Rect.fromCircle(center: bc, radius: 260)),
      );
    }
  }

  // Disko topu ince ipte iner.
  final bw = 80.0;
  final bh = bw * 230 / 205;
  const ax = 452.0, ay = 76.0;
  final dk = _pr(c, 0.04, 0.3);

  final swing = math.sin(ph) * 0.06;
  cv.save();
  cv.translate(ax, ay);
  cv.rotate(swing);
  cv.translate(-ax, -ay);
  final ballTop = ay + 4 + 30 * _eo(dk);
  // İp.
  final stringTop = Offset(ax, ay - 2), stringEnd = Offset(ax, ballTop + 3);
  cv.drawLine(
    stringTop,
    stringEnd,
    Paint()
      ..strokeWidth = 3.6
      ..color = _col(0x4A4A66, 0.55 * f.a),
  );
  cv.drawLine(
    stringTop,
    stringEnd,
    Paint()
      ..strokeWidth = 1.8
      ..color = _col(0xFFFFFF, 0.95 * f.a),
  );
  cv.drawCircle(stringTop, 3, Paint()..color = _col(0x4A4A66, 0.8 * f.a));
  final center = Offset(ax, ballTop + bh * 0.5);
  f.spr('avokado_disco_ball', center, bw, op: _sp(dk, 0, 0.2));
  // Dönüş taklidi: topun üstünde kayan parlak bantlar (daire içinde kırpılı).
  final ballC = Offset(ax, ballTop + bh * 0.58);
  final br = bw * 0.47;
  if (dk > 0.5) {
    cv.save();
    cv.clipPath(Path()..addOval(Rect.fromCircle(center: ballC, radius: br)));
    for (var i = 0; i < 3; i++) {
      final x =
          ballC.dx -
          br +
          ((_cyc(c, 2) + i / 3.0) % 1.0) * 2 * br * 1.4 -
          br * 0.2;
      final p = Path()
        ..moveTo(x, ballC.dy - br)
        ..lineTo(x + 8, ballC.dy - br)
        ..lineTo(x - 6, ballC.dy + br)
        ..lineTo(x - 14, ballC.dy + br)
        ..close();
      cv.drawPath(p, Paint()..color = _col(0xFFFFFF, 0.28 * f.a));
    }
    cv.restore();
  }
  // Etraf parıltıları.
  for (var i = 0; i < 4; i++) {
    final g = _fl(_cyc(c, 2) + i * 0.25);
    final a = i * 1.7 + 0.6;
    final p = ballC + Offset(math.cos(a), math.sin(a)) * (br + 5 + 4 * i % 3);
    _glint(cv, p, 4 + 6 * _hump(g), 0xFFFFFF, dk > 0.5 ? _hump(g) : 0, f.a);
  }
  cv.restore();

  // Notalar kafanın solunda yükselir.
  for (var i = 0; i < 5; i++) {
    final gate = _pr(c, 0.3 + 0.05 * i, 0.38 + 0.05 * i);
    if (gate <= 0) continue;
    final r = c.rand(i, 83);
    final k = _fl(_cyc(c, 1) + i / 5.0);
    final left = i != 4;
    final x = left
        ? 200 + 55 * ((i * 0.37 + r) % 1.0) + math.sin(k * 6 + i) * 9
        : 470 + math.sin(k * 6) * 8;
    final y = left ? 235 - 125 * k : 330 - 100 * k;
    f.spr(
      'avokado_note',
      Offset(x, math.max(y, 90)),
      22 + 8 * r,
      rot: math.sin(k * 5 + i) * 0.35,
      op: _life(k, 0.15, 0.3) * gate,
    );
  }
}

// ================================================================== KAMP ===

void _kamp(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  final w = c.capWidth;
  final ph = _phs(c, 1);
  final fk = _pr(c, 0.04, 0.24);
  final glowK = _pr(c, 0.0, 0.3);
  final flick =
      0.5 +
      0.5 * math.sin(ph * 7 + 1.3) * 0.6 +
      0.5 * math.sin(ph * 11 + 0.4) * 0.4;

  // Fener parlar: kapağın arkasında sıcak ışık, sonra kapak yeniden çizilir.
  final lantern = c.capImagePt(0.5, 0.55);
  final pulse = 0.5 + 0.5 * math.sin(_phs(c, 2));
  _soft(cv, lantern, 1.05 * w, 0xFFB347, (0.5 + 0.12 * pulse) * glowK * f.a);
  _soft(cv, lantern, 0.6 * w, 0xFFD27A, 0.35 * glowK * f.a);
  c.drawCapOver(cv);
  _soft(
    cv,
    lantern,
    0.42 * w,
    0xFFE9A8,
    (0.22 + 0.1 * pulse) * glowK * f.a,
    blend: BlendMode.plus,
  );

  // Ateş sağ yanda zeminde.
  final fx = c.glass.right + 46;
  final fy = c.glass.bottom + 14;
  final fw = 100.0;
  final fh = fw * 243 / 198;
  final fire = Offset(fx, fy);
  _soft(
    cv,
    Offset(fx, fy - fh * 0.4),
    120,
    0xFF9A3C,
    (0.38 + 0.12 * flick) * fk * f.a,
  );
  final sy = 1 + 0.07 * (flick - 0.5), sx = 1 - 0.035 * (flick - 0.5);
  cv.save();
  cv.translate(fire.dx, fire.dy);
  cv.scale(sx * _back(fk), sy * _back(fk));
  cv.translate(-fire.dx, -fire.dy);
  f.spr('kamp_fire', fire, fw, at: Alignment.bottomCenter, op: fk);
  f.spr(
    'kamp_fire',
    fire,
    fw * 1.04,
    at: Alignment.bottomCenter,
    op: 0.22 * fk * flick,
    blend: BlendMode.plus,
  );
  cv.restore();

  // Dumanlar.
  final tip = Offset(fx, fy - fh * 0.9);
  for (var i = 0; i < 4; i++) {
    final k = _fl(_cyc(c, 1) + i / 4.0);
    final p = tip + Offset(math.sin(k * 4 + i * 2) * 12 + k * 8, -80 * k);
    cv.drawCircle(
      p,
      8 + 16 * k,
      Paint()..color = _col(0xBFC3E0, 0.2 * _life(k, 0.2, 0.6) * fk * f.a),
    );
  }

  // Közler: kodla çizilir, yükselip söner.
  for (var i = 0; i < 12; i++) {
    final r = c.rand(i, 91);
    final k = _fl(_cyc(c, 1.0 + (i % 3)) + r);
    final x = fx + (r - 0.5) * 36 + math.sin(k * 7 + i) * 12 * k;
    final y = fy - fh * 0.5 - 130 * k * (0.7 + 0.5 * c.rand(i, 92));
    if (y < 84) continue;
    final op = _life(k, 0.05, 0.6) * fk;
    final hex = i % 3 == 0 ? 0xFFE08A : 0xFF9A3C;
    final rad = 1.4 + 1.8 * c.rand(i, 93);
    _soft(cv, Offset(x, y), rad * 3.2, hex, 0.35 * op * f.a);
    cv.drawCircle(Offset(x, y), rad, Paint()..color = _col(hex, op * f.a));
  }

  // Kızartılan marshmallow: sopa camdan ateşe uzanır.
  final mk = _pr(c, 0.28, 0.5);
  if (mk > 0) {
    final mw = 82.0;
    // Sopa ateşin sağında zemine saplı, marshmallow alevlerin üstünde.
    final target = Offset(fx + 8, fy - fh * 0.62);
    final p = Offset.lerp(target + const Offset(26, -46), target, _eo(mk))!;
    cv.drawOval(
      Rect.fromCenter(center: Offset(fx + 56, fy + 4), width: 22, height: 6),
      Paint()..color = _col(0x0B0B1E, 0.45 * mk * f.a),
    );
    f.spr(
      'kamp_marshmallow',
      p + Offset(0, math.sin(ph * 2) * 1.6),
      mw,
      flip: true,
      op: mk,
    );
    final g = _fl(_cyc(c, 1) + 0.3);
    _glint(
      cv,
      p + const Offset(-14, -34),
      3 + 5 * _hump(g),
      0xFFE9A8,
      mk >= 1 ? 0.9 : 0,
      f.a,
    );
  }
}

// ============================================================== OKYANUS ===
// Giriş (4 sn, aşamalar t'ye göre): 0-25% yüzgeç suyu yarar, kapak sudan
// fırlar; 25-55% dev dalga kapağın arkasından yükselir, kapak üstünde sörf
// yapar; 55-85% kapak boyuna iner, ısırır, sıçrama ve "HAP!" balonu; 85-100%
// sıçrama söner. Döngü: balık çemberi (iki balık + aynalı üçüncü).

double _ok(double t, double a, double b) => _sp(t, a, b);
double _lerp(double a, double b, double x) => a + (b - a) * x;

CapPose _okyanusPose(CelebrationContext c) {
  final t = c.t;
  // Yükseliş: sudan fırlar, dalgada hafif süzülür, sonra boyuna iner.
  double dy;
  if (t < 0.1) {
    dy = 0;
  } else if (t < 0.2) {
    dy = -36 * _eo(_ok(t, 0.1, 0.2));
  } else if (t < 0.28) {
    dy = _lerp(-36, -20, _ok(t, 0.2, 0.28));
  } else if (t < 0.52) {
    dy = -20 + 3 * math.sin(_ok(t, 0.28, 0.52) * _tau);
  } else {
    final d = _ok(t, 0.52, 0.6);
    dy = _lerp(-20, 3, d * d);
  }
  final ride =
      math.sin(_ok(t, 0.25, 0.55) * _tau) * (_hump(_ok(t, 0.25, 0.55)));
  final bite = _hump(_ok(t, 0.6, 0.72));
  return CapPose(
    dx: 9 * ride,
    dy: dy + 3 * bite,
    rotation: 0.15 * ride,
    scale: 1 + 0.12 * bite,
  );
}

CapPose _okyanusLoopPose(CelebrationContext c) {
  if (c.reduceMotion) return CapPose.identity;
  final l = c.loop * _tau;
  return CapPose(
    dy: -2 * (0.5 - 0.5 * math.cos(l)),
    rotation: 0.03 * math.sin(l),
  );
}

void _okyanus(Canvas cv, CelebrationContext c) {
  if (c.reduceMotion) {
    _okyanusLoop(cv, c);
    return;
  }
  final f = _Fx(cv, c);
  final t = c.t;
  final w = c.capWidth / c.pose.scale;
  final head = c.capCenter - Offset(c.pose.dx, c.pose.dy);
  final neck = c.capImagePt(0.5, 0.95);
  double cx(double x) => x.clamp(168.0, 512.0);

  // 1) Yüzgeç suyun yüzeyinde kayar.
  final fk = _ok(t, 0.0, 0.03) * (1 - _ok(t, 0.15, 0.24));
  if (fk > 0.02) {
    final x = _lerp(
      c.glass.left + 16,
      c.glass.right - 16,
      _eo(_ok(t, 0.02, 0.16)),
    );
    final y = c.waterY + 4 + 2 * math.sin(t * 90);
    f.spr(
      'okyanus_fin',
      Offset(x, y),
      0.38 * w,
      at: Alignment.bottomCenter,
      op: fk,
    );
  }
  // Fırlama anında küçük sıçramalar.
  final sk = _ok(t, 0.12, 0.2) * (1 - _ok(t, 0.24, 0.32));
  if (sk > 0.02) {
    final k = _back(_ok(t, 0.12, 0.2));
    f.spr(
      'okyanus_splash',
      Offset(cx(neck.dx - 0.34 * w), neck.dy + 10),
      0.42 * w * k,
      at: Alignment.bottomCenter,
      op: sk,
    );
    f.spr(
      'okyanus_splash',
      Offset(cx(neck.dx + 0.34 * w), neck.dy + 10),
      0.42 * w * k,
      at: Alignment.bottomCenter,
      flip: true,
      op: sk,
    );
  }

  // 2) Dev dalga kapağın arkasından yükselir; kapak üstünde sörf yapar.
  final wk = _eo(_ok(t, 0.22, 0.34)) * (1 - _ok(t, 0.52, 0.62));
  if (wk > 0.02) {
    final ww = 1.3 * w;
    final base = c.glass.top + 0.4 * w + (1 - wk) * 70;
    f.spr(
      'okyanus_wave',
      Offset(cx(head.dx), base),
      ww,
      at: Alignment.bottomCenter,
      op: wk,
    );
    c.drawCapOver(cv);
    // Köpük serpintisi.
    final top = base - ww * 363 / 442;
    for (var i = 0; i < 12; i++) {
      final k = _fract((_ok(t, 0.28, 0.56)) * 2.2 + c.rand(i, 1));
      final p = Offset(
        cx(head.dx + (c.rand(i, 2) - 0.5) * 1.1 * w),
        math.max(80.0, top + 0.18 * ww * 0.5 - k * 0.3 * w),
      );
      cv.drawCircle(
        p,
        (2.5 + 3.5 * c.rand(i, 3)) * (1 - 0.4 * k),
        c.paintOf(0xFFFFFF, wk * _hump(k) * 0.95),
      );
    }
  }

  // 3) Isırık: kocaman sıçrama omuzlarda ve "HAP!" balonu.
  final bk = _back(_ok(t, 0.56, 0.64));
  final bo = (1 - _ok(t, 0.8, 0.9)) * _ok(t, 0.56, 0.6);
  if (bo > 0.02) {
    final sy = c.glass.top + 26;
    f.spr(
      'okyanus_splash',
      Offset(cx(c.glass.left - 4), sy),
      0.8 * w * bk,
      at: Alignment.bottomCenter,
      op: bo,
    );
    f.spr(
      'okyanus_splash',
      Offset(cx(c.glass.right + 4), sy),
      0.8 * w * bk,
      at: Alignment.bottomCenter,
      flip: true,
      op: bo,
    );
    c.drawCapOver(cv);
    final bx = math.min(head.dx + 0.66 * w, 430.0);
    final by = math.max(head.dy - 0.2 * w, 112.0);
    f.bubble('HAP!', Offset(bx, by), 1.1 * _back(_ok(t, 0.58, 0.68)), bo, -1);
  }
}

/// Sabit/döngü: balık çemberi (kapağın etrafında elips), kabarcıklar.
void _okyanusLoop(Canvas cv, CelebrationContext c) {
  final f = _Fx(cv, c);
  final w = c.capWidth / c.pose.scale;
  final head = c.capCenter - Offset(c.pose.dx, c.pose.dy);
  final l = c.reduceMotion ? 0.12 : c.loop;
  final cy = head.dy + 0.12 * w;
  final rx = 0.66 * w, ry = 0.17 * w;

  final fish = <(String, bool, double)>[
    ('okyanus_fish1', false, 0.0),
    ('okyanus_fish2', false, 1 / 3),
    ('okyanus_fish1', true, 2 / 3),
  ];
  final back = <void Function()>[];
  final front = <void Function()>[];
  for (final (name, mirror, off) in fish) {
    final phi = (l + off) * _tau;
    final depth = math.cos(phi); // >0 önde
    final x = (head.dx + rx * math.sin(phi)).clamp(190.0, 490.0);
    final y = cy + ry * depth + 3 * math.sin(phi * 2);
    final fw = 0.3 * w * (0.72 + 0.28 * (0.5 + 0.5 * depth));
    final op = depth > 0 ? 1.0 : 0.55;
    // Öndeki balık sağa, arkadaki sola yüzer (aynalı olan tersine).
    final right = (depth > 0) != mirror;
    final rot = 0.12 * math.sin(phi) * (right ? 1 : -1);
    void draw() =>
        f.spr(name, Offset(x, y), fw, flip: !right, rot: rot, op: op);
    (depth > 0 ? front : back).add(draw);
  }
  for (final d in back) {
    d();
  }
  c.drawCapOver(cv);
  for (final d in front) {
    d();
  }

  // Kabarcıklar: aralıklı, cam omzundan yükselir.
  for (var i = 0; i < 5; i++) {
    final k = c.reduceMotion ? 0.2 + 0.15 * i : _fract(l + i / 5);
    final side = i.isEven ? -1.0 : 1.0;
    final x =
        (head.dx +
                side * (0.42 + 0.14 * (i % 3)) * w +
                6 * math.sin(k * _tau * 2 + i))
            .clamp(190.0, 490.0);
    final y = c.glass.top - k * 0.9 * w;
    final bw = (0.1 + 0.05 * c.rand(i, 1)) * w;
    f.spr(
      'okyanus_bubble',
      Offset(x, math.max(90.0, y)),
      bw,
      op: c.reduceMotion ? 0.9 : _hump(k) * 0.95,
    );
  }
}

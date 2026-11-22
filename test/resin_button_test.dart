import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrosen/features/home/resin_button.dart';

double _cr(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('ResinColors picks readable text for light and dark colors', () {
    for (final c in [
      const Color(0xFFF4E27A),
      const Color(0xFF0C2A4A),
      const Color(0xFFD4537E),
    ]) {
      final t = ResinColors.readableOn(c);
      expect(_cr(t, c), greaterThanOrEqualTo(4.5));
    }
  });

  test('derive keeps text readable on glass over light and dark scenes', () {
    for (final bg in [const Color(0xFFF2F8FF), const Color(0xFF0B1A2A)]) {
      for (final tone in ResinTone.values) {
        final r = ResinColors.derive(
          tone: tone,
          band: const Color(0xFFD4537E),
          water: const Color(0xFFE24B4A),
          glass: const Color(0xFFF4C0D1),
          deep: const Color(0xFF791F1F),
          backdrop: bg,
        );
        final mid = Color.alphaBlend(Color.lerp(r.top, r.bottom, 0.5)!, bg);
        expect(_cr(r.text, mid), greaterThanOrEqualTo(4.5));
      }
    }
  });
}

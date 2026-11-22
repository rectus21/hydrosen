import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Sahnenin üstünde duran buzlu cam panel: arkası bulanıklaştırılmış, yarı
/// saydam yüzey. Yüzey rengi temanın [ColorScheme.surface]'idir; metin
/// kontrastı bu renge göre hesaplandığı için okunurluk korunur.
class FrostedPanel extends StatelessWidget {
  const FrostedPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 24,
  });

  /// Yüzeyin saydamlığı; kontrast testleri bu değerle yapılır.
  static const surfaceAlpha = 0.84;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final shape = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: s.surface.withValues(alpha: surfaceAlpha),
            borderRadius: shape,
            border: Border.all(color: s.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Padding(
            padding: padding,
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      ),
    );
  }
}

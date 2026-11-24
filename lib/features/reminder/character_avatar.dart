import 'package:flutter/material.dart';

import '../thermos/illustrated_artwork.dart';
import '../thermos/thermos_theme.dart';
import '../thermos/wolf_artwork.dart';

/// Karakterin küçük yuvarlak resmi (kapak). Resim bulunamazsa adın baş harfi.
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({super.key, required this.theme, this.size = 44});

  final ThermosTheme theme;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Uygulama açılışında çözülmüş kapak varsa onu kullan (anında görünür).
    final preloaded = theme.id == 'kurt'
        ? WolfArtwork.current?.normal
        : IllustratedArtwork.byId[theme.id]?.normal;
    final initial = theme.name.isEmpty ? '?' : theme.name[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.92),
        border: Border.all(color: theme.edge.withValues(alpha: 0.7), width: 2),
      ),
      child: ClipOval(
        child: preloaded != null
            ? RawImage(
                image: preloaded,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              )
            : Image.asset(
                'assets/caps/${theme.id}_normal.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: theme.label,
                      fontWeight: FontWeight.w800,
                      fontSize: size * 0.45,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

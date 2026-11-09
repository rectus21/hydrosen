import 'dart:ui';

/// Termos biçimi: tasarım taslaklarındaki "Tombul" ve "İnce".
enum ThermosShape {
  chubby('Tombul'),
  slim('İnce');

  const ThermosShape(this.label);
  final String label;
}

/// Bir temanın renkleri. Kapak ve arka plan çizimleri sonraki adımda temaya
/// eklenecek; şimdilik yalnızca Klasik tema var.
class ThermosTheme {
  const ThermosTheme({
    required this.id,
    required this.name,
    required this.background,
    required this.glass,
    required this.edge,
    required this.water,
    required this.deepWater,
    required this.waterSurface,
    required this.mark,
    required this.label,
    required this.band,
    required this.bandLight,
  });

  final String id;
  final String name;
  final Color background;
  final Color glass;
  final Color edge;
  final Color water;
  final Color deepWater;
  final Color waterSurface;
  final Color mark;
  final Color label;
  final Color band;
  final Color bandLight;

  static const classic = ThermosTheme(
    id: 'klasik',
    name: 'Klasik',
    background: Color(0xFFE6F1FB),
    glass: Color(0xFFB5D4F4),
    edge: Color(0xFF185FA5),
    water: Color(0xFF378ADD),
    deepWater: Color(0xFF0C447C),
    waterSurface: Color(0xFFB5D4F4),
    mark: Color(0xFF0C447C),
    label: Color(0xFF0C447C),
    band: Color(0xFF888780),
    bandLight: Color(0xFFB4B2A9),
  );
}

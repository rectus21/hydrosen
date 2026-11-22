import 'dart:ui';

/// Tasarım taslaklarındaki SVG yol verisini (M, L, Q, H, V, Z ve küçük harfli
/// göreli karşılıkları) Flutter [Path]'e çevirir. Tema çizimleri bu sayede
/// taslaklardaki koordinatlarla birebir taşınabilir.
Path svgPath(String d) {
  final tokens = RegExp(r'[MLQHVZmlqhvz]|-?\d*\.?\d+(?:e-?\d+)?')
      .allMatches(d)
      .map((m) => m.group(0)!)
      .toList();
  final path = Path();
  var i = 0;
  var cmd = '';
  double x = 0, y = 0, startX = 0, startY = 0;

  bool isCmd(String t) => RegExp(r'^[A-Za-z]$').hasMatch(t);
  double next() {
    if (i >= tokens.length || isCmd(tokens[i])) {
      throw FormatException('Eksik sayı: "$d"');
    }
    return double.parse(tokens[i++]);
  }

  while (i < tokens.length) {
    if (isCmd(tokens[i])) {
      cmd = tokens[i++];
    } else if (cmd.isEmpty) {
      throw FormatException('Komutsuz sayı: "$d"');
    }
    final rel = cmd == cmd.toLowerCase();
    switch (cmd.toUpperCase()) {
      case 'M':
        x = next() + (rel ? x : 0);
        y = next() + (rel ? y : 0);
        path.moveTo(x, y);
        startX = x;
        startY = y;
        // M'den sonraki sayı çiftleri L olarak okunur.
        cmd = rel ? 'l' : 'L';
      case 'L':
        x = next() + (rel ? x : 0);
        y = next() + (rel ? y : 0);
        path.lineTo(x, y);
      case 'H':
        x = next() + (rel ? x : 0);
        path.lineTo(x, y);
      case 'V':
        y = next() + (rel ? y : 0);
        path.lineTo(x, y);
      case 'Q':
        final cx = next() + (rel ? x : 0);
        final cy = next() + (rel ? y : 0);
        x = next() + (rel ? x : 0);
        y = next() + (rel ? y : 0);
        path.quadraticBezierTo(cx, cy, x, y);
      case 'Z':
        path.close();
        x = startX;
        y = startY;
        cmd = '';
      default:
        throw FormatException('Desteklenmeyen komut: $cmd');
    }
  }
  return path;
}

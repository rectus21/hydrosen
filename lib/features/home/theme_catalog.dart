import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../settings/settings_controller.dart';
import '../thermos/thermos_theme.dart';

/// Tema kataloğunun kategorileri (görünme sırasıyla). Eşlenmeyen temalar
/// [kThemeOtherCategory] altında toplanır.
const String kThemeOtherCategory = 'Diğer';
const List<String> kThemeCategories = [
  'Hayvanlar',
  'Meyve ve tatlılar',
  'Spor',
  'Meslekler',
  'Fantastik ve uzay',
  'Doğa ve mevsim',
  kThemeOtherCategory,
];

/// Tema id -> kategori. Yeni temayı eklemek/taşımak için yalnız burayı düzenle.
const Map<String, String> kThemeCategoryOf = {
  // Hayvanlar
  'kedi': 'Hayvanlar',
  'pofuduk': 'Hayvanlar',
  'kopek': 'Hayvanlar',
  'tavsan': 'Hayvanlar',
  'penguen': 'Hayvanlar',
  'koala': 'Hayvanlar',
  'baykus': 'Hayvanlar',
  'tilki': 'Hayvanlar',
  'kurt': 'Hayvanlar',
  'civciv': 'Hayvanlar',
  'aslan': 'Hayvanlar',
  'geyik': 'Hayvanlar',
  'inek': 'Hayvanlar',
  'koyun': 'Hayvanlar',
  'maymun': 'Hayvanlar',
  'boga': 'Hayvanlar',
  'susamuru': 'Hayvanlar',
  'fok': 'Hayvanlar',
  'balina': 'Hayvanlar',
  'fil': 'Hayvanlar',
  'rakun': 'Hayvanlar',
  'kirpi': 'Hayvanlar',
  'sincap': 'Hayvanlar',
  'kaplan': 'Hayvanlar',
  'panda': 'Hayvanlar',
  'ayi': 'Hayvanlar',
  'ahtapot': 'Hayvanlar',
  'kurbaga': 'Hayvanlar',
  // Meyve ve tatlılar
  'cilek': 'Meyve ve tatlılar',
  'karpuz': 'Meyve ve tatlılar',
  'limon': 'Meyve ve tatlılar',
  'avokado': 'Meyve ve tatlılar',
  'dondurma': 'Meyve ve tatlılar',
  'yesilelma': 'Meyve ve tatlılar',
  // Spor
  'futbol': 'Spor',
  'basketbol': 'Spor',
  'voleybol': 'Spor',
  'yarisarabasi': 'Spor',
  // Meslekler
  'eczaci': 'Meslekler',
  // Fantastik ve uzay
  'tekboynuz': 'Fantastik ve uzay',
  'astronot': 'Fantastik ve uzay',
  'ejderha': 'Fantastik ve uzay',
  'maviejderha': 'Fantastik ve uzay',
  'karaejderha': 'Fantastik ve uzay',
  'robot': 'Fantastik ve uzay',
  'korsan': 'Fantastik ve uzay',
  'sihirbaz': 'Fantastik ve uzay',
  'gece': 'Fantastik ve uzay',
  // Doğa ve mevsim
  'okyanus': 'Doğa ve mevsim',
  'kaktus': 'Doğa ve mevsim',
  'kardanadam': 'Doğa ve mevsim',
  'bulut': 'Doğa ve mevsim',
  'kamp': 'Doğa ve mevsim',
  'sonbahar': 'Doğa ve mevsim',
};

String themeCategoryOf(ThermosTheme t) =>
    kThemeCategoryOf[t.id] ?? kThemeOtherCategory;

/// Kategori -> temalar ([ThermosTheme.all] sırasıyla); boş kategoriler atlanır.
Map<String, List<ThermosTheme>> groupThemesByCategory([
  Iterable<ThermosTheme>? themes,
]) {
  final out = {for (final c in kThemeCategories) c: <ThermosTheme>[]};
  for (final t in themes ?? ThermosTheme.all) {
    out[themeCategoryOf(t)]!.add(t);
  }
  out.removeWhere((_, v) => v.isEmpty);
  return out;
}

/// Kapak görseli ve opak sınırları (yalnız görünür kısım; avatarda ortalanır).
class _CapImage {
  const _CapImage(this.image, this.bounds);
  final ui.Image image;
  final Rect bounds;
}

final _capCache = <String, Future<_CapImage?>>{};

Future<_CapImage?> _loadCap(String id) => _capCache.putIfAbsent(id, () async {
  try {
    final data = await rootBundle.load('assets/caps/${id}_normal.png');
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      targetWidth: 192,
    );
    final ui.Image img;
    try {
      img = (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
    final bytes = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bytes == null) return _CapImage(img, Offset.zero & _sizeOf(img));
    var minX = img.width, minY = img.height, maxX = -1, maxY = -1;
    for (var y = 0; y < img.height; y++) {
      for (var x = 0; x < img.width; x++) {
        if (bytes.getUint8((y * img.width + x) * 4 + 3) > 24) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }
    if (maxX < 0) return _CapImage(img, Offset.zero & _sizeOf(img));
    return _CapImage(
      img,
      Rect.fromLTRB(
        minX.toDouble(),
        minY.toDouble(),
        maxX + 1.0,
        maxY + 1.0,
      ),
    );
  } catch (_) {
    return null;
  }
});

Size _sizeOf(ui.Image i) => Size(i.width.toDouble(), i.height.toDouble());

class _CapPainter extends CustomPainter {
  _CapPainter(this.cap);
  final _CapImage cap;

  @override
  void paint(Canvas canvas, Size size) {
    final box = size.shortestSide * 0.84;
    final b = cap.bounds;
    final s = math.min(box / b.width, box / b.height);
    final dst = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: b.width * s,
      height: b.height * s,
    );
    // Açık renkli kapaklar açık sahnede okunsun diye hafif gölge.
    canvas.drawImageRect(
      cap.image,
      b,
      dst.shift(const Offset(0, 2.5)),
      Paint()
        ..filterQuality = FilterQuality.medium
        ..colorFilter = const ColorFilter.mode(Color(0x66000000), BlendMode.srcIn)
        ..imageFilter = ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
    );
    canvas.drawImageRect(
      cap.image,
      b,
      dst,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_CapPainter old) => old.cap != cap;
}

/// Yalnız avatar: yarı saydam beyaz daire içinde kapak. Seçiliyse kalın halka.
/// Dokununca tema hemen uygulanır; küçük "pop" animasyonu oynar.
class _ThemeAvatar extends StatefulWidget {
  const _ThemeAvatar({
    super.key,
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final ThermosTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ThemeAvatar> createState() => _ThemeAvatarState();
}

class _ThemeAvatarState extends State<_ThemeAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.14).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.14, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 65,
    ),
  ]).animate(_pop);

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _tap() {
    _pop.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final initial = t.name.isEmpty ? '?' : t.name.substring(0, 1).toUpperCase();
    return Semantics(
      button: true,
      selected: widget.selected,
      label: t.name,
      excludeSemantics: true,
      onTap: _tap,
      child: Tooltip(
        message: t.name,
        child: GestureDetector(
          key: ValueKey('theme-card-${t.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: _tap,
          child: ScaleTransition(
            scale: _scale,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: widget.selected
                      ? Border.all(color: const Color(0xFF1E88E5), width: 5)
                      : null,
                ),
                child: FutureBuilder<_CapImage?>(
                  future: _loadCap(t.id),
                  builder: (context, snap) {
                    final cap = snap.data;
                    if (cap == null) {
                      return Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            shadows: const [
                              Shadow(
                                color: Color(0xAA000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return CustomPaint(painter: _CapPainter(cap));
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kategori süzgeçli, kaydırmalı avatar ızgarası; dokununca tema uygulanır.
class ThemeCatalog extends StatefulWidget {
  const ThemeCatalog({super.key, required this.settings, this.footer});

  final SettingsController settings;
  final Widget? footer;

  @override
  State<ThemeCatalog> createState() => _ThemeCatalogState();
}

class _ThemeCatalogState extends State<ThemeCatalog> {
  static const _all = 'Tümü';
  late final Map<String, List<ThermosTheme>> _groups = groupThemesByCategory();
  String _filter = _all;

  void _select(ThermosTheme t) {
    if (t != widget.settings.theme) widget.settings.setTheme(t);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.settings,
    builder: (context, _) {
      final text = Theme.of(context).textTheme;
      final cats = _groups.keys.toList();
      final specific = _filter != _all && _groups.containsKey(_filter);
      final themes = <ThermosTheme>[
        for (final c in specific ? [_filter] : cats) ..._groups[c]!,
      ];
      final footer = widget.footer;
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                'Tema seç',
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView(
                key: const ValueKey('theme-chips'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  for (final c in [_all, ...cats])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        key: ValueKey('theme-chip-$c'),
                        label: Text(c),
                        selected: _filter == c,
                        onSelected: (_) => setState(() => _filter = c),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: themes.length,
              itemBuilder: (_, i) {
                final t = themes[i];
                return _ThemeAvatar(
                  key: ValueKey('theme-avatar-${t.id}'),
                  theme: t,
                  selected: t == widget.settings.theme,
                  onTap: () => _select(t),
                );
              },
            ),
          ),
          if (footer != null)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(child: footer),
            ),
        ],
      );
    },
  );
}

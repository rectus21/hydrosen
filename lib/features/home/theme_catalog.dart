import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';
import '../thermos/thermos_theme.dart';

/// Tema kataloğunun kategorileri (görünme sırasıyla). Eşlenmeyen temalar
/// [kThemeOtherCategory] altında toplanır.
const String kThemeOtherCategory = 'Diğer';
const List<String> kThemeCategories = [
  'Hayvanlar',
  'Meyve ve tatlılar',
  'Fantastik ve uzay',
  'Doğa ve mevsim',
  kThemeOtherCategory,
];

/// Tema id -> kategori. Yeni temayı eklemek/taşımak için yalnız burayı düzenle.
const Map<String, String> kThemeCategoryOf = {
  // Hayvanlar
  'kedi': 'Hayvanlar',
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
  'seftali': 'Meyve ve tatlılar',
  // Fantastik ve uzay
  'tekboynuz': 'Fantastik ve uzay',
  'astronot': 'Fantastik ve uzay',
  'ejderha': 'Fantastik ve uzay',
  'maviejderha': 'Fantastik ve uzay',
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

const _scrim = Color(0xB3101418);

/// Yüklenirken sakin renk gösteren, çözümleme boyutu sınırlı varlık resmi.
class _CatalogImage extends StatelessWidget {
  const _CatalogImage(
    this.path, {
    required this.cacheWidth,
    this.fit = BoxFit.cover,
  });

  final String path;
  final int cacheWidth;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Image.asset(
    path,
    fit: fit,
    cacheWidth: cacheWidth,
    gaplessPlayback: true,
    filterQuality: FilterQuality.medium,
    errorBuilder: (_, _, _) => const SizedBox.shrink(),
    frameBuilder: (context, child, frame, sync) => sync
        ? child
        : AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 180),
            child: child,
          ),
  );
}

String _scene(ThermosTheme t) => 'assets/scenes/${t.id}.png';
String _cap(ThermosTheme t, {bool happy = false}) =>
    'assets/caps/${t.id}_${happy ? 'happy' : 'normal'}.png';

class _NameStrip extends StatelessWidget {
  const _NameStrip(this.name);

  final String name;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 34),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    color: _scrim,
    alignment: Alignment.center,
    child: Text(
      name,
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.clip,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12.5,
        height: 1.15,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// Seçili temayı büyük gösteren üst kart.
class _SelectedHero extends StatelessWidget {
  const _SelectedHero({required this.theme});

  final ThermosTheme theme;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Seçili tema ${theme.name}',
      child: Container(
        key: const ValueKey('theme-hero'),
        height: 150,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.primary, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _CatalogImage(_scene(theme), cacheWidth: 900),
            Positioned(
              right: 12,
              top: 8,
              bottom: 8,
              width: 120,
              child: _CatalogImage(
                _cap(theme),
                cacheWidth: 400,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: _scrim,
                padding: const EdgeInsets.fromLTRB(14, 8, 140, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seçili tema',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      theme.name,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final ThermosTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);
    return Semantics(
      button: true,
      selected: selected,
      label: theme.name,
      child: GestureDetector(
        key: ValueKey('theme-card-${theme.id}'),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: radius,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 4 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _CatalogImage(_scene(theme), cacheWidth: 300),
                Positioned(
                  left: 8,
                  right: 8,
                  top: 8,
                  bottom: 42,
                  child: _CatalogImage(
                    _cap(theme),
                    cacheWidth: 300,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _NameStrip(theme.name),
                ),
                if (selected)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: CircleAvatar(
                      radius: 11,
                      backgroundColor: scheme.primary,
                      child: Icon(Icons.check, size: 15, color: scheme.onPrimary),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kategorilere ayrılmış, kaydırmalı tema kataloğu.
class ThemeCatalog extends StatefulWidget {
  const ThemeCatalog({super.key, required this.settings, this.footer});

  final SettingsController settings;
  final Widget? footer;

  @override
  State<ThemeCatalog> createState() => _ThemeCatalogState();
}

class _ThemeCatalogState extends State<ThemeCatalog> {
  static const _all = 'Tümü';
  final _scroll = ScrollController();
  late final Map<String, List<ThermosTheme>> _groups = groupThemesByCategory();
  String _filter = _all;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _preview(ThermosTheme t) async {
    final chosen = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _ThemePreviewSheet(theme: t, settings: widget.settings),
    );
    if (chosen == true && mounted && _scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _card(ThermosTheme t) => _ThemeCard(
    theme: t,
    selected: t == widget.settings.theme,
    onTap: () => _preview(t),
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.settings,
    builder: (context, _) {
      final text = Theme.of(context).textTheme;
      final cats = _groups.keys.toList();
      final specific = _filter != _all && _groups.containsKey(_filter);
      return CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _SelectedHero(theme: widget.settings.theme),
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
          if (specific)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 120 / 160,
                ),
                itemCount: _groups[_filter]!.length,
                itemBuilder: (_, i) => _card(_groups[_filter]![i]),
              ),
            )
          else
            SliverList.builder(
              itemCount: cats.length,
              itemBuilder: (context, i) {
                final list = _groups[cats[i]]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              cats[i],
                              style: text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text('${list.length} tema', style: text.bodySmall),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        key: ValueKey('theme-row-${cats[i]}'),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (_, j) =>
                            SizedBox(width: 120, child: _card(list[j])),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          if (widget.footer != null)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(child: widget.footer),
            ),
        ],
      );
    },
  );
}

class _ThemePreviewSheet extends StatefulWidget {
  const _ThemePreviewSheet({required this.theme, required this.settings});

  final ThermosTheme theme;
  final SettingsController settings;

  @override
  State<_ThemePreviewSheet> createState() => _ThemePreviewSheetState();
}

class _ThemePreviewSheetState extends State<_ThemePreviewSheet> {
  bool _happy = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final scheme = Theme.of(context).colorScheme;
    final isSelected = widget.settings.theme == t;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                key: const ValueKey('theme-preview-scene'),
                onTap: () => setState(() => _happy = !_happy),
                child: SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: scheme.surfaceContainerHighest),
                      _CatalogImage(_scene(t), cacheWidth: 900),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _CatalogImage(
                          _cap(t, happy: _happy),
                          cacheWidth: 900,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SwitchListTile(
              key: const ValueKey('theme-preview-happy'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Mutlu hâli'),
              value: _happy,
              onChanged: (v) => setState(() => _happy = v),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('theme-select-button'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: () {
                  if (!isSelected) widget.settings.setTheme(t);
                  Navigator.of(context).pop(true);
                },
                child: Text(isSelected ? 'Seçili' : 'Bu temayı seç'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

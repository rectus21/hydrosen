import 'package:flutter/material.dart';

import '../../app/app_look.dart';
import '../settings/settings_controller.dart';
import '../thermos/thermos_theme.dart';

/// Deneme aşaması için geçici; sonra kaldırılacak/düzeltilecek.
/// Ana ekrandaki hızlı tema rafını açar/kapatır. Kaldırmak için bayrağı false
/// yap ya da bu dosyayı ve home_screen.dart'taki kullanımını sil.
const bool kQuickThemeStrip = true;

/// Geçici "tema rafı": tüm temaların küçük önizlemeleri + tombul/ince seçici.
class QuickThemeStrip extends StatefulWidget {
  const QuickThemeStrip({super.key, required this.settings});

  final SettingsController settings;

  @override
  State<QuickThemeStrip> createState() => _QuickThemeStripState();
}

class _QuickThemeStripState extends State<QuickThemeStrip> {
  static const _itemW = 72.0, _gap = 8.0;
  static final _themes = <ThermosTheme>[
    ThermosTheme.unicorn,
    ThermosTheme.byId('balina'),
    for (final theme in ThermosTheme.all)
      if (theme.id != 'tekboynuz' && theme.id != 'balina') theme,
  ];
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(jump: true));
  }

  @override
  void didUpdateWidget(QuickThemeStrip old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  void _reveal({bool jump = false}) {
    if (!mounted || !_scroll.hasClients) return;
    final i = _themes.indexOf(widget.settings.theme);
    if (i < 0) return;
    final pos = _scroll.position;
    final center = i * (_itemW + _gap) + _itemW / 2 - pos.viewportDimension / 2;
    final target = center.clamp(0.0, pos.maxScrollExtent);
    if (jump) {
      _scroll.jumpTo(target);
    } else if ((target - pos.pixels).abs() > 1) {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SegmentedButton<ThermosShape>(
          key: const ValueKey('quick-shape'),
          segments: [
            for (final v in ThermosShape.values)
              ButtonSegment(value: v, label: Text(v.label)),
          ],
          selected: {s.shape},
          showSelectedIcon: false,
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onSelectionChanged: (v) => s.setShape(v.first),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 78,
          child: ListView.separated(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            itemCount: _themes.length,
            separatorBuilder: (_, _) => const SizedBox(width: _gap),
            itemBuilder: (context, i) {
              final t = _themes[i];
              final selected = t == s.theme;
              final face = themeTypefaces[t.id]?.headline ?? AppFont.nunito;
              return InkWell(
                key: ValueKey('quick-theme-${t.id}'),
                borderRadius: BorderRadius.circular(10),
                onTap: () => s.setTheme(t),
                child: Container(
                  width: _itemW,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? scheme.primary : scheme.outlineVariant,
                      width: selected ? 3 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(child: _ThemeThumbnail(theme: t)),
                      const SizedBox(height: 3),
                      Text(
                        t.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: face.style(
                          TextStyle(
                            fontSize: 11,
                            height: 1.1,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ThemeThumbnail extends StatelessWidget {
  const _ThemeThumbnail({required this.theme});

  final ThermosTheme theme;

  @override
  Widget build(BuildContext context) {
    if (theme.id == 'tekboynuz' || theme.id == 'balina') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: ColoredBox(
          color: Colors.white.withValues(alpha: 0.7),
          child: Image.asset(
            'assets/caps/${theme.id}_normal.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => _MiniThermos(theme: theme),
          ),
        ),
      );
    }
    return _MiniThermos(theme: theme);
  }
}

class _MiniThermos extends StatelessWidget {
  const _MiniThermos({required this.theme});

  final ThermosTheme theme;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(5),
    child: Column(
      children: [
        Container(height: 7, color: theme.band),
        Container(height: 2, color: theme.bandLight),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.glass,
              border: Border.all(color: theme.edge),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.6,
                widthFactor: 1,
                child: ColoredBox(color: theme.water),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

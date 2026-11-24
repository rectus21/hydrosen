import 'package:flutter/material.dart';

import '../../app/frosted_panel.dart';
import '../../domain/badges.dart';
import '../../domain/streak.dart';
import '../home/water_controller.dart';
import 'badge_medallion.dart';

const _monthShort = [
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];

String _shortDate(DateTime d) => '${d.day} ${_monthShort[d.month - 1]}';

/// Profil sekmesindeki "Rozetlerim" bölümü: seri özeti, kaçırma hakkı ve
/// rozet ızgarası (kazanılanlar renkli, kilitliler gri).
class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key, required this.controller});

  final WaterController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) =>
        BadgesPanel(status: controller.streak, earned: controller.earnedBadges),
  );
}

/// Denetleyiciden bağımsız, yalnız veriyle çizilen panel (testlenebilir).
class BadgesPanel extends StatelessWidget {
  const BadgesPanel({super.key, required this.status, required this.earned});

  final StreakStatus status;
  final Map<String, DateTime> earned;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final toNext = status.goalDaysToNextRight;
    return FrostedPanel(
      key: const ValueKey('badges-section'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rozetlerim', style: text.titleLarge),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _Stat(
                    key: const ValueKey('streak-current'),
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFFF8A2B),
                    value: '${status.current}',
                    label: 'Şu anki seri',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Stat(
                    key: const ValueKey('streak-best'),
                    icon: Icons.emoji_events_rounded,
                    iconColor: const Color(0xFFE0A100),
                    value: '${status.best}',
                    label: 'En uzun seri',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _RightsStat(
                    key: const ValueKey('rights-stat'),
                    rights: status.rights,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Her 7 hedef gününde 1 hak kazanırsın, en fazla 2. '
            'Bir günü kaçırırsan hak kendiliğinden kullanılır.'
            '${toNext == null ? '' : ' Sonraki hakka $toNext hedef günü var.'}',
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (status.current == 0 && !status.todayDone) ...[
            const SizedBox(height: 6),
            Text(
              'Yeni bir seri başlıyor! Bugün ilk gün.',
              key: const ValueKey('streak-fresh'),
              style: text.bodySmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 6,
              // Madalyon (en çok 110) + iki satır yazı; yazı boyutuyla büyür.
              mainAxisExtent: 116 + MediaQuery.textScalerOf(context).scale(40),
            ),
            children: [
              for (final b in Badges.all)
                _BadgeCell(
                  key: ValueKey('badge-${b.id}'),
                  badge: b,
                  earnedAt: earned[b.id],
                  remaining: b.days == null
                      ? null
                      : (b.days! - status.current).clamp(0, b.days!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return _StatBox(
      top: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 2),
          Text(
            value,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
      label: label,
      labelColor: scheme.onSurfaceVariant,
    );
  }
}

class _RightsStat extends StatelessWidget {
  const _RightsStat({super.key, required this.rights});

  final int rights;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Kaçırma hakkı: $rights / ${StreakEngine.maxRights}',
      excludeSemantics: true,
      child: _StatBox(
        top: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < StreakEngine.maxRights; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  i < rights ? Icons.shield : Icons.shield_outlined,
                  key: ValueKey('right-${i < rights ? 'full' : 'empty'}-$i'),
                  size: 28,
                  color: i < rights
                      ? const Color(0xFF3FA7D6)
                      : scheme.outline.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
        label: 'Kaçırma hakkı',
        labelColor: scheme.onSurfaceVariant,
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.top,
    required this.label,
    required this.labelColor,
  });

  final Widget top;
  final String label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(fit: BoxFit.scaleDown, child: top),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: labelColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCell extends StatelessWidget {
  const _BadgeCell({
    super.key,
    required this.badge,
    required this.earnedAt,
    required this.remaining,
  });

  final BadgeDef badge;
  final DateTime? earnedAt;
  final int? remaining;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final locked = earnedAt == null;
    final sub = locked
        ? (remaining != null ? '$remaining gün kaldı' : badge.hint)
        : _shortDate(earnedAt!);
    return Semantics(
      label: locked
          ? '${badge.title} rozeti kilitli, $sub'
          : '${badge.title} rozeti kazanıldı, $sub',
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, c) {
          final size = (c.maxWidth * 0.82).clamp(48.0, 92.0);
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BadgeMedallion(badge: badge, size: size, locked: locked),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  badge.title,
                  maxLines: 1,
                  style: text.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: locked ? scheme.onSurfaceVariant : scheme.onSurface,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  sub,
                  maxLines: 1,
                  style: text.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

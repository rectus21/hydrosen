import 'package:flutter/material.dart';

import '../../domain/streak.dart';

/// Ana ekranın tek satırlık seri notu. Sakin ve suçlamasız; yeni panel yok.
String streakLineText(StreakStatus s) {
  final hak = s.rights > 0 ? ' · ${s.rights} hak' : '';
  if (s.todayDone) return '${s.current}. gün devam ediyor$hak';
  if (s.current > 0) {
    if (s.yesterdayProtected) return 'Hakkın kullanıldı, seri devam ediyor$hak';
    return 'Bugün hedefe ulaşırsan ${s.current + 1}. gün olur$hak';
  }
  return 'Yeni bir seri başlıyor! Bugün ilk gün.';
}

/// [fg] ve [shadows]: sahnenin alt bandının parlaklığına göre ana ekranın
/// seçtiği okunur renk ve gölge.
class StreakLine extends StatelessWidget {
  const StreakLine({
    super.key,
    required this.status,
    required this.fg,
    required this.shadows,
  });

  final StreakStatus status;
  final Color fg;
  final List<Shadow> shadows;

  @override
  Widget build(BuildContext context) {
    final active = status.todayDone || status.current > 0;
    final text = streakLineText(status);
    return Semantics(
      label: 'Seri: $text',
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 15,
              color: active
                  ? const Color(0xFFFF9A3C)
                  : fg.withValues(alpha: 0.7),
              shadows: shadows,
            ),
            const SizedBox(width: 3),
            Text(
              text,
              maxLines: 1,
              softWrap: false,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: fg.withValues(alpha: 0.9),
                shadows: shadows,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/frosted_panel.dart';
import '../../domain/app_settings.dart';
import '../../domain/saved_container.dart';
import '../../domain/water_entry.dart';
import 'drink_widgets.dart';
import 'entry_sheet.dart';
import 'water_controller.dart';

enum _RecordsPeriod { week, month }

class RecordsSection extends StatefulWidget {
  const RecordsSection({
    super.key,
    required this.controller,
    required this.onDelete,
    this.containers = AppSettings.defaultContainers,
  });

  final WaterController controller;
  final void Function(int id) onDelete;
  final List<SavedContainer> containers;

  @override
  State<RecordsSection> createState() => _RecordsSectionState();
}

class _RecordsSectionState extends State<RecordsSection> {
  late DateTime _weekAnchor;
  late DateTime _monthAnchor;
  late DateTime _selectedDay;
  _RecordsPeriod _period = _RecordsPeriod.week;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _weekAnchor = _startOfWeek(today);
    _monthAnchor = DateTime(today.year, today.month);
    _selectedDay = today;
  }

  Map<DateTime, int> get _dailyTotals {
    final totals = <DateTime, int>{};
    for (final entry in widget.controller.allEntries) {
      final day = _dateOnly(entry.time);
      totals.update(
        day,
        (value) => value + entry.countedMl,
        ifAbsent: () => entry.countedMl,
      );
    }
    return totals;
  }

  List<WaterEntry> get _selectedEntries => widget.controller.allEntries
      .where((entry) => DateUtils.isSameDay(entry.time, _selectedDay))
      .toList();

  void _selectPeriod(_RecordsPeriod period) {
    if (_period == period) return;
    final today = _dateOnly(DateTime.now());
    setState(() {
      _period = period;
      if (period == _RecordsPeriod.week) {
        _weekAnchor = _startOfWeek(_selectedDay);
      } else {
        _monthAnchor = DateTime(_selectedDay.year, _selectedDay.month);
      }

      if (_selectedDay.isAfter(today)) _selectedDay = today;
    });
  }

  void _movePeriod(int amount) {
    final today = _dateOnly(DateTime.now());
    setState(() {
      if (_period == _RecordsPeriod.week) {
        _weekAnchor = _weekAnchor.add(Duration(days: amount * 7));
        final proposed = _weekAnchor;
        _selectedDay = proposed.isAfter(today) ? today : proposed;
      } else {
        _monthAnchor = DateTime(_monthAnchor.year, _monthAnchor.month + amount);
        final proposed = DateTime(_monthAnchor.year, _monthAnchor.month, 1);
        _selectedDay = proposed.isAfter(today) ? today : proposed;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totals = _dailyTotals;
    final protectedDays = widget.controller.streak.protectedDays;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const SceneTitle('Su kayıtları'),
            const SizedBox(height: 12),
            SegmentedButton<_RecordsPeriod>(
              key: const ValueKey('records-period-selector'),
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: _RecordsPeriod.week,
                  icon: Icon(Icons.view_week_outlined),
                  label: Text('Haftalık'),
                ),
                ButtonSegment(
                  value: _RecordsPeriod.month,
                  icon: Icon(Icons.calendar_month_outlined),
                  label: Text('Aylık'),
                ),
              ],
              selected: {_period},
              onSelectionChanged: (selection) => _selectPeriod(selection.first),
            ),
            const SizedBox(height: 12),
            _PeriodHeader(
              label: _period == _RecordsPeriod.week
                  ? _weekLabel(_weekAnchor)
                  : _monthLabel(_monthAnchor),
              onPrevious: () => _movePeriod(-1),
              onNext: _canMoveForward ? () => _movePeriod(1) : null,
            ),
            const SizedBox(height: 12),
            if (_period == _RecordsPeriod.week)
              _WeeklyChart(
                weekStart: _weekAnchor,
                selectedDay: _selectedDay,
                totals: totals,
                protectedDays: protectedDays,
                goalMl: widget.controller.goalMl,
                onSelect: (day) => setState(() => _selectedDay = day),
              )
            else
              _MonthlyCalendar(
                month: _monthAnchor,
                selectedDay: _selectedDay,
                totals: totals,
                protectedDays: protectedDays,
                goalMl: widget.controller.goalMl,
                onSelect: (day) => setState(() => _selectedDay = day),
              ),
            const SizedBox(height: 12),
            _DayRecords(
              day: _selectedDay,
              entries: _selectedEntries,
              isProtected: protectedDays.contains(_dateOnly(_selectedDay)),
              totalMl: totals[_dateOnly(_selectedDay)] ?? 0,
              goalMl: widget.controller.goalMl,
              onDelete: widget.onDelete,
              onEdit: (entry) => editEntryFlow(
                context,
                widget.controller,
                entry,
                containers: widget.containers,
              ),
              onAdd: () => addEntryFlow(
                context,
                widget.controller,
                _selectedDay,
                containers: widget.containers,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canMoveForward {
    final today = _dateOnly(DateTime.now());
    if (_period == _RecordsPeriod.week) {
      return _weekAnchor.isBefore(_startOfWeek(today));
    }
    return _monthAnchor.isBefore(DateTime(today.year, today.month));
  }
}

class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) => FrostedPanel(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Önceki dönem',
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          tooltip: 'Sonraki dönem',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    ),
  );
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({
    required this.weekStart,
    required this.selectedDay,
    required this.totals,
    required this.protectedDays,
    required this.goalMl,
    required this.onSelect,
  });

  final DateTime weekStart;
  final DateTime selectedDay;
  final Map<DateTime, int> totals;
  final Set<DateTime> protectedDays;
  final int goalMl;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );
    final values = [for (final day in days) totals[_dateOnly(day)] ?? 0];
    final weekTotal = values.fold(0, (sum, value) => sum + value);
    final maxValue = math.max(goalMl, values.fold(0, math.max));
    final scheme = Theme.of(context).colorScheme;

    // Kenar boşluğu dar: günlük çubuklar en az 48 px genişliğinde dokunma
    // hedefi olsun (390 px ekranda 7 x ~50 px). Başlık ve ipucu kendi
    // boşluğunu taşır.
    const edge = EdgeInsets.symmetric(horizontal: 8);
    return FrostedPanel(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: edge,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Haftalık ilerleme',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Günlük hedef $goalMl ml',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _TotalBadge(label: '$weekTotal ml'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 210,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < days.length; i++)
                  Expanded(
                    child: _DayBar(
                      day: days[i],
                      amountMl: values[i],
                      heightFactor: maxValue == 0 ? 0 : values[i] / maxValue,
                      selected: DateUtils.isSameDay(days[i], selectedDay),
                      isProtected: protectedDays.contains(_dateOnly(days[i])),
                      onTap: () => onSelect(days[i]),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: edge,
            child: Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'Ayrıntılar için bir güne dokun',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.day,
    required this.amountMl,
    required this.heightFactor,
    required this.selected,
    required this.isProtected,
    required this.onTap,
  });

  final DateTime day;
  final int amountMl;
  final double heightFactor;
  final bool selected;

  /// Kaçırma hakkıyla korunan gün.
  final bool isProtected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final barColor = selected ? scheme.primary : scheme.primaryContainer;
    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label:
          '${_weekdayShort[day.weekday - 1]} ${day.day}, $amountMl ml'
          '${isProtected ? ', korundu' : ''}',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Her günde aynı yer ayrılır: çubuk yükseklikleri kıyaslanabilir kalır.
              SizedBox(
                height: 15,
                child: isProtected
                    ? Icon(
                        Icons.shield,
                        key: ValueKey('protected-${day.day}'),
                        size: 14,
                        color: const Color(0xFF3FA7D6),
                      )
                    : null,
              ),
              Text(
                amountMl == 0 ? '–' : _compactAmount(amountMl),
                maxLines: 1,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 24,
                      height: math.max(
                        amountMl == 0 ? 5 : 12,
                        constraints.maxHeight * heightFactor.clamp(0.0, 1.0),
                      ),
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(8),
                        border: selected
                            ? Border.all(
                                color: scheme.primary.withValues(alpha: 0.35),
                                width: 2,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _weekdayShort[day.weekday - 1],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
              Text(
                '${day.day}',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlyCalendar extends StatelessWidget {
  const _MonthlyCalendar({
    required this.month,
    required this.selectedDay,
    required this.totals,
    required this.protectedDays,
    required this.goalMl,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Map<DateTime, int> totals;
  final Set<DateTime> protectedDays;
  final int goalMl;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final dayCount = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = DateTime(month.year, month.month).weekday - 1;
    final monthDays = List.generate(
      dayCount,
      (index) => DateTime(month.year, month.month, index + 1),
    );
    final monthTotal = monthDays.fold<int>(
      0,
      (sum, day) => sum + (totals[_dateOnly(day)] ?? 0),
    );

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Aylık görünüm',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _TotalBadge(label: '$monthTotal ml'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final label in _weekdayShort)
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 0.78,
            ),
            itemCount: leadingEmpty + dayCount,
            itemBuilder: (context, index) {
              if (index < leadingEmpty) return const SizedBox.shrink();
              final day = monthDays[index - leadingEmpty];
              final amount = totals[_dateOnly(day)] ?? 0;
              return _MonthDay(
                day: day,
                amountMl: amount,
                goalMl: goalMl,
                selected: DateUtils.isSameDay(day, selectedDay),
                isProtected: protectedDays.contains(_dateOnly(day)),
                onTap: () => onSelect(day),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MonthDay extends StatelessWidget {
  const _MonthDay({
    required this.day,
    required this.amountMl,
    required this.goalMl,
    required this.selected,
    required this.isProtected,
    required this.onTap,
  });

  final DateTime day;
  final int amountMl;
  final int goalMl;
  final bool selected;
  final bool isProtected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = goalMl <= 0 ? 0.0 : (amountMl / goalMl).clamp(0.0, 1.0);
    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label:
          '${day.day} ${_monthNames[day.month - 1]}, $amountMl ml'
          '${isProtected ? ', korundu' : ''}',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(3, 5, 3, 4),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : scheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected ? null : clayShadows(context, scale: 0.2),
            border: selected
                ? Border.all(color: scheme.primary, width: 2)
                : null,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isProtected)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    Icons.shield,
                    key: ValueKey('protected-${day.day}'),
                    size: 11,
                    color: const Color(0xFF3FA7D6),
                  ),
                ),
              Column(
                children: [
                  Text(
                    '${day.day}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: scheme.surfaceContainerHighest,
                        color: progress >= 1 ? Colors.green : scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    amountMl == 0 ? '–' : _compactAmount(amountMl),
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(fontSize: 9, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayRecords extends StatelessWidget {
  const _DayRecords({
    required this.day,
    required this.entries,
    required this.isProtected,
    required this.totalMl,
    required this.goalMl,
    required this.onDelete,
    required this.onEdit,
    required this.onAdd,
  });

  final DateTime day;
  final List<WaterEntry> entries;
  final bool isProtected;
  final int totalMl;
  final int goalMl;
  final void Function(int id) onDelete;
  final void Function(WaterEntry entry) onEdit;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final progress = goalMl <= 0 ? 0.0 : (totalMl / goalMl).clamp(0.0, 1.0);
    final scheme = Theme.of(context).colorScheme;
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dateLabel(day),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalMl / $goalMl ml',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                '%${(progress * 100).round()}',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: scheme.primary),
              ),
            ],
          ),
          if (isProtected) ...[
            const SizedBox(height: 8),
            Row(
              key: const ValueKey('day-protected'),
              children: [
                const Icon(Icons.shield, size: 16, color: Color(0xFF3FA7D6)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Korundu: kaçırma hakkın kullanıldı, seri devam ediyor.',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: progress,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'Bu gün için su kaydı yok.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            )
          else
            for (final entry in entries)
              EntryTile(
                key: ValueKey('record-${entry.id}'),
                entry: entry,
                onEdit: () => onEdit(entry),
                onDelete: () => onDelete(entry.id),
              ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const ValueKey('records-add'),
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Kayıt ekle'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalBadge extends StatelessWidget {
  const _TotalBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

const _weekdayShort = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
const _monthNames = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _startOfWeek(DateTime date) =>
    _dateOnly(date).subtract(Duration(days: date.weekday - 1));

String _weekLabel(DateTime start) {
  final end = start.add(const Duration(days: 6));
  if (start.year != end.year) {
    return '${start.day} ${_monthNames[start.month - 1]} ${start.year} – '
        '${end.day} ${_monthNames[end.month - 1]} ${end.year}';
  }
  if (start.month == end.month) {
    return '${start.day}–${end.day} ${_monthNames[start.month - 1]} ${start.year}';
  }
  return '${start.day} ${_monthNames[start.month - 1]} – '
      '${end.day} ${_monthNames[end.month - 1]} ${end.year}';
}

String _monthLabel(DateTime month) =>
    '${_monthNames[month.month - 1]} ${month.year}';

String _dateLabel(DateTime date) {
  final today = _dateOnly(DateTime.now());
  if (DateUtils.isSameDay(date, today)) return 'Bugün';
  if (DateUtils.isSameDay(date, today.subtract(const Duration(days: 1)))) {
    return 'Dün';
  }
  return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
}

String _compactAmount(int amountMl) {
  if (amountMl < 1000) return '$amountMl';
  final liters = amountMl / 1000;
  return '${liters.toStringAsFixed(liters == liters.round() ? 0 : 1)}k';
}

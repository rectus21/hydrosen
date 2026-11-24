import 'package:flutter/material.dart';

import '../../domain/app_settings.dart';
import '../../domain/drink_type.dart';
import '../../domain/saved_container.dart';
import '../../domain/water_entry.dart';
import 'drink_widgets.dart';
import 'water_controller.dart';

/// Kayıt sayfasından dönen sonuç: kaydet (miktar/içecek/zaman) ya da sil.
class EntrySheetResult {
  const EntrySheetResult.save({
    required int this.amountMl,
    required DrinkType this.drink,
    required DateTime this.time,
  }) : delete = false;

  const EntrySheetResult.delete()
    : amountMl = null,
      drink = null,
      time = null,
      delete = true;

  final int? amountMl;
  final DrinkType? drink;
  final DateTime? time;
  final bool delete;
}

/// Kayıt ekleme/düzenleme sayfası. [entry] varsa düzenleme (Sil görünür);
/// yoksa [day] gününe ekleme: bugünse şimdiki saat, geçmiş günse 12:00.
Future<EntrySheetResult?> showEntrySheet(
  BuildContext context, {
  WaterEntry? entry,
  DateTime? day,
  DateTime? now,
  List<SavedContainer> containers = AppSettings.defaultContainers,
}) => showModalBottomSheet<EntrySheetResult>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => EntrySheet(
    entry: entry,
    day: day,
    now: now ?? DateTime.now(),
    containers: containers,
  ),
);

/// Bir kaydı düzenler: Kaydet yerinde günceller, Sil kaldırır.
Future<void> editEntryFlow(
  BuildContext context,
  WaterController controller,
  WaterEntry entry, {
  List<SavedContainer> containers = AppSettings.defaultContainers,
}) async {
  final result = await showEntrySheet(
    context,
    entry: entry,
    now: controller.now,
    containers: containers,
  );
  if (result == null) return;
  if (result.delete) {
    await controller.remove(entry.id);
  } else {
    await controller.update(
      entry.id,
      amountMl: result.amountMl,
      drink: result.drink,
      time: result.time,
    );
  }
}

/// [day] gününe yeni kayıt ekler.
Future<void> addEntryFlow(
  BuildContext context,
  WaterController controller,
  DateTime day, {
  List<SavedContainer> containers = AppSettings.defaultContainers,
}) async {
  final result = await showEntrySheet(
    context,
    day: day,
    now: controller.now,
    containers: containers,
  );
  if (result == null || result.delete) return;
  await controller.add(
    result.amountMl!,
    drink: result.drink!,
    time: result.time,
  );
}

class EntrySheet extends StatefulWidget {
  const EntrySheet({
    super.key,
    this.entry,
    this.day,
    required this.now,
    this.containers = AppSettings.defaultContainers,
  });

  final WaterEntry? entry;
  final DateTime? day;
  final DateTime now;
  final List<SavedContainer> containers;

  @override
  State<EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends State<EntrySheet> {
  late final TextEditingController _text;
  late DrinkType _drink;
  late DateTime _date;
  late TimeOfDay _time;
  String? _error;

  bool get _editing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    if (e != null) {
      _text = TextEditingController(text: '${e.amountMl}');
      _drink = e.drink;
      _date = DateUtils.dateOnly(e.time);
      _time = TimeOfDay.fromDateTime(e.time);
    } else {
      _text = TextEditingController();
      _drink = DrinkType.water;
      _date = DateUtils.dateOnly(widget.day ?? widget.now);
      _time = DateUtils.isSameDay(_date, widget.now)
          ? TimeOfDay.fromDateTime(widget.now)
          : const TimeOfDay(hour: 12, minute: 0);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  DateTime get _when =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(widget.now);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: DateTime(2020),
      lastDate: today,
      helpText: 'Gün seç',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Saat seç',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final ml = parseAmount(_text.text);
    if (ml == null) {
      setState(
        () => _error = '1–${SavedContainer.maxMl} arasında bir sayı gir',
      );
      return;
    }
    final when = _when;
    if (when.isAfter(widget.now)) {
      setState(() => _error = 'Gelecek bir saat seçemezsin');
      return;
    }
    Navigator.pop(
      context,
      EntrySheetResult.save(amountMl: ml, drink: _drink, time: when),
    );
  }

  String _dateLabel() {
    final today = DateUtils.dateOnly(widget.now);
    if (DateUtils.isSameDay(_date, today)) return 'Bugün';
    if (DateUtils.isSameDay(_date, today.subtract(const Duration(days: 1)))) {
      return 'Dün';
    }
    return '${_date.day} ${_months[_date.month - 1]} ${_date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final clock =
        '${_time.hour.toString().padLeft(2, '0')}:'
        '${_time.minute.toString().padLeft(2, '0')}';
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _editing ? 'Kaydı düzenle' : 'Kayıt ekle',
            style: text.titleLarge,
          ),
          const SizedBox(height: 14),
          TextField(
            key: const ValueKey('entry-amount'),
            controller: _text,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Miktar (ml)',
              hintText: 'Örn. 200',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _save(),
          ),
          const FieldLabel('Kaplarım'),
          ContainerChips(
            containers: widget.containers,
            onPick: (c) => setState(() {
              _text.text = '${c.ml}';
              _error = null;
            }),
          ),
          const FieldLabel('İçecek'),
          DrinkChips(
            selected: _drink,
            onSelected: (d) => setState(() => _drink = d),
          ),
          CountedHint(amountText: _text.text, drink: _drink),
          const FieldLabel('Gün ve saat'),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  key: const ValueKey('entry-date'),
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(_dateLabel()),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  key: const ValueKey('entry-time'),
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule_outlined, size: 18),
                  label: Text(clock),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (_editing) ...[
                OutlinedButton.icon(
                  key: const ValueKey('entry-delete'),
                  onPressed: () =>
                      Navigator.pop(context, const EntrySheetResult.delete()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.error,
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Sil'),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton(
                  key: const ValueKey('entry-save'),
                  onPressed: _save,
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _months = [
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

import 'package:flutter/material.dart';

import '../../domain/drink_type.dart';
import '../../domain/saved_container.dart';
import '../../domain/water_entry.dart';

/// İçecek türünün Material simgesi (emoji yok).
IconData drinkIcon(DrinkType drink) => switch (drink) {
  DrinkType.water => Icons.water_drop_outlined,
  DrinkType.mineral => Icons.bubble_chart_outlined,
  DrinkType.ayran => Icons.local_drink_outlined,
  DrinkType.tea => Icons.emoji_food_beverage_outlined,
  DrinkType.coffee => Icons.coffee_outlined,
};

/// Kayıt başlığı: su "200 ml", diğerleri "200 ml çay · 160 ml sayıldı".
String entryTitle(WaterEntry e) => e.drink == DrinkType.water
    ? '${e.amountMl} ml'
    : '${e.amountMl} ml ${e.drink.lowerLabel} · ${e.countedMl} ml sayıldı';

/// Miktar yazı alanındaki metni 1..[max] aralığında tam sayıya çevirir.
int? parseAmount(String text, {int max = SavedContainer.maxMl}) {
  final v = int.tryParse(text.trim());
  return v == null || v <= 0 || v > max ? null : v;
}

/// İçecek türü seçici: tek satıra sığmazsa alta sarar.
class DrinkChips extends StatelessWidget {
  const DrinkChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final DrinkType selected;
  final ValueChanged<DrinkType> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    runSpacing: 4,
    children: [
      for (final d in DrinkType.values)
        ChoiceChip(
          key: ValueKey('drink-chip-${d.id}'),
          avatar: Icon(drinkIcon(d), size: 18),
          label: Text(d.label),
          showCheckmark: false,
          selected: d == selected,
          onSelected: (_) => onSelected(d),
        ),
    ],
  );
}

/// Kayıtlı kap düğmeleri: dokununca miktarı doldurur.
class ContainerChips extends StatelessWidget {
  const ContainerChips({
    super.key,
    required this.containers,
    required this.onPick,
  });

  final List<SavedContainer> containers;
  final ValueChanged<SavedContainer> onPick;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    runSpacing: 4,
    children: [
      for (final c in containers)
        ActionChip(
          key: ValueKey('container-chip-${c.id}'),
          avatar: const Icon(Icons.local_cafe_outlined, size: 18),
          label: Text('${c.name} ${c.ml}'),
          onPressed: () => onPick(c),
        ),
    ],
  );
}

/// Küçük bölüm başlığı.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge),
  );
}

/// Canlı önizleme: "300 ml çay · 240 ml sayılır" (su için boş).
class CountedHint extends StatelessWidget {
  const CountedHint({super.key, required this.amountText, required this.drink});

  final String amountText;
  final DrinkType drink;

  @override
  Widget build(BuildContext context) {
    final ml = parseAmount(amountText);
    if (drink == DrinkType.water || ml == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        '$ml ml ${drink.lowerLabel} · ${drink.countedMl(ml)} ml sayılır',
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// Kayıt satırı (Günlük ve Kayıtlar): dokununca düzenler, çöp kutusu siler.
class EntryTile extends StatelessWidget {
  const EntryTile({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final WaterEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = entry.time;
    final clock =
        '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      onTap: onEdit,
      leading: Icon(drinkIcon(entry.drink)),
      title: Text(entryTitle(entry)),
      subtitle: Text(clock),
      trailing: IconButton(
        tooltip: 'Kaydı sil',
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}

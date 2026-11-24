import 'drink_type.dart';

class WaterEntry {
  const WaterEntry({
    required this.id,
    required this.amountMl,
    required this.time,
    this.drink = DrinkType.water,
  });

  final int id;

  /// Ham miktar (ml): bardağa dökülen. Toplamlar [countedMl] kullanır.
  final int amountMl;
  final DateTime time;
  final DrinkType drink;

  /// Hedefe sayılan miktar: `round(ml × oran)`.
  int get countedMl => drink.countedMl(amountMl);

  WaterEntry copyWith({int? amountMl, DateTime? time, DrinkType? drink}) =>
      WaterEntry(
        id: id,
        amountMl: amountMl ?? this.amountMl,
        time: time ?? this.time,
        drink: drink ?? this.drink,
      );

  /// Su kaydında 'd' alanı yazılmaz; eski sürümlerle aynı biçim kalır.
  Map<String, Object> toJson() => {
    'id': id,
    'ml': amountMl,
    't': time.toIso8601String(),
    if (drink != DrinkType.water) 'd': drink.id,
  };

  /// Geçersiz kayıtta [FormatException] veya [TypeError] fırlatır.
  factory WaterEntry.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final ml = json['ml'];
    final t = json['t'];
    if (id is! int || ml is! int || ml <= 0 || t is! String) {
      throw const FormatException('Geçersiz su kaydı');
    }
    return WaterEntry(
      id: id,
      amountMl: ml,
      time: DateTime.parse(t),
      drink: DrinkType.fromId(json['d']),
    );
  }
}

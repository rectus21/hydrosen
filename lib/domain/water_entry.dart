class WaterEntry {
  const WaterEntry({
    required this.id,
    required this.amountMl,
    required this.time,
  });

  final int id;
  final int amountMl;
  final DateTime time;

  Map<String, Object> toJson() => {
    'id': id,
    'ml': amountMl,
    't': time.toIso8601String(),
  };

  /// Geçersiz kayıtta [FormatException] veya [TypeError] fırlatır.
  factory WaterEntry.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final ml = json['ml'];
    final t = json['t'];
    if (id is! int || ml is! int || ml <= 0 || t is! String) {
      throw const FormatException('Geçersiz su kaydı');
    }
    return WaterEntry(id: id, amountMl: ml, time: DateTime.parse(t));
  }
}

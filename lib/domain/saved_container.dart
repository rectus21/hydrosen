/// Kayıtlı kap: kullanıcının adlandırdığı hazır miktar (bardak, kupa, matara).
class SavedContainer {
  const SavedContainer({
    required this.id,
    required this.name,
    required this.ml,
  });

  static const maxNameLength = 16;
  static const minMl = 1;
  static const maxMl = 5000;

  final int id;
  final String name;
  final int ml;

  SavedContainer copyWith({String? name, int? ml}) =>
      SavedContainer(id: id, name: name ?? this.name, ml: ml ?? this.ml);

  Map<String, Object> toJson() => {'id': id, 'name': name, 'ml': ml};

  /// Geçersizse [FormatException] fırlatır.
  factory SavedContainer.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final name = json['name'];
    final ml = json['ml'];
    if (id is! int ||
        name is! String ||
        ml is! int ||
        ml < minMl ||
        ml > maxMl) {
      throw const FormatException('Geçersiz kap');
    }
    return SavedContainer(id: id, name: normalizeName(name), ml: ml);
  }

  /// Boşlukları kırpar ve uzunluğu sınırlar.
  static String normalizeName(String name) {
    final t = name.trim();
    return t.length > maxNameLength ? t.substring(0, maxNameLength) : t;
  }

  @override
  bool operator ==(Object other) =>
      other is SavedContainer &&
      other.id == id &&
      other.name == name &&
      other.ml == ml;

  @override
  int get hashCode => Object.hash(id, name, ml);
}

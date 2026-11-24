import '../features/thermos/thermos_theme.dart';
import 'bottle_name.dart';
import 'saved_container.dart';

/// Kullanıcının kalıcı tercihleri: termos biçimi, tema ve günlük hedef.
class AppSettings {
  const AppSettings({
    this.shape = ThermosShape.chubby,
    this.theme = ThermosTheme.classic,
    this.goalMl = defaultGoalMl,
    this.glassMl = defaultGlassMl,
    this.animatedCelebrations = true,
    this.containers = defaultContainers,
    this.bottleNames = const {},
  });

  /// Varsayılan kayıtlı kaplar.
  static const defaultContainers = [
    SavedContainer(id: 1, name: 'Bardak', ml: 200),
    SavedContainer(id: 2, name: 'Kupa', ml: 300),
    SavedContainer(id: 3, name: 'Matara', ml: 500),
  ];
  static const maxContainers = 8;

  static const defaultGoalMl = 2000;
  static const minGoalMl = 500;
  static const maxGoalMl = 5000;
  static const goalStepMl = 100;

  static const defaultGlassMl = 200;
  static const minGlassMl = 150;
  static const maxGlassMl = 500;
  static const glassStepMl = 50;

  final ThermosShape shape;
  final ThermosTheme theme;
  final int goalMl;

  /// Bir bardağın hacmi (ml).
  final int glassMl;

  /// Hedefte karakter hareketi: açıkken sistem "animasyonları azalt" dese de
  /// kutlamalar oynar.
  final bool animatedCelebrations;

  /// Kayıtlı kaplar (en az 1, en çok [maxContainers]).
  final List<SavedContainer> containers;

  /// Tema kimliği -> kullanıcının verdiği matara/karakter adı. Yalnız özel
  /// adlar saklanır; yoksa tema adı kullanılır.
  final Map<String, String> bottleNames;

  /// [theme] için kullanıcının verdiği ad; verilmediyse null.
  String? customBottleName(ThermosTheme theme) => bottleNames[theme.id];

  /// Matara/karakter adı: özel ad, yoksa tema adı.
  String bottleName(ThermosTheme theme) =>
      customBottleName(theme) ?? theme.name;

  /// Saklanan adları süzer: geçersiz/uygunsuz/boş olanlar atılır.
  static Map<String, String> sanitizeBottleNames(Map<String, Object?> raw) {
    final out = <String, String>{};
    raw.forEach((id, value) {
      if (value is! String) return;
      final r = BottleName.validate(value);
      final name = r.name;
      if (r.isOk && name != null && name.isNotEmpty) out[id] = name;
    });
    return out;
  }

  /// Hedefi adıma yuvarlar ve sınırlara çeker.
  static int normalizeGoal(int ml) {
    final snapped = (ml / goalStepMl).round() * goalStepMl;
    return snapped.clamp(minGoalMl, maxGoalMl);
  }

  /// Bardağı adıma yuvarlar ve sınırlara çeker.
  static int normalizeGlass(int ml) {
    final snapped = (ml / glassStepMl).round() * glassStepMl;
    return snapped.clamp(minGlassMl, maxGlassMl);
  }

  AppSettings copyWith({
    ThermosShape? shape,
    ThermosTheme? theme,
    int? goalMl,
    int? glassMl,
    bool? animatedCelebrations,
    List<SavedContainer>? containers,
    Map<String, String>? bottleNames,
  }) => AppSettings(
    shape: shape ?? this.shape,
    theme: theme ?? this.theme,
    goalMl: goalMl ?? this.goalMl,
    glassMl: glassMl ?? this.glassMl,
    animatedCelebrations: animatedCelebrations ?? this.animatedCelebrations,
    containers: containers ?? this.containers,
    bottleNames: bottleNames ?? this.bottleNames,
  );
}

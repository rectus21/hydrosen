import '../features/thermos/thermos_theme.dart';

/// Kullanıcının kalıcı tercihleri: termos biçimi, tema ve günlük hedef.
class AppSettings {
  const AppSettings({
    this.shape = ThermosShape.chubby,
    this.theme = ThermosTheme.classic,
    this.goalMl = defaultGoalMl,
    this.glassMl = defaultGlassMl,
  });

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
  }) => AppSettings(
    shape: shape ?? this.shape,
    theme: theme ?? this.theme,
    goalMl: goalMl ?? this.goalMl,
    glassMl: glassMl ?? this.glassMl,
  );
}

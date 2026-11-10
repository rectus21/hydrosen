import '../features/thermos/thermos_theme.dart';

/// Kullanıcının kalıcı tercihleri: termos biçimi, tema ve günlük hedef.
class AppSettings {
  const AppSettings({
    this.shape = ThermosShape.chubby,
    this.theme = ThermosTheme.classic,
    this.goalMl = defaultGoalMl,
  });

  static const defaultGoalMl = 2000;
  static const minGoalMl = 500;
  static const maxGoalMl = 5000;
  static const goalStepMl = 100;

  final ThermosShape shape;
  final ThermosTheme theme;
  final int goalMl;

  /// Hedefi adıma yuvarlar ve sınırlara çeker.
  static int normalizeGoal(int ml) {
    final snapped = (ml / goalStepMl).round() * goalStepMl;
    return snapped.clamp(minGoalMl, maxGoalMl);
  }

  AppSettings copyWith({
    ThermosShape? shape,
    ThermosTheme? theme,
    int? goalMl,
  }) => AppSettings(
    shape: shape ?? this.shape,
    theme: theme ?? this.theme,
    goalMl: goalMl ?? this.goalMl,
  );
}

import '../../domain/backup.dart';
import '../home/reminder_controller.dart';
import '../home/water_controller.dart';
import '../settings/settings_controller.dart';

/// Yedek alma ve geri yükleme: denetleyicilerden veriyi toplar, yedekten gelen
/// veriyi geri koyar. Dosya okuma/yazma burada değildir ([BackupFileIO]).
///
/// Yedeklenmeyenler: hatırlatıcının günlük sayaçları ve geri alma geçmişi.
///
/// Not (2026-11-25): uygulama tamamen ücretsizdir; tüm temalar herkese açık
/// (tema kilidi ve satın alma yok), bu yüzden yedekte böyle bir veri de yok.
class BackupService {
  BackupService({required this.water, required this.settings, this.reminder});

  final WaterController water;
  final SettingsController settings;
  final ReminderController? reminder;

  /// Şu anki tüm veri.
  BackupData collect() => BackupData(
    entries: water.allEntries,
    settings: settings.settings,
    reminder: reminder?.settings,
    streak: water.streakData,
  );

  /// Yedek dosyasının metni.
  String export({DateTime? now}) => BackupCodec.encode(collect(), now: now);

  /// Geçerli (doğrulanmış) yedeği uygular: mevcut verinin YERİNE GEÇER.
  ///
  /// Sıra: kayıtlar+seri, ayarlar, hatırlatıcı. Kayıtlar ya da ayarlar
  /// yazılamazsa önceki adımlar geri alınır ve [BackupException] fırlar;
  /// veri eski hâlinde kalır. Yedekte olmayan isteğe bağlı bölümler (ayarlar,
  /// hatırlatıcı) mevcut değerleriyle kalır; seri yoksa kayıtlardan kurulur.
  ///
  Future<void> restore(BackupData data) async {
    final before = collect();
    final newSettings = data.settings;
    try {
      await water.replaceAll(
        data.entries,
        streak: data.streak,
        goalMl: newSettings?.goalMl,
      );
    } catch (_) {
      throw const BackupException(
        'Geri yükleme yapılamadı, verilerin olduğu gibi duruyor.',
      );
    }
    if (newSettings != null) {
      try {
        await settings.restore(newSettings);
      } catch (_) {
        try {
          await water.replaceAll(
            before.entries,
            streak: before.streak,
            goalMl: before.settings?.goalMl,
          );
        } catch (_) {
          // Geri alma da yazılamadı; bellek eski veriye döndü.
        }
        throw const BackupException(
          'Geri yükleme yapılamadı, verilerin olduğu gibi duruyor.',
        );
      }
    }
    final r = data.reminder;
    if (r != null) await reminder?.apply(r);
  }
}

import '../../domain/reminder_planner.dart';

/// Bir hatırlatmanın içeriği; teslimat kanalından bağımsızdır.
class ReminderMessage {
  const ReminderMessage({
    required this.title,
    required this.body,
    required this.themeId,
    this.kind = ReminderKind.normal,
  });

  /// Bildirim başlığı (uygulama adı).
  final String title;

  /// Karakterin "susadım" cümlesi (mataranın adıyla).
  final String body;
  final String themeId;
  final ReminderKind kind;

  /// Karakter kapağının uygulama içi varlık yolu (bildirim simgesi için).
  String get capAsset => 'assets/caps/${themeId}_normal.png';
}

/// Bildirim izninin durumu.
enum ReminderPermission {
  /// Bu kanal bu platformda çalışmaz.
  unsupported,

  /// Henüz sorulmadı.
  notAsked,
  granted,
  denied,
}

/// Hatırlatma teslim kanalı. Planlama (ReminderPlanner) kanaldan bağımsızdır;
/// yeni bir kanal eklemek yalnızca bu arayüzü uygulamaktır.
abstract class ReminderNotifier {
  /// Kanal bu platformda kullanılabilir mi.
  bool get supported;

  /// Güncel izin durumu.
  ReminderPermission get permission;

  /// İzin ister. Tarayıcılar yalnızca **kullanıcı dokunuşundan** çağrılırsa
  /// izin penceresi açar; bu yüzden yalnız bir düğme dokunuşundan çağır.
  Future<ReminderPermission> requestPermission();

  /// Hatırlatmayı gösterir; gösterilemediyse (izin yok, sekme açık vb.) false.
  Future<bool> show(ReminderMessage message);
}

/// Uygulama açıkken görünen hatırlatma: ev ekranı bir banner gösterir.
class InAppReminderNotifier implements ReminderNotifier {
  InAppReminderNotifier(this.onShow);

  final void Function(ReminderMessage message) onShow;

  @override
  bool get supported => true;

  @override
  ReminderPermission get permission => ReminderPermission.granted;

  @override
  Future<ReminderPermission> requestPermission() async => permission;

  @override
  Future<bool> show(ReminderMessage message) async {
    onShow(message);
    return true;
  }
}

/// Birden çok kanala aynı anda teslim eder. Kanallardan biri hata verirse
/// diğerleri etkilenmez.
class ReminderDelivery {
  ReminderDelivery(this.channels);

  final List<ReminderNotifier> channels;

  /// Mesajı her kanala gönderir; en az biri gösterdiyse true.
  Future<bool> deliver(ReminderMessage message) async {
    var any = false;
    for (final c in channels) {
      try {
        if (await c.show(message)) any = true;
      } catch (_) {
        // Bir kanalın hatası diğerini engellemesin.
      }
    }
    return any;
  }
}

/// TODO(mobil): Android/iOS yerel bildirimi.
///
/// Projede şu an `android/` ve `ios/` klasörü yok; bu yüzden bu sınıf yalnızca
/// bir yer tutucudur ve kanal "desteklenmiyor" der. Platform klasörleri
/// eklenince şunlar yapılacak:
///
/// 1. `pubspec.yaml`: `flutter_local_notifications` ve `timezone`
///    (+ `flutter_timezone`) paketlerini ekle.
/// 2. Android: `POST_NOTIFICATIONS` (API 33+) izni; tam zamanlı alarm yerine
///    tercihen `inexact` zamanlama; bildirim kanalı "Su hatırlatma".
/// 3. `requestPermission()` içinde platform iznini iste (yine bir dokunuştan).
/// 4. Zamanlama: `ReminderPlanner.plan` sonucundaki `at` için tek seferlik
///    `zonedSchedule` kur (tekrarlayan değil, tek tek planla; plan her su
///    kaydında ve her ayar değişiminde iptal edilip yeniden hesaplanır).
///    Uygulama kapalıyken "son içmeden itibaren" mantığı yalnızca bildirim
///    planlandığı andaki bilgiyle çalışır; bu yüzden birkaç hatırlatma ileriye
///    (günlük üst sınır kadar) kurup her açılışta yeniden hesapla.
/// 5. Metin: `ReminderMessages.pick`; simge olarak kapak PNG'si.
/// 6. Cihazda dene: üretici pil kısıtları (Xiaomi, Huawei, Samsung)
///    bildirimleri geciktirebilir. Web'de denenemez.
class LocalNotificationsReminderNotifier implements ReminderNotifier {
  @override
  bool get supported => false;

  @override
  ReminderPermission get permission => ReminderPermission.unsupported;

  @override
  Future<ReminderPermission> requestPermission() async => permission;

  @override
  Future<bool> show(ReminderMessage message) async => false;
}

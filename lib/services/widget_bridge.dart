import 'package:flutter/foundation.dart';

import '../domain/widget_snapshot.dart';
import '../features/home/water_controller.dart';
import '../features/settings/settings_controller.dart';

/// Uygulama ile telefonun ana ekran widget'ı arasındaki köprü. Veri değiştikçe
/// [update] çağrılır; şimdilik [NoopWidgetBridge] hiçbir şey yapmaz.
///
/// GELECEK ADIMLAR (Android/iOS klasörleri ve SDK gelince; şimdi YAPILMADI):
///
/// 1. Paket: `home_widget` eklenir. Köprünün gerçek uygulaması
///    `HomeWidget.saveWidgetData('snapshot', jsonEncode(snapshot.toJson()))`
///    ve ardından `HomeWidget.updateWidget(...)` çağırır.
/// 2. Android: `AppWidgetProvider` alt sınıfı + `res/xml/hydrosen_widget_info.xml`
///    (2x2 ve 4x2 için minWidth/minHeight, updatePeriodMillis=0; güncelleme
///    uygulamadan gelir) + `res/layout/hydrosen_widget.xml` (karakter resmi,
///    "1200 / 2000 ml", ilerleme halkası, "12. gün"). `AndroidManifest.xml`'e
///    receiver eklenir. Veriyi `HomeWidgetPlugin.getData(context)` okur.
/// 3. iOS: Xcode'da WidgetKit uzantısı (Widget Extension) eklenir; uygulama ile
///    uzantı bir App Group'u (`group.<paket>.hydrosen`) paylaşır ve
///    `home_widget` veriyi o grubun UserDefaults'una yazar. SwiftUI görünümü
///    aynı alanları okur. Sistem, `WidgetCenter.shared.reloadAllTimelines()`
///    ile yenilenir.
/// 4. Etkileşimli "+1 bardak": Android'de widget'taki düğme bir
///    `PendingIntent` ile arka plan çağrısı (`HomeWidgetBackgroundIntent`)
///    tetikler; Dart tarafında `HomeWidget.registerInteractivityCallback`
///    kaydı "bardak ekle" işini çalıştırır (kayıt eklenir, sonra köprü yeni
///    görüntüyü yazar). iOS 17+ için aynısı `AppIntent` ile yapılır. Bu işler
///    arayüz açık olmadan çalışabilir; bu yüzden kayıt ekleme mantığı
///    arayüzden bağımsız bir sınıfa taşınmalıdır.
abstract class WidgetBridge {
  Future<void> update(WidgetSnapshot snapshot);
}

/// Şimdilik hiçbir şey yapmayan köprü.
class NoopWidgetBridge implements WidgetBridge {
  const NoopWidgetBridge();

  @override
  Future<void> update(WidgetSnapshot snapshot) async {}
}

/// Su ve ayar denetleyicilerini dinler; görüntü DEĞİŞTİĞİNDE (ve ilk yüklemede)
/// köprüye gönderir. Aynı görüntü ikinci kez gönderilmez.
class WidgetSnapshotPublisher {
  WidgetSnapshotPublisher({
    required this.water,
    required this.settings,
    required this.bridge,
  }) {
    water.addListener(_check);
    settings.addListener(_check);
    _check();
  }

  final WaterController water;
  final SettingsController settings;
  final WidgetBridge bridge;

  WidgetSnapshot? _last;

  /// Son gönderilen görüntü (yoksa null).
  WidgetSnapshot? get last => _last;

  /// Şu anki durumdan görüntü; veriler yüklenmediyse null.
  WidgetSnapshot? get current {
    if (!water.loaded || !settings.loaded) return null;
    return WidgetSnapshot(
      todayMl: water.totalMl,
      goalMl: water.goalMl,
      streakDay: water.streak.current,
      themeId: settings.theme.id,
      characterName: settings.bottleName,
    );
  }

  void _check() {
    final next = current;
    if (next == null || next == _last) return;
    _last = next;
    bridge.update(next).catchError((Object e) {
      // Köprü hatası uygulamayı etkilemesin.
      debugPrint('WidgetBridge: $e');
    });
  }

  void dispose() {
    water.removeListener(_check);
    settings.removeListener(_check);
  }
}

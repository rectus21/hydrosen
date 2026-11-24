import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'reminder_notifier.dart';

/// Tarayıcı bildirimi (Notification API).
ReminderNotifier createWebNotifier() => _WebReminderNotifier();

class _WebReminderNotifier implements ReminderNotifier {
  @override
  bool get supported => globalContext.has('Notification');

  @override
  ReminderPermission get permission {
    if (!supported) return ReminderPermission.unsupported;
    return switch (web.Notification.permission) {
      'granted' => ReminderPermission.granted,
      'denied' => ReminderPermission.denied,
      _ => ReminderPermission.notAsked,
    };
  }

  @override
  Future<ReminderPermission> requestPermission() async {
    if (!supported) return ReminderPermission.unsupported;
    try {
      await web.Notification.requestPermission().toDart;
    } catch (_) {
      // İzin penceresi açılamadı; durum aşağıda okunur.
    }
    return permission;
  }

  @override
  Future<bool> show(ReminderMessage message) async {
    if (permission != ReminderPermission.granted) return false;
    // Sekme görünürken uygulama içi banner yeter; bildirim yalnız sekme
    // arka plandayken ya da pencere gizliyken gösterilir.
    if (web.document.visibilityState == 'visible') return false;
    try {
      final icon = Uri.base.resolve('assets/${message.capAsset}').toString();
      web.Notification(
        message.title,
        web.NotificationOptions(
          body: message.body,
          icon: icon,
          tag: 'hydrosen-reminder',
        ),
      );
      return true;
    } catch (_) {
      // Bazı mobil tarayıcılar `new Notification` yerine service worker ister;
      // sessizce vazgeçilir (uygulama içi banner zaten gösterilmiştir).
      return false;
    }
  }
}

import 'reminder_notifier.dart';

/// Web dışı platformlarda tarayıcı bildirimi yoktur.
ReminderNotifier createWebNotifier() => _UnsupportedWebNotifier();

class _UnsupportedWebNotifier implements ReminderNotifier {
  @override
  bool get supported => false;

  @override
  ReminderPermission get permission => ReminderPermission.unsupported;

  @override
  Future<ReminderPermission> requestPermission() async => permission;

  @override
  Future<bool> show(ReminderMessage message) async => false;
}

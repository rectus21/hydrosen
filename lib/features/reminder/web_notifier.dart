// Tarayıcıda gerçek Notification API, diğer platformlarda boş bir kanal.
export 'web_notifier_stub.dart'
    if (dart.library.js_interop) 'web_notifier_web.dart';

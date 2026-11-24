import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'backup_io_base.dart';

/// Tarayıcıda yedek: Blob + gizli bağlantı ile indirme, `<input type=file>`
/// ile seçme.
BackupFileIO createBackupFileIO() => _WebBackupFileIO();

class _WebBackupFileIO implements BackupFileIO {
  @override
  bool get canSave => true;

  @override
  bool get canPick => true;

  @override
  Future<bool> saveFile({
    required String fileName,
    required String content,
  }) async {
    try {
      final blob = web.Blob(
        [content.toJS].toJS,
        web.BlobPropertyBag(type: 'application/json'),
      );
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = fileName
        ..style.display = 'none';
      web.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      // İndirme başlayınca adres serbest bırakılır.
      Timer(const Duration(seconds: 5), () => web.URL.revokeObjectURL(url));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> pickFileText() {
    final completer = Completer<String?>();
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = '.json,application/json'
      ..style.display = 'none';
    void done(String? value) {
      if (!completer.isCompleted) completer.complete(value);
      input.remove();
    }

    input.addEventListener(
      'change',
      ((web.Event _) {
        final files = input.files;
        if (files == null || files.length == 0) {
          done(null);
          return;
        }
        files
            .item(0)!
            .text()
            .toDart
            .then(
              (text) => done(text.toDart),
              onError: (Object _) => done(null),
            );
      }).toJS,
    );
    // Seçici vazgeçilirse (modern tarayıcılarda) "cancel" olayı gelir.
    input.addEventListener('cancel', ((web.Event _) => done(null)).toJS);
    web.document.body?.append(input);
    input.click();
    return completer.future;
  }
}

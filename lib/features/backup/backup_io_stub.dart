import 'backup_io_base.dart';

/// Web dışı platformlarda şimdilik dosya kanalı yok.
BackupFileIO createBackupFileIO() => const UnsupportedBackupFileIO();

/// TODO(telefon sürümü): Android/iOS için paylaşım sayfası.
/// - Kaydetme: yedek metni geçici dizine `hydrosen-yedek-YYYY-MM-DD.json` olarak
///   yazılır ve `share_plus` ile paylaşım sayfası (Drive, e-posta, Dosyalar)
///   açılır.
/// - Seçme: `file_picker` ile .json seçilir ve metni okunur.
/// Arayüz [BackupFileIO]'yu kullandığından yalnız bu sınıf değişecek.
class UnsupportedBackupFileIO implements BackupFileIO {
  const UnsupportedBackupFileIO();

  @override
  bool get canSave => false;

  @override
  bool get canPick => false;

  @override
  Future<bool> saveFile({
    required String fileName,
    required String content,
  }) async => false;

  @override
  Future<String?> pickFileText() async => null;
}

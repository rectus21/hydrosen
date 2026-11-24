/// Yedek dosyasını cihaza yazma ve cihazdan okuma. Arayüz ve testler yalnız bunu
/// bilir; web uygulaması `backup_io_web.dart`, diğerleri `backup_io_stub.dart`.
abstract class BackupFileIO {
  /// Bu platformda dosya kaydedilebiliyor mu.
  bool get canSave;

  /// Bu platformda dosya seçilebiliyor mu.
  bool get canPick;

  /// [content] metnini [fileName] adıyla kaydeder/indirir. Başarılıysa true.
  Future<bool> saveFile({required String fileName, required String content});

  /// Kullanıcıya bir .json dosyası seçtirir ve metnini döner; vazgeçtiyse null.
  Future<String?> pickFileText();
}

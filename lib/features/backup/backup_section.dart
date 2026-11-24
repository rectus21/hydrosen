import 'package:flutter/material.dart';

import '../../app/frosted_panel.dart';
import '../../domain/backup.dart';
import 'backup_io.dart';
import 'backup_service.dart';

/// Profil'deki "Yedekle ve geri yükle" bölümü.
class BackupSection extends StatefulWidget {
  const BackupSection({super.key, required this.service, this.io, this.now});

  final BackupService service;

  /// Verilmezse platformun dosya kanalı ([createBackupFileIO]).
  final BackupFileIO? io;

  /// Testlerde sabit saat.
  final DateTime Function()? now;

  @override
  State<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends State<BackupSection> {
  late final BackupFileIO _io = widget.io ?? createBackupFileIO();
  String? _error;
  bool _busy = false;

  DateTime get _now => (widget.now ?? DateTime.now)();

  void _toast(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _export() async {
    setState(() => _error = null);
    final name = BackupCodec.fileName(_now);
    final ok = await _io.saveFile(
      fileName: name,
      content: widget.service.export(now: _now),
    );
    if (!mounted) return;
    if (ok) {
      _toast('Yedek dosyası hazır: $name');
    } else {
      setState(
        () => _error = _io.canSave
            ? 'Yedek dosyası oluşturulamadı. Tekrar dene.'
            : 'Yedek dosyası telefon sürümüyle gelecek.',
      );
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      final text = await _io.pickFileText();
      if (!mounted) return;
      if (text == null) {
        if (!_io.canPick) {
          setState(() => _error = 'Geri yükleme telefon sürümüyle gelecek.');
        }
        return;
      }
      final BackupData data;
      try {
        data = BackupCodec.decode(text);
      } on BackupException catch (e) {
        setState(() => _error = e.message);
        return;
      }
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => _ConfirmDialog(summary: BackupSummary.of(data).text),
      );
      if (ok != true || !mounted) return;
      try {
        await widget.service.restore(data);
        if (mounted) _toast('Yedek geri yüklendi.');
      } on BackupException catch (e) {
        if (mounted) setState(() => _error = e.message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return FrostedPanel(
      key: const ValueKey('backup-section'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('Yedekle ve geri yükle', style: text.titleLarge),
          ),
          const SizedBox(height: 6),
          Text(
            'Kayıtların, ayarların ve rozetlerin tek bir dosyada saklanır; '
            'istediğin zaman geri yükleyebilirsin.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const ValueKey('backup-export'),
            style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: _busy ? null : _export,
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Yedek dosyası oluştur'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const ValueKey('backup-restore'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: _busy ? null : _restore,
            icon: const Icon(Icons.file_upload_outlined),
            label: const Text('Yedekten geri yükle'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  key: const ValueKey('backup-error'),
                  style: TextStyle(color: scheme.error),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) => AlertDialog(
    key: const ValueKey('backup-confirm'),
    title: const Text('Yedek geri yüklensin mi?'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary,
          key: const ValueKey('backup-summary'),
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text('Mevcut verilerin yerini alır.'),
      ],
    ),
    actions: [
      TextButton(
        key: const ValueKey('backup-confirm-cancel'),
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Vazgeç'),
      ),
      FilledButton(
        key: const ValueKey('backup-confirm-ok'),
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Geri yükle'),
      ),
    ],
  );
}

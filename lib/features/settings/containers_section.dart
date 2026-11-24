import 'package:flutter/material.dart';

import '../../app/frosted_panel.dart';
import '../../domain/app_settings.dart';
import '../../domain/saved_container.dart';
import 'settings_controller.dart';

/// "Kaplarım": kayıtlı kapları listeler; ad/miktar düzenler, ekler, siler
/// (en az bir kap kalır).
class ContainersSection extends StatelessWidget {
  const ContainersSection({super.key, required this.controller});

  final SettingsController controller;

  Future<void> _edit(BuildContext context, SavedContainer? existing) async {
    final result = await showDialog<({String name, int ml})>(
      context: context,
      builder: (_) => ContainerDialog(existing: existing),
    );
    if (result == null) return;
    if (existing == null) {
      await controller.addContainer(result.name, result.ml);
    } else {
      await controller.updateContainer(
        existing.id,
        name: result.name,
        ml: result.ml,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final list = controller.containers;
    final canDelete = list.length > 1;
    final canAdd = list.length < AppSettings.maxContainers;
    return FrostedPanel(
      key: const ValueKey('containers-section'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kaplarım', style: text.titleMedium),
          const SizedBox(height: 2),
          Text(
            'Özel miktar penceresinde tek dokunuşla seçersin.',
            style: text.bodySmall,
          ),
          const SizedBox(height: 4),
          for (final c in list)
            ListTile(
              key: ValueKey('container-${c.id}'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.local_cafe_outlined),
              title: Text(
                '${c.name} · ${c.ml} ml',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _edit(context, c),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: ValueKey('container-edit-${c.id}'),
                    tooltip: 'Kabı düzenle',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _edit(context, c),
                  ),
                  IconButton(
                    key: ValueKey('container-delete-${c.id}'),
                    tooltip: canDelete ? 'Kabı sil' : 'En az bir kap kalmalı',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: canDelete
                        ? () => controller.removeContainer(c.id)
                        : null,
                  ),
                ],
              ),
            ),
          if (canAdd)
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                key: const ValueKey('container-add'),
                onPressed: () => _edit(context, null),
                icon: const Icon(Icons.add),
                label: const Text('Kap ekle'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Kap ekleme/düzenleme penceresi: ad ve miktar.
class ContainerDialog extends StatefulWidget {
  const ContainerDialog({super.key, this.existing});

  final SavedContainer? existing;

  @override
  State<ContainerDialog> createState() => _ContainerDialogState();
}

class _ContainerDialogState extends State<ContainerDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _ml = TextEditingController(
    text: widget.existing == null ? '' : '${widget.existing!.ml}',
  );
  String? _nameError;
  String? _mlError;

  @override
  void dispose() {
    _name.dispose();
    _ml.dispose();
    super.dispose();
  }

  void _submit() {
    final name = SavedContainer.normalizeName(_name.text);
    final ml = int.tryParse(_ml.text.trim());
    final nameBad = name.isEmpty;
    final mlBad =
        ml == null || ml < SavedContainer.minMl || ml > SavedContainer.maxMl;
    if (nameBad || mlBad) {
      setState(() {
        _nameError = nameBad ? 'Bir ad yaz' : null;
        _mlError = mlBad
            ? '${SavedContainer.minMl}–${SavedContainer.maxMl} arasında bir sayı gir'
            : null;
      });
      return;
    }
    Navigator.pop(context, (name: name, ml: ml));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(widget.existing == null ? 'Kap ekle' : 'Kabı düzenle'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const ValueKey('container-name'),
              controller: _name,
              autofocus: true,
              maxLength: SavedContainer.maxNameLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Ad',
                hintText: 'Örn. Şişe',
                errorText: _nameError,
              ),
            ),
            TextField(
              key: const ValueKey('container-ml'),
              controller: _ml,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Miktar (ml)',
                hintText: 'Örn. 250',
                errorText: _mlError,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          key: const ValueKey('container-save'),
          onPressed: _submit,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

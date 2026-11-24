import 'package:flutter/material.dart';

import '../../app/frosted_panel.dart';
import '../../domain/bottle_name.dart';
import '../reminder/character_avatar.dart';
import 'settings_controller.dart';

/// Profil sekmesinde sıcak bir kart: çocuk karakterine/matarasına isim verir.
/// İsim her temada ayrıdır; boş bırakılırsa tema adı kullanılır.
class BottleNameCard extends StatelessWidget {
  const BottleNameCard({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: settings,
    // Tema değişince alan kendi temasının adıyla yeniden kurulur.
    builder: (context, _) => _BottleNameForm(
      key: ValueKey('bottle-form-${settings.theme.id}'),
      settings: settings,
    ),
  );
}

class _BottleNameForm extends StatefulWidget {
  const _BottleNameForm({super.key, required this.settings});

  final SettingsController settings;

  @override
  State<_BottleNameForm> createState() => _BottleNameFormState();
}

class _BottleNameFormState extends State<_BottleNameForm> {
  late final TextEditingController _text = TextEditingController(
    text: widget.settings.customBottleName ?? '',
  );
  String? _error;
  String? _ok;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final theme = widget.settings.theme;
    final result = await widget.settings.setBottleName(theme, _text.text);
    if (!mounted) return;
    setState(() {
      _error = result.message;
      if (result.isOk) {
        final name = widget.settings.bottleNameOf(theme);
        _text.text = widget.settings.customBottleName ?? '';
        _ok = widget.settings.customBottleName == null
            ? 'İsim tema adına döndü: $name.'
            : 'Güzel isim! $name artık seninle.';
      } else {
        _ok = null;
      }
    });
    if (result.isOk) FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.settings.theme;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return FrostedPanel(
      key: const ValueKey('bottle-name-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CharacterAvatar(theme: theme, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Karakterine bir isim ver',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${theme.name} temasının adı şimdi: '
                      '${widget.settings.bottleName}',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('bottle-name-field'),
            controller: _text,
            maxLength: BottleName.maxLength,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: 'Matara adı',
              hintText: theme.name,
              prefixIcon: const Icon(Icons.favorite_border),
              errorText: _error,
              errorMaxLines: 2,
              helperText: 'Boş bırakırsan ad "${theme.name}" olur.',
              helperMaxLines: 2,
            ),
          ),
          if (_ok != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _ok!,
                key: const ValueKey('bottle-name-ok'),
                style: text.bodyMedium?.copyWith(color: scheme.primary),
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: const ValueKey('bottle-name-save'),
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}

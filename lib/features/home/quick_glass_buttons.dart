import 'package:flutter/material.dart';

import 'resin_button.dart';

/// Bardak sırasının altında hızlı düğmeler: ortada büyük "İç" (+1 bardak),
/// solunda "−1 bardak", sağında "+2 bardak". [onRemove] null ise (bugün hiç
/// su yok) çıkarma düğmesi pasiftir.
class QuickGlassButtons extends StatelessWidget {
  const QuickGlassButtons({
    super.key,
    required this.glassMl,
    required this.onAdd,
    required this.onRemove,
  });

  final int glassMl;
  final void Function(int glasses) onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SideButton(
          key: const ValueKey('quick-remove-1'),
          title: '−1 bardak',
          sub: '$glassMl ml',
          outlined: true,
          onPressed: onRemove,
        ),
        const SizedBox(width: 14),
        _DrinkButton(
          key: const ValueKey('quick-add-1'),
          sub: '$glassMl ml',
          onPressed: () => onAdd(1),
        ),
        const SizedBox(width: 14),
        _SideButton(
          key: const ValueKey('quick-add-2'),
          title: '+2 bardak',
          sub: '${glassMl * 2} ml',
          onPressed: () => onAdd(2),
        ),
      ],
    );
  }
}

/// Küçük yan düğme (79 x 55): reçine; "outlined" olan sakin cam, diğeri
/// ikincil ton.
class _SideButton extends StatelessWidget {
  const _SideButton({
    super.key,
    required this.title,
    required this.sub,
    required this.onPressed,
    this.outlined = false,
  });

  final String title, sub;
  final VoidCallback? onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      label: '$title, $sub',
      excludeSemantics: true,
      button: true,
      enabled: onPressed != null,
      onTap: onPressed,
      child: ResinButton(
        tone: outlined ? ResinTone.glass : ResinTone.secondary,
        width: 79,
        height: 55,
        radius: 30,
        onPressed: onPressed,
        builder: (context, color) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  style: text.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  sub,
                  maxLines: 1,
                  style: text.labelSmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Büyük yuvarlak "İç" düğmesi: en doygun reçine, basınca küçülür.
class _DrinkButton extends StatelessWidget {
  const _DrinkButton({super.key, required this.sub, required this.onPressed});

  final String sub;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      label: '+1 bardak, $sub',
      excludeSemantics: true,
      button: true,
      onTap: onPressed,
      child: ResinButton(
        tone: ResinTone.primary,
        circle: true,
        width: 81,
        height: 81,
        onPressed: onPressed,
        builder: (context, on) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'İç',
                maxLines: 1,
                style: text.headlineSmall?.copyWith(
                  color: on,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '+1 bardak',
                  maxLines: 1,
                  style: text.labelSmall?.copyWith(
                    color: on,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  sub,
                  maxLines: 1,
                  style: text.labelSmall?.copyWith(
                    color: on.withValues(alpha: 0.9),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

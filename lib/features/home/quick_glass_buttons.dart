import 'package:flutter/material.dart';

/// Bardak sırasının altında hızlı düğmeler: "+1 bardak", "+2 bardak" ve
/// "−1 bardak". [onRemove] null ise (bugün hiç su yok) çıkarma düğmesi pasiftir.
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
      children: [
        Expanded(
          child: _QuickButton(
            key: const ValueKey('quick-add-1'),
            title: '+1 bardak',
            sub: '$glassMl ml',
            onPressed: () => onAdd(1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickButton(
            key: const ValueKey('quick-add-2'),
            title: '+2 bardak',
            sub: '${glassMl * 2} ml',
            onPressed: () => onAdd(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickButton(
            key: const ValueKey('quick-remove-1'),
            title: '−1 bardak',
            sub: '$glassMl ml',
            outlined: true,
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({
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
    final small = Theme.of(context).textTheme.labelSmall;
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(fit: BoxFit.scaleDown, child: Text(title, maxLines: 1)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(sub, maxLines: 1, style: small),
        ),
      ],
    );
    const style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, 56)),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 6)),
    );
    return Semantics(
      label: '$title, $sub',
      excludeSemantics: true,
      button: true,
      enabled: onPressed != null,
      onTap: onPressed,
      child: outlined
          ? OutlinedButton(onPressed: onPressed, style: style, child: child)
          : FilledButton.tonal(
              onPressed: onPressed,
              style: style,
              child: child,
            ),
    );
  }
}

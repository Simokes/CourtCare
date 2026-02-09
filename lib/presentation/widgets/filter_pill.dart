// lib/presentation/widgets/filter_pill.dart
import 'package:flutter/material.dart';

class FilterPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onClear;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FilterPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onClear,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? scheme.surfaceContainerHighest;
    final fg = foregroundColor ?? scheme.onSurfaceVariant;
    final border = BorderSide(color: scheme.outlineVariant, width: 1);

    return Semantics(
      label: 'Filtre $label',
      button: true,
      child: Material(
        color: bg,
        shape: StadiumBorder(side: border),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onClear,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: fg),
                  ),
                ),
                const SizedBox(width: 6),
                InkResponse(
                  radius: 16,
                  onTap: onClear,
                  child: Icon(Icons.close_rounded, size: 16, color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

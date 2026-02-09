// lib/presentation/widgets/filters_bar.dart
import 'package:flutter/material.dart';

class FiltersBar extends StatelessWidget {
  final List<Widget> children;
  const FiltersBar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(children: _withSpacing(children)),
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> items) {
    return [
      for (int i = 0; i < items.length; i++) ...[
        if (i == 0) const SizedBox(width: 2),
        items[i],
        const SizedBox(width: 8),
      ],
    ];
  }
}

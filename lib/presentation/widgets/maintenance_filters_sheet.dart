import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/maintenance_filters_provider.dart';
import '../providers/terrain_provider.dart';

class MaintenanceFiltersSheet extends ConsumerWidget {
  const MaintenanceFiltersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(maintenanceFiltersProvider.notifier);
    final filters = ref.watch(maintenanceFiltersProvider);
    final terrains = ref.watch(terrainsProvider).value ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  final now = DateTime.now();
                  notifier.setDateRange(
                    DateTime(now.year, now.month, now.day),
                    DateTime(now.year, now.month, now.day, 23, 59, 59),
                  );
                },
                child: const Text("Aujourd'hui"),
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    notifier.setDateRange(picked.start, picked.end);
                  }
                },
                child: const Text("Période…"),
              ),
            ],
          ),
          DropdownButton<String>(
            value: filters.type,
            hint: const Text("Type"),
            items: ["Recharge", "Travaux", "Soufflage", "Arrosage"]
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: notifier.setType,
          ),
          DropdownButton<int>(
            value: filters.terrainId,
            hint: const Text("Terrain"),
            items: terrains
                .map(
                  (t) => DropdownMenuItem(
                    value: t.id,
                    child: Text("Terrain ${t.numero} (${t.type})"),
                  ),
                )
                .toList(),
            onChanged: notifier.setTerrain,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: notifier.clear,
            child: const Text("Réinitialiser"),
          ),
        ],
      ),
    );
  }
}

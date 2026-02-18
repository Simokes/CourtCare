// lib/presentation/screens/all_maintenances_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_drawer.dart';
import '../widgets/maintenance_filters_sheet.dart';
import '../widgets/filter_pill.dart';
import '../widgets/filters_bar.dart';
import '../providers/maintenance_filters_provider.dart';
import '../utils/date_formatting.dart';
import '../widgets/add_maintenance_sheet.dart';
import '../../domain/entities/maintenance.dart' as domain;
import '../providers/database_provider.dart';

class AllMaintenancesScreen extends ConsumerWidget {
  const AllMaintenancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredMaintenancesProvider);
    final filters = ref.watch(maintenanceFiltersProvider);

    final pills = <Widget>[];

    if (filters.start != null && filters.end != null) {
      pills.add(
        FilterPill(
          icon: Icons.calendar_today_rounded,
          label: 'Du ${_fmt(filters.start!)} au ${_fmt(filters.end!)}',
          onClear: () => ref
              .read(maintenanceFiltersProvider.notifier)
              .setDateRange(null, null),
        ),
      );
    }

    if (filters.type != null) {
      pills.add(
        FilterPill(
          icon: Icons.label_rounded,
          label: 'Type : ${filters.type}',
          onClear: () =>
              ref.read(maintenanceFiltersProvider.notifier).setType(null),
        ),
      );
    }

    if (filters.terrainId != null) {
      pills.add(
        FilterPill(
          icon: Icons.sports_tennis_rounded,
          label: 'Terrain #${filters.terrainId}',
          onClear: () =>
              ref.read(maintenanceFiltersProvider.notifier).setTerrain(null),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les maintenances'),
        actions: [
          IconButton(
            tooltip: 'Filtres',
            icon: const Icon(Icons.filter_alt),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const MaintenanceFiltersSheet(),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          FiltersBar(children: pills),
          Expanded(
            child: filtered.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (items) {
                if (items.isEmpty) return const _EmptyState();
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, i) {
                    final m = items[i]; // MaintenanceEntity (Drift)

                    final existing = domain.Maintenance(
                      id: m.id,
                      terrainId: m.terrainId,
                      type: m.type,
                      commentaire: m.commentaire,
                      date: m.date,
                      sacsMantoUtilises: m.sacsMantoUtilises,
                      sacsSottomantoUtilises: m.sacsSottomantoUtilises,
                      sacsSiliceUtilises: m.sacsSiliceUtilises,
                    );

                    return ListTile(
                      leading: _MaintenanceTypeIcon(type: m.type),
                      title: Text(m.type),
                      subtitle: Text(
                        '${formatHumanizedFr(m.date)} • Terrain ${m.terrainId}'
                        '${_sacsResume(m.sacsMantoUtilises, m.sacsSottomantoUtilises, m.sacsSiliceUtilises)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () async {
                          final db = ref.read(databaseProvider);
                          final terrain = await db.getTerrainById(m.terrainId);
                          if (!context.mounted) return;
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => AddMaintenanceSheet(
                              terrainNumero: terrain.numero,
                              terrainId: terrain.id,
                              terrainType: terrain.type,
                              existing: existing,
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year} $hh:$min';
  }

  static String _sacsResume(int manto, int sotto, int silice) {
    final parts = <String>[];
    if (manto > 0) parts.add('Manto: $manto');
    if (sotto > 0) parts.add('Sottomanto: $sotto');
    if (silice > 0) parts.add('Silice: $silice');
    if (parts.isEmpty) return '';
    return ' • ${parts.join(' · ')}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: scheme.outline),
          const SizedBox(height: 8),
          Text('Aucune maintenance trouvée.',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Ajuste les filtres pour afficher des résultats.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceTypeIcon extends StatelessWidget {
  final String type;
  const _MaintenanceTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    IconData icon;
    Color bg;
    Color fg = scheme.onPrimary;

    switch (type) {
      case 'Recharge':
        icon = Icons.add_circle_outline;
        bg = scheme.primaryContainer;
        fg = scheme.onPrimaryContainer;
        break;
      case 'Travaux':
        icon = Icons.build_outlined;
        bg = scheme.tertiaryContainer;
        fg = scheme.onTertiaryContainer;
        break;
      case 'Soufflage':
        icon = Icons.air_outlined;
        bg = scheme.secondaryContainer;
        fg = scheme.onSecondaryContainer;
        break;
      case 'Arrosage':
        icon = Icons.water_drop_outlined;
        bg = scheme.secondaryContainer;
        fg = scheme.onSecondaryContainer;
        break;
      default:
        icon = Icons.handyman_outlined;
        bg = scheme.surfaceContainerHighest;
        fg = scheme.onSurfaceVariant;
    }

    return CircleAvatar(
      backgroundColor: bg,
      foregroundColor: fg,
      child: Icon(icon, size: 18),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:court_care/presentation/providers/terrain_provider.dart'
    show terrainsProvider;
import 'package:court_care/presentation/providers/database_provider.dart' as dbp
    show databaseProvider;
import 'package:court_care/presentation/providers/maintenance_provider.dart'
    show maintenanceProvider;
import 'package:court_care/presentation/providers/stats_period_provider.dart';
import 'package:court_care/presentation/providers/selected_terrains_provider.dart';
import 'package:court_care/presentation/providers/stats_providers.dart';
import 'package:court_care/presentation/widgets/grouped_bar_chart.dart';
import 'package:court_care/presentation/providers/maintenance_provider.dart'
    hide startOfDay, endOfDay, startOfWeek, startOfMonth, endOfMonth;

import 'package:court_care/domain/entities/terrain.dart'; // pour TerrainType

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statsPeriodProvider);
    final terrainsAsync = ref.watch(terrainsProvider);
    final selected = ref.watch(selectedTerrainsProvider);

    final sacksSeries = ref.watch(sacksSeriesProvider);
    final maintTypesSeries = ref.watch(maintenanceTypesSeriesProvider);
//TEST
    ref.listen(sacksSeriesProvider, (prev, next) {
      next.whenData((points) {
        debugPrint('[SACKS] points=${points.length} '
            'range=${period.range.startInclusive} -> ${period.range.endInclusive} '
            'selected=${selected.isEmpty ? 'ALL' : selected.toList()} '
            'sum=${points.fold<int>(0, (a, p) => a + p.manto + p.sottomanto + p.silice)}');
      });
    });

    ref.listen(maintenanceTypesSeriesProvider, (prev, next) {
      next.whenData((rows) {
        debugPrint('[TYPES] rows=${rows.length}');
      });
    });
    ref.listen(sacksSeriesProvider, (_, next) {
      next.whenData((points) {
        debugPrint('Sacks: ${points.length} points '
            'range: ${period.range.startInclusive} -> ${period.range.endInclusive} '
            'terrains: ${selected.isEmpty ? "ALL" : selected.toList()}');
      });
    });
    //test

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Insert dev'),
        onPressed: () async {
          try {
            // 1) Insertion via le Notifier (respecte tes règles métier)
            await ref.read(maintenanceProvider.notifier).addMaintenance(
                  terrainId: 1,
                  terrainType: TerrainType
                      .terreBattue, // important pour les règles matériaux
                  type: 'Recharge', // consomme des sacs
                  commentaire: 'DEV – 10/02/2026',
                  sacsMantoUtilises: 3,
                  sacsSottomantoUtilises: 1,
                  sacsSiliceUtilises: 0,
                  date: DateTime(2026, 2, 10, 12, 0,
                      0), // ✅ DANS la fenêtre "février 2026"
                );
            debugPrint(
                'DB(screen) hash = ${identityHashCode(ref.read(dbp.databaseProvider))}');
            final totalRows = await (ref
                .read(dbp.databaseProvider)
                .customSelect('SELECT COUNT(*) AS c FROM maintenances',
                    readsFrom: {
                  ref.read(dbp.databaseProvider).maintenances
                }).getSingle());
            debugPrint(
                'DEV: total maintenances en DB = ${totalRows.data['c']}');
            // 2) Relire immédiatement ce que la DB contient pour (terrain=1) DANS la fenêtre
            final db = ref.read(dbp.databaseProvider);
            final rows = await db.customSelect(
              '''
        SELECT id, terrain_id, type, date,
               sacs_manto_utilises AS manto,
               sacs_sottomanto_utilises AS sotto,
               sacs_silice_utilises AS sil
        FROM maintenances
        WHERE date BETWEEN ? AND ?
          AND terrain_id = 1
        ORDER BY date DESC
        ''',
              variables: [
                Variable<int>(
                    period.range.startInclusive.millisecondsSinceEpoch),
                Variable<int>(period.range.endInclusive.millisecondsSinceEpoch),
              ],
              readsFrom: {db.maintenances},
            ).get();

            debugPrint(
                'DEV: maintenances dans la fenêtre (terrain 1) = ${rows.length}');
            for (final r in rows.take(3)) {
              final m = r.data;
              debugPrint('  id=${m['id']} t=${m['terrain_id']} '
                  'date=${DateTime.fromMillisecondsSinceEpoch(m['date'] as int)} '
                  'M=${m['manto']} So=${m['sotto']} Si=${m['sil']} type=${m['type']}');
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Maintenance DEV insérée')),
              );
            }
          } catch (e, st) {
            debugPrint('DEV insert ERROR: $e\n$st');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur insert DEV: $e')),
              );
            }
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _PeriodBar(period: period),
          const SizedBox(height: 12),
          terrainsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur terrains: $e'),
            data: (terrains) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Tous les terrains'),
                  selected: selected.isEmpty,
                  onSelected: (_) =>
                      ref.read(selectedTerrainsProvider.notifier).clear(),
                ),
                ...terrains.map((t) {
                  final selectedFlag = selected.contains(t.id);
                  return FilterChip(
                    label: Text('T${t.numero}'),
                    selected: selected.isEmpty ? true : selectedFlag,
                    onSelected: (_) => ref
                        .read(selectedTerrainsProvider.notifier)
                        .toggle(t.id),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Chart 1 : Maintenances par type (comptes)
          maintTypesSeries.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur: $e'),
            data: (rows) {
              // Adapter rows -> buckets + séries par type
              final buckets = <String>[];
              final types = <String>{};
              final byBucket = <String, Map<String, int>>{};
              for (final r in rows) {
                buckets.add(r.bucket);
                types.add(r.type);
                byBucket.putIfAbsent(r.bucket, () => <String, int>{});
                byBucket[r.bucket]![r.type] = r.count;
              }
              final uniqueBuckets = buckets.toSet().toList()..sort();
              final typeList = types.toList()..sort();

              final palette = _palette();
              final series = typeList.map((t) {
                final color = palette[t.hashCode % palette.length];
                final vals = uniqueBuckets
                    .map((b) => (byBucket[b]?[t] ?? 0).toDouble())
                    .toList();
                return ChartSeries(id: t, color: color, values: vals);
              }).toList();

              return GroupedBarChart(
                title: 'Maintenances par type',
                buckets: uniqueBuckets,
                series: series,
                height: 260,
              );
            },
          ),

          const SizedBox(height: 16),

          // Chart 2 : Sacs utilisés (Manto / Sotto / Silice)
          sacksSeries.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur: $e'),
            data: (points) {
              final buckets = points.map((p) => p.bucket).toList();
              final manto = ChartSeries(
                id: 'Manto',
                color: const Color(0xFF8D6E63),
                values: points.map((p) => p.manto.toDouble()).toList(),
              );
              final sotto = ChartSeries(
                id: 'Sottomanto',
                color: const Color(0xFFFFA726),
                values: points.map((p) => p.sottomanto.toDouble()).toList(),
              );
              final sil = ChartSeries(
                id: 'Silice',
                color: const Color(0xFFBDBDBD),
                values: points.map((p) => p.silice.toDouble()).toList(),
              );
              return GroupedBarChart(
                title: 'Sacs utilisés (par jour)',
                buckets: buckets,
                series: [manto, sotto, sil],
                height: 260,
              );
            },
          ),
        ],
      ),
    );
  }

  List<Color> _palette() => const [
        Color(0xFF42A5F5), // blue
        Color(0xFF66BB6A), // green
        Color(0xFFAB47BC), // purple
        Color(0xFFEF5350), // red
        Color(0xFFFFCA28), // amber
        Color(0xFF26C6DA), // cyan
        Color(0xFF7E57C2), // deep purple
        Color(0xFFFF7043), // deep orange
      ];
}

class _PeriodBar extends ConsumerWidget {
  final StatsPeriodState period;
  const _PeriodBar({required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                _PeriodButton(
                  label: 'Jour',
                  selected: period.kind == PeriodKind.day,
                  onTap: () => ref
                      .read(statsPeriodProvider.notifier)
                      .setKind(PeriodKind.day),
                ),
                const SizedBox(width: 8),
                _PeriodButton(
                  label: 'Semaine',
                  selected: period.kind == PeriodKind.week,
                  onTap: () => ref
                      .read(statsPeriodProvider.notifier)
                      .setKind(PeriodKind.week),
                ),
                const SizedBox(width: 8),
                _PeriodButton(
                  label: 'Mois',
                  selected: period.kind == PeriodKind.month,
                  onTap: () => ref
                      .read(statsPeriodProvider.notifier)
                      .setKind(PeriodKind.month),
                ),
                const Spacer(),
                IconButton(
                  tooltip: period.kind == PeriodKind.day
                      ? 'Choisir un jour'
                      : 'Choisir un mois',
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(now.year - 2),
                      lastDate: DateTime(now.year + 2),
                    );
                    if (picked != null) {
                      final n = ref.read(statsPeriodProvider.notifier);
                      if (period.kind == PeriodKind.day) {
                        n.setDay(picked);
                      } else if (period.kind == PeriodKind.month) {
                        n.setMonth(picked);
                      } else if (period.kind == PeriodKind.week) {
                        final s = startOfWeek(picked);
                        final e = endOfWeek(picked); // ✅ fin de la même semaine
                        ref
                            .read(statsPeriodProvider.notifier)
                            .setCustomRange(s, e);
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _periodLabel(period),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _periodLabel(StatsPeriodState p) {
    final s = p.range.startInclusive;
    final e = p.range.endInclusive;
    String d(DateTime x) =>
        '${x.day.toString().padLeft(2, '0')}/${x.month.toString().padLeft(2, '0')}/${x.year}';
    switch (p.kind) {
      case PeriodKind.day:
        return 'Période : ${d(s)}';
      case PeriodKind.week:
      case PeriodKind.custom:
        return 'Période : ${d(s)} – ${d(e)}';
      case PeriodKind.month:
        return 'Période : ${s.month.toString().padLeft(2, '0')}/${s.year}';
    }
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

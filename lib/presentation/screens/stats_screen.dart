import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:court_care/presentation/providers/stats_period_provider.dart';
import 'package:court_care/presentation/providers/selected_terrains_provider.dart';
import 'package:court_care/presentation/providers/stats_providers.dart';
import 'package:court_care/presentation/providers/terrain_provider.dart';
import 'package:court_care/presentation/widgets/grouped_bar_chart.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statsPeriodProvider);
    final terrainsAsync = ref.watch(terrainsProvider);
    final selected = ref.watch(selectedTerrainsProvider);

    final sacksSeries = ref.watch(sacksSeriesProvider);
    final maintTypesSeries = ref.watch(maintenanceTypesSeriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
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
                  onSelected: (_) => ref.read(selectedTerrainsProvider.notifier).clear(),
                ),
                ...terrains.map((t) {
                  final selectedFlag = selected.contains(t.id);
                  return FilterChip(
                    label: Text('T${t.numero}'),
                    selected: selectedFlag || selected.isEmpty,
                    onSelected: (_) => ref.read(selectedTerrainsProvider.notifier).toggle(t.id),
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
                final vals = uniqueBuckets.map((b) => (byBucket[b]?[t] ?? 0).toDouble()).toList();
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
                  onTap: () => ref.read(statsPeriodProvider.notifier).setKind(PeriodKind.day),
                ),
                const SizedBox(width: 8),
                _PeriodButton(
                  label: 'Semaine',
                  selected: period.kind == PeriodKind.week,
                  onTap: () => ref.read(statsPeriodProvider.notifier).setKind(PeriodKind.week),
                ),
                const SizedBox(width: 8),
                _PeriodButton(
                  label: 'Mois',
                  selected: period.kind == PeriodKind.month,
                  onTap: () => ref.read(statsPeriodProvider.notifier).setKind(PeriodKind.month),
                ),
                const Spacer(),
                IconButton(
                  tooltip: period.kind == PeriodKind.day ? 'Choisir un jour' : 'Choisir un mois',
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
                        // semaine: on centre sur le jour choisi
                        final s = startOfWeek(picked);
                        n.setCustomRange(s, endOfDay(DateTime.now()));
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
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
    String d(DateTime x) => '${x.day.toString().padLeft(2, '0')}/${x.month.toString().padLeft(2, '0')}/${x.year}';
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
  const _PeriodButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
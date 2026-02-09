import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_drawer.dart';
import '../providers/maintenance_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final monthKey = DateTime(now.year, now.month, 1);

    final monthlyTotals = ref.watch(monthlyTotalsAllTerrainsProvider(monthKey));

    return Scaffold(
      appBar: AppBar(title: const Text('CourtCare')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: monthlyTotals.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Consommation du mois',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Erreur: $e'),
                  ],
                ),
                data: (t) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Consommation du mois',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    const _Legend(),
                    const SizedBox(height: 8),
                    _MonthlyRow(
                      icon: Icons.layers,
                      label: 'Manto',
                      value: t.manto,
                      color: const Color(0xFF8D6E63),
                    ),
                    _MonthlyRow(
                      icon: Icons.layers_outlined,
                      label: 'Sottomanto',
                      value: t.sottomanto,
                      color: const Color(0xFFFFA726),
                    ),
                    _MonthlyRow(
                      icon: Icons.grain,
                      label: 'Silice',
                      value: t.silice,
                      color: const Color(0xFFBDBDBD),
                    ),
                    if ((t.manto + t.sottomanto + t.silice) == 0) ...[
                      const SizedBox(height: 8),
                      const Text('Aucune consommation ce mois.'),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Bienvenue dans CourtCare',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Row(
      children: [
        const Icon(Icons.info_outline, size: 16),
        const SizedBox(width: 6),
        Text('Totaux mensuels (tous terrains)', style: style),
      ],
    );
  }
}

class _MonthlyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _MonthlyRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text('$value sac(s)', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

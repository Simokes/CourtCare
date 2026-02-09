import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/maintenance.dart';
import '../../domain/entities/terrain.dart';
import '../providers/maintenance_provider.dart';
import '../widgets/add_maintenance_sheet.dart';

class TerrainMaintenanceHistoryScreen extends ConsumerWidget {
  final Terrain terrain;

  const TerrainMaintenanceHistoryScreen({
    super.key,
    required this.terrain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    // Bornes stables
    final todayStart = startOfDay(now);
    final todayEnd = endOfDay(now);

    final weekStart = startOfWeek(now);
    final weekEnd = endOfDay(now);

    final maintenancesAsync =
        ref.watch(maintenancesByTerrainProvider(terrain.id));

    final todayTotals = ref.watch(
      sacsTotalsProvider((
        terrainId: terrain.id,
        start: todayStart,
        end: todayEnd,
      )),
    );

    final weekTotals = ref.watch(
      sacsTotalsProvider((
        terrainId: terrain.id,
        start: weekStart,
        end: weekEnd,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Historique – Terrain ${terrain.numero}'),
      ),
      body: Column(
        children: [
          // ------------------------------------------------------------------
          // TOTALS
          // ------------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _TotalsCard(
                  context: context,
                  title: 'Aujourd’hui',
                  totals: todayTotals,
                ),
                _TotalsCard(
                  context: context,
                  title: 'Cette semaine',
                  totals: weekTotals,
                ),
              ],
            ),
          ),

          // ------------------------------------------------------------------
          // LISTE DES MAINTENANCES
          // ------------------------------------------------------------------
          Expanded(
            child: maintenancesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erreur : $err')),
              data: (maintenances) {
                if (maintenances.isEmpty) {
                  return const Center(
                    child: Text('Aucune maintenance enregistrée'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: maintenances.length,
                  itemBuilder: (context, index) {
                    final m = maintenances[index];
                    return _MaintenanceCard(
                      maintenance: m,
                      terrain: terrain,
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
}

// ============================================================================
// CARD AVEC SUPPRESSION + MODIFICATION
// ============================================================================
class _MaintenanceCard extends ConsumerWidget {
  final Maintenance maintenance;
  final Terrain terrain;

  const _MaintenanceCard({
    required this.maintenance,
    required this.terrain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(maintenance.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final result = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Supprimer la maintenance'),
            content: const Text('Cette action est définitive.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );
        return result ?? false;
      },
      onDismissed: (_) async {
        await ref.read(maintenanceProvider.notifier).deleteMaintenance(
              maintenanceId: maintenance.id,
              terrainId: terrain.id,
            );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),

          // Contenu existant
          title: Text(
            maintenance.type,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _MaintenanceDetails(maintenance: maintenance),
          ),

          // -----------------------------
          // ICÔNE MODIFIER (AJOUTÉ)
          // -----------------------------
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => AddMaintenanceSheet(
                  terrainNumero: terrain.numero,
                  terrainId: terrain.id,
                  terrainType: terrain.type,
                  existing: maintenance, // MODE ÉDITION
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DÉTAILS D'UNE MAINTENANCE (inchangé)
// ============================================================================
class _MaintenanceDetails extends StatelessWidget {
  final Maintenance maintenance;

  const _MaintenanceDetails({required this.maintenance});

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date
        Text(
          formatDate(maintenance.date),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),

        const SizedBox(height: 8),

        // Consommation
        if (maintenance.sacsMantoUtilises > 0)
          _ChipInfo(label: '${maintenance.sacsMantoUtilises} sac(s) Manto'),
        if (maintenance.sacsSottomantoUtilises > 0)
          _ChipInfo(label: '${maintenance.sacsSottomantoUtilises} sac(s) Sottomanto'),
        if (maintenance.sacsSiliceUtilises > 0)
          _ChipInfo(label: '${maintenance.sacsSiliceUtilises} sac(s) Silice'),

        if (maintenance.commentaire != null &&
            maintenance.commentaire!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            maintenance.commentaire!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final String label;

  const _ChipInfo({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(label),
    );
  }
}

// ============================================================================
// CARTE TOTAUX (inchangé)
// ============================================================================
class _TotalsCard extends StatelessWidget {
  final BuildContext context;
  final String title;
  final AsyncValue<({int manto, int sottomanto, int silice})> totals;

  const _TotalsCard({
    required this.context,
    required this.title,
    required this.totals,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.only(bottom: 12, right: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: totals.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Erreur'),
            data: (t) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (t.manto > 0) Text('🟤 Manto : ${t.manto} sacs'),
                if (t.sottomanto > 0)
                  Text('🟠 Sottomanto : ${t.sottomanto} sacs'),
                if (t.silice > 0) Text('⚪ Silice : ${t.silice} sacs'),
                if (t.manto + t.sottomanto + t.silice == 0)
                  const Text('Aucune consommation'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
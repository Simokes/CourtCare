import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/terrain.dart';
import '../providers/maintenance_provider.dart';

class TerrainMaintenanceHistoryScreen extends ConsumerWidget {
  final Terrain terrain;

  const TerrainMaintenanceHistoryScreen({
    super.key,
    required this.terrain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenancesAsync =
        ref.watch(maintenancesByTerrainProvider(terrain.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Historique – Terrain ${terrain.numero}'),
      ),
      body: maintenancesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Erreur : $err'),
        ),
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

              return Dismissible(
                key: ValueKey(m.id),
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
                  await ref
                      .read(maintenanceProvider.notifier)
                      .deleteMaintenance(
                        maintenanceId: m.id,
                        terrainId: terrain.id,
                      );
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Titre + date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              m.type,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              _formatDate(m.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 🔹 Quantités
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (m.sacsMantoUtilises > 0)
                              _ChipInfo(
                                label: '${m.sacsMantoUtilises} sac(s) Manto',
                                icon: Icons.layers,
                              ),
                            if (m.sacsSottomantoUtilises > 0)
                              _ChipInfo(
                                label:
                                    '${m.sacsSottomantoUtilises} sac(s) Sottomanto',
                                icon: Icons.layers_outlined,
                              ),
                            if (m.sacsSiliceUtilises > 0)
                              _ChipInfo(
                                label: '${m.sacsSiliceUtilises} sac(s) Silice',
                                icon: Icons.grain,
                              ),
                          ],
                        ),

                        // 🔹 Commentaire
                        if (m.commentaire != null &&
                            m.commentaire!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            m.commentaire!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _ChipInfo extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ChipInfo({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 4),
      child: Chip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
      ),
    );
  }
}

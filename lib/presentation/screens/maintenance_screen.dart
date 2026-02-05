import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/terrain_provider.dart' as terrainProv;
import '../providers/maintenance_provider.dart' as maintenanceProv;
import '../widgets/terrain_card.dart';
import '../widgets/add_maintenance_sheet.dart';
import 'terrain_maintenance_history_screen.dart';

class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terrainsAsync = ref.watch(terrainProv.terrainsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      body: terrainsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur : $err')),
        data: (terrains) {
          if (terrains.isEmpty) {
            return const Center(child: Text('Aucun terrain trouvé'));
          }

          return ListView.builder(
            itemCount: terrains.length,
            itemBuilder: (context, index) {
              final terrain = terrains[index];
              final maintenancesAsync =
                  ref.watch(maintenanceProv.maintenanceCountProvider(terrain.id));

              return maintenancesAsync.when(
                loading: () => TerrainCard(
                  terrain: terrain,
                  maintenancesDuJour: 0,
                  onAddMaintenance: () {},
                  onTap: () {},
                ),
                error: (_, __) => TerrainCard(
                  terrain: terrain,
                  maintenancesDuJour: 0,
                  onAddMaintenance: () {},
                  onTap: () {},
                ),
                data: (count) => TerrainCard(
                  terrain: terrain,
                  maintenancesDuJour: count,
                  onAddMaintenance: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => AddMaintenanceSheet(
                        terrainId: terrain.id,
                        terrainNumero: terrain.numero,
                        terrainType: terrain.type,
                      ),
                    );
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TerrainMaintenanceHistoryScreen(
                          terrain: terrain,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

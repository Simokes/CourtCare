import 'package:flutter/material.dart';
import 'package:court_care/domain/entities/terrain.dart';

class TerrainCard extends StatelessWidget {
  final Terrain terrain;
  final int maintenancesDuJour;
  final VoidCallback onAddMaintenance;
  final VoidCallback onTap;

  const TerrainCard({
    super.key,
    required this.terrain,
    required this.maintenancesDuJour,
    required this.onAddMaintenance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Terrain ${terrain.numero} - ${terrain.type.name}'),
        subtitle: Text('Maintenances aujourd\'hui : $maintenancesDuJour'),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: onAddMaintenance,
        ),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/maintenance.dart' as domain;
import 'database_provider.dart';

// ------------------- LISTE DES MAINTENANCES -------------------
final maintenancesByTerrainProvider =
    FutureProvider.family<List<domain.Maintenance>, int>((ref, terrainId) async {
  final db = ref.read(databaseProvider);
  return db.getMaintenancesForTerrain(terrainId);
});

// ------------------- COMPTE DU JOUR -------------------
final maintenanceCountProvider =
    FutureProvider.family<int, int>((ref, terrainId) async {
  final db = ref.read(databaseProvider);
  return db.getMaintenancesCountForDay(terrainId, DateTime.now());
});

// ------------------- SUPPRESSION -------------------
final deleteMaintenanceProvider =
    Provider<Future<void> Function(int)>((ref) {
  final db = ref.read(databaseProvider);

  return (int maintenanceId) async {
    await db.deleteMaintenance(maintenanceId);
  };
});

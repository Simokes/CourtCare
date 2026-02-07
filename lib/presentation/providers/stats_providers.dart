import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:court_care/data/database/app_database.dart';
import 'package:court_care/presentation/providers/terrain_provider.dart'; // databaseProvider
import 'package:court_care/presentation/providers/stats_period_provider.dart';
import 'package:court_care/presentation/providers/selected_terrains_provider.dart';

/// Série: sacs utilisés par jour (Manto/Sotto/Silice), multi-terrains
final sacksSeriesProvider = StreamProvider<List<SacsTotalsPoint>>((ref) {
  final db = ref.watch(databaseProvider);
  final period = ref.watch(statsPeriodProvider);
  final selected = ref.watch(selectedTerrainsProvider).toList(); // vide => tous
  return db.watchDailySacsSeriesForTerrains(
    start: period.range.startInclusive,
    end: period.range.endInclusive,
    terrainIds: selected,
  );
});

/// Série: maintenances par type (compte), par jour, multi-terrains
final maintenanceTypesSeriesProvider = StreamProvider<List<MaintenanceTypeRow>>((ref) {
  final db = ref.watch(databaseProvider);
  final period = ref.watch(statsPeriodProvider);
  final selected = ref.watch(selectedTerrainsProvider).toList(); // vide => tous
  return db.watchDailyMaintenanceTypeCounts(
    start: period.range.startInclusive,
    end: period.range.endInclusive,
    terrainIds: selected,
  );
});
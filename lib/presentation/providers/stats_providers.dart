import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:court_care/data/database/app_database.dart';

// ✅ providers locaux, en relatif (sans ambiguïté)
import 'database_provider.dart';
import 'stats_period_provider.dart';
import 'selected_terrains_provider.dart';

/// Série: sacs utilisés par jour (Manto/Sotto/Silice), multi-terrains
final sacksSeriesProvider =
    StreamProvider.autoDispose<List<SacsTotalsPoint>>((ref) {
  final db = ref.watch(databaseProvider); // sync & stable
  final period = ref.watch(statsPeriodProvider); // sync
  final selected = ref.watch(selectedTerrainsProvider); // sync
  final ids = selected.isEmpty ? <int>[] : selected.toList(); // vide => tous

  return db.watchDailySacsSeriesForTerrains(
    start: period.range.startInclusive,
    end: period.range.endInclusive,
    terrainIds: ids,
  );
});

/// Série: maintenances par type (compte), par jour, multi-terrains
final maintenanceTypesSeriesProvider =
    StreamProvider.autoDispose<List<MaintenanceTypeRow>>((ref) {
  final db = ref.watch(databaseProvider);
  final period = ref.watch(statsPeriodProvider);
  final selected = ref.watch(selectedTerrainsProvider);
  final ids = selected.isEmpty ? <int>[] : selected.toList();

  return db.watchDailyMaintenanceTypeCounts(
    start: period.range.startInclusive,
    end: period.range.endInclusive,
    terrainIds: ids,
  );
});

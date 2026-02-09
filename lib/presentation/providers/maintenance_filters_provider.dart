import 'package:court_care/data/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';

class MaintenanceFilters {
  final DateTime? start;
  final DateTime? end;
  final String? type;
  final int? terrainId;

  const MaintenanceFilters({
    this.start,
    this.end,
    this.type,
    this.terrainId,
  });

  MaintenanceFilters copyWith({
    DateTime? start,
    DateTime? end,
    String? type,
    int? terrainId,
  }) {
    return MaintenanceFilters(
      start: start ?? this.start,
      end: end ?? this.end,
      type: type ?? this.type,
      terrainId: terrainId ?? this.terrainId,
    );
  }
}

class MaintenanceFiltersNotifier extends StateNotifier<MaintenanceFilters> {
  MaintenanceFiltersNotifier() : super(const MaintenanceFilters());

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(start: start, end: end);
  }

  void setType(String? type) {
    state = state.copyWith(type: type);
  }

  void setTerrain(int? id) {
    state = state.copyWith(terrainId: id);
  }

  void clear() => state = const MaintenanceFilters();
}

final maintenanceFiltersProvider =
    StateNotifierProvider<MaintenanceFiltersNotifier, MaintenanceFilters>(
        (ref) => MaintenanceFiltersNotifier());

final filteredMaintenancesProvider =
    StreamProvider<List<MaintenanceEntity>>((ref) {
  final db = ref.watch(databaseProvider);
  final filters = ref.watch(maintenanceFiltersProvider);

  return db.watchFilteredMaintenances(
    start: filters.start,
    end: filters.end,
    type: filters.type,
    terrainId: filters.terrainId,
  );
});

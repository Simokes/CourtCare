import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/terrain.dart';
import '../../domain/entities/maintenance.dart';
import 'database_provider.dart';

final maintenanceProvider =
    StateNotifierProvider<MaintenanceNotifier, AsyncValue<void>>(
  (ref) => MaintenanceNotifier(ref),
);

class MaintenanceNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  MaintenanceNotifier(this.ref) : super(const AsyncData(null));
  Future<void> deleteMaintenance({
    required int maintenanceId,
    required int terrainId,
  }) async {
    state = const AsyncLoading();

    try {
      final db = ref.read(databaseProvider);

      await db.deleteMaintenance(maintenanceId);

      // 🔄 Rafraîchissements
      ref.invalidate(maintenancesByTerrainProvider(terrainId));
      ref.invalidate(maintenanceCountProvider(terrainId));

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> addMaintenance({
    required int terrainId,
    required TerrainType terrainType,
    required String type,
    String? commentaire,
    int sacsMantoUtilises = 0,
    int sacsSottomantoUtilises = 0,
    int sacsSiliceUtilises = 0,
  }) async {
    state = const AsyncLoading();

    try {
      final db = ref.read(databaseProvider);

      // 🔒 RÈGLES MÉTIER VERROUILLÉES
      int manto = 0;
      int sottomanto = 0;
      int silice = 0;

      if (terrainType == TerrainType.terreBattue) {
        manto = sacsMantoUtilises;
        sottomanto = sacsSottomantoUtilises;
      } else if (terrainType == TerrainType.synthetique) {
        silice = sacsSiliceUtilises;
      }
      final bool utiliseSacs = type == 'Recharge' || type == 'Travaux';

      if (!utiliseSacs) {
        manto = 0;
        sottomanto = 0;
        silice = 0;
      }

      await db.addMaintenance(
        terrainId: terrainId,
        type: type,
        commentaire: commentaire,
        date: DateTime.now(),
        sacsMantoUtilises: manto,
        sacsSottomantoUtilises: sottomanto,
        sacsSiliceUtilises: silice,
      );

      // 🔄 Rafraîchissements
      ref.invalidate(maintenancesByTerrainProvider(terrainId));
      ref.invalidate(maintenanceCountProvider(terrainId));

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final maintenancesByTerrainProvider =
    FutureProvider.family<List<Maintenance>, int>((ref, terrainId) {
  final db = ref.read(databaseProvider);
  return db.getMaintenancesForTerrain(terrainId);
});

final maintenanceCountProvider =
    FutureProvider.family<int, int>((ref, terrainId) {
  final db = ref.read(databaseProvider);
  return db.getMaintenancesCountForDay(
    terrainId,
    DateTime.now(),
  );
});

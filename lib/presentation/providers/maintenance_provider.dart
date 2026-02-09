import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../domain/entities/terrain.dart';
import '../../domain/entities/maintenance.dart';
import 'database_provider.dart';
import 'package:court_care/data/database/app_database.dart';

// ============================================================================
// HELPERS (portée locale)
// ============================================================================
DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime endOfDay(DateTime d) =>
    DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

DateTime startOfWeek(DateTime d) =>
    DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

DateTime endOfMonth(DateTime d) {
  final firstNextMonth = (d.month == 12)
      ? DateTime(d.year + 1, 1, 1)
      : DateTime(d.year, d.month + 1, 1);
  return firstNextMonth.subtract(const Duration(milliseconds: 1));
}

// ============================================================================
// PROVIDERS GLOBAUX
// ============================================================================

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

/// Totaux réactifs sur une période [start..end]
final sacsTotalsProvider = StreamProvider.family<
    ({int manto, int sottomanto, int silice}),
    ({int terrainId, DateTime start, DateTime end})>((ref, params) {
  final db = ref.watch(databaseProvider);
  return db.watchSacsTotals(
    terrainId: params.terrainId,
    start: params.start,
    end: params.end,
  );
});

/// Totaux mensuels sur l'ensemble des terrains
final monthlyTotalsAllTerrainsProvider =
    StreamProvider.family<({int manto, int sottomanto, int silice}), DateTime>(
  (ref, anyDayInMonth) {
    final db = ref.watch(databaseProvider);
    final start = startOfMonth(anyDayInMonth);
    final end = endOfMonth(anyDayInMonth);
    return db.watchSacsTotalsAllTerrains(start: start, end: end);
  },
);

// ============================================================================
// NOTIFIER
// ============================================================================
final maintenanceProvider =
    StateNotifierProvider<MaintenanceNotifier, AsyncValue<void>>(
  (ref) => MaintenanceNotifier(ref),
);

class MaintenanceNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  MaintenanceNotifier(this.ref) : super(const AsyncData(null));

  // --------------------------------------------------------------------------
  // DELETE
  // --------------------------------------------------------------------------
  Future<void> deleteMaintenance({
    required int maintenanceId,
    required int terrainId,
  }) async {
    state = const AsyncLoading();
    try {
      final db = ref.read(databaseProvider);
      await db.deleteMaintenance(maintenanceId);

      // Invalidation ciblée
      ref.invalidate(maintenancesByTerrainProvider(terrainId));
      ref.invalidate(maintenanceCountProvider(terrainId));

      ref.invalidate(
        sacsTotalsProvider((
          terrainId: terrainId,
          start: startOfDay(DateTime.now()),
          end: endOfDay(DateTime.now()),
        )),
      );

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // ADD
  // --------------------------------------------------------------------------
  Future<void> addMaintenance({
    required int terrainId,
    required TerrainType terrainType,
    required String type,
    String? commentaire,
    int sacsMantoUtilises = 0,
    int sacsSottomantoUtilises = 0,
    int sacsSiliceUtilises = 0,
    DateTime? date,
  }) async {
    state = const AsyncLoading();

    try {
      final db = ref.read(databaseProvider);

      // === RÈGLES MÉTIER ===
      int manto = 0;
      int sottomanto = 0;
      int silice = 0;

      if (terrainType == TerrainType.terreBattue) {
        manto = sacsMantoUtilises;
        sottomanto = sacsSottomantoUtilises;
      } else {
        silice = sacsSiliceUtilises;
      }

      final utiliseSacs = type == 'Recharge' || type == 'Travaux';
      if (!utiliseSacs) {
        manto = 0;
        sottomanto = 0;
        silice = 0;
      }

      await db.addMaintenance(
        terrainId: terrainId,
        type: type,
        commentaire: commentaire,
        date: date ?? DateTime.now(),
        sacsMantoUtilises: manto,
        sacsSottomantoUtilises: sottomanto,
        sacsSiliceUtilises: silice,
      );

      // Refresh automatique
      ref.invalidate(maintenancesByTerrainProvider(terrainId));
      ref.invalidate(maintenanceCountProvider(terrainId));
      ref.invalidate(sacsTotalsProvider);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // UPDATE (nouveau)
  // --------------------------------------------------------------------------
  Future<void> updateMaintenance({
    required Maintenance existing,
    required String type,
    String? commentaire,
    required int sacsMantoUtilises,
    required int sacsSottomantoUtilises,
    required int sacsSiliceUtilises,
  }) async {
    state = const AsyncLoading();

    try {
      final db = ref.read(databaseProvider);

      // --- RÉCUP TERRAIN ---
      final terrain = await db.getTerrainById(existing.terrainId);

      // === RÈGLES MÉTIER IDENTIQUES À ADD ===
      int manto = 0;
      int sottomanto = 0;
      int silice = 0;

      if (terrain.type == TerrainType.terreBattue) {
        manto = sacsMantoUtilises;
        sottomanto = sacsSottomantoUtilises;
      } else {
        silice = sacsSiliceUtilises;
      }

      final utiliseSacs = type == 'Recharge' || type == 'Travaux';
      if (!utiliseSacs) {
        manto = 0;
        sottomanto = 0;
        silice = 0;
      }

      // === UPDATE SQL ===
      final companion = MaintenancesCompanion(
        id: Value(existing.id),
        terrainId: Value(existing.terrainId),
        type: Value(type),
        commentaire: Value(commentaire),
        date: Value(existing.date),
        sacsMantoUtilises: Value(manto),
        sacsSottomantoUtilises: Value(sottomanto),
        sacsSiliceUtilises: Value(silice),
      );

      await db.updateMaintenance(companion);

      // Refresh automatique (mêmes invalidations que delete)
      ref.invalidate(maintenancesByTerrainProvider(existing.terrainId));
      ref.invalidate(maintenanceCountProvider(existing.terrainId));
      ref.invalidate(sacsTotalsProvider);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

// ============================================================================
// Totaux mensuels par terrain
// ============================================================================
final monthlyTotalsByTerrainProvider = StreamProvider.family<
    ({int manto, int sottomanto, int silice}),
    ({int terrainId, DateTime anyDayInMonth})>((ref, params) {
  final db = ref.watch(databaseProvider);

  final start = startOfMonth(params.anyDayInMonth);
  final end = endOfMonth(params.anyDayInMonth);

  return db.watchSacsTotals(
    terrainId: params.terrainId,
    start: start,
    end: end,
  );
});

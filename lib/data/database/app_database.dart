import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Tables Drift
import 'tables/terrain_table.dart';
import 'tables/maintenances.dart';

// Entités domaine
import 'package:court_care/domain/entities/terrain.dart';
import 'package:court_care/domain/entities/maintenance.dart' as domain;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    TerrainTable,
    Maintenances,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 3) {
            await migrator.addColumn(
              maintenances,
              maintenances.sacsMantoUtilises,
            );
            await migrator.addColumn(
              maintenances,
              maintenances.sacsSottomantoUtilises,
            );
            await migrator.addColumn(
              maintenances,
              maintenances.sacsSiliceUtilises,
            );
          }
        },
      );

  // ------------------- SEED TERRAINS -------------------
  Future<void> seedTerrains() async {
    final existing = await select(terrainTable).get();
    if (existing.isNotEmpty) return;

    for (int i = 1; i <= 8; i++) {
      await into(terrainTable).insert(
        TerrainTableCompanion.insert(
          numero: i,
          type:
              (i <= 6 ? TerrainType.terreBattue : TerrainType.synthetique).name,
          statut: TerrainStatut.ouvert.name,
        ),
      );
    }
  }

  Future<
      ({
        int manto,
        int sottomanto,
        int silice,
      })> getSacsTotalsForTerrainBetween(
    int terrainId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await (select(maintenances)
          ..where((m) => m.terrainId.equals(terrainId))
          ..where((m) => m.date.isBetweenValues(start, end)))
        .get();

    int manto = 0;
    int sottomanto = 0;
    int silice = 0;

    for (final r in rows) {
      manto += r.sacsMantoUtilises;
      sottomanto += r.sacsSottomantoUtilises;
      silice += r.sacsSiliceUtilises;
    }

    return (
      manto: manto,
      sottomanto: sottomanto,
      silice: silice,
    );
  }

  // ------------------- TERRAINS -------------------
  Future<List<Terrain>> getAllTerrains() async {
    final rows = await select(terrainTable).get();
    return rows
        .map((row) => Terrain(
              id: row.id,
              numero: row.numero,
              type: TerrainType.values.byName(row.type),
              statut: TerrainStatut.values.byName(row.statut),
            ))
        .toList();
  }

  // ------------------- MAINTENANCES -------------------
  Future<void> addMaintenance({
    required int terrainId,
    required String type,
    String? commentaire,
    int sacsMantoUtilises = 0,
    int sacsSottomantoUtilises = 0,
    int sacsSiliceUtilises = 0,
    required DateTime date,
  }) async {
    await into(maintenances).insert(
      MaintenancesCompanion.insert(
        terrainId: terrainId,
        type: type,
        commentaire: Value(commentaire),
        date: date,
        sacsMantoUtilises: Value(sacsMantoUtilises),
        sacsSottomantoUtilises: Value(sacsSottomantoUtilises),
        sacsSiliceUtilises: Value(sacsSiliceUtilises),
      ),
    );
  }

  Future<List<domain.Maintenance>> getMaintenancesForTerrain(
      int terrainId) async {
    final rows = await (select(maintenances)
          ..where((m) => m.terrainId.equals(terrainId)))
        .get();

    // Conversion MaintenanceEntity -> domain.Maintenance
    return rows
        .map((row) => domain.Maintenance(
              id: row.id,
              terrainId: row.terrainId,
              type: row.type,
              commentaire: row.commentaire,
              date: row.date,
              sacsMantoUtilises: row.sacsMantoUtilises,
              sacsSottomantoUtilises: row.sacsSottomantoUtilises,
              sacsSiliceUtilises: row.sacsSiliceUtilises,
            ))
        .toList();
  }

  Future<void> deleteMaintenance(int maintenanceId) async {
    await (delete(maintenances)..where((m) => m.id.equals(maintenanceId))).go();
  }

  Future<int> getMaintenancesCountForDay(int terrainId, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final rows = await (select(maintenances)
          ..where((m) => m.terrainId.equals(terrainId))
          ..where((m) => m.date.isBetweenValues(start, end)))
        .get();

    return rows.length;
  }
}

// ------------------- REACTIVE TOTALS WATCHERS -------------------
extension TotalsWatchQueries on AppDatabase {
  /// Totaux réactifs des sacs pour un terrain et une période (bornes inclusives).
  /// Émet immédiatement une première valeur, puis à chaque changement (insert/update/delete).
  Stream<({int manto, int sottomanto, int silice})> watchSacsTotals({
    required int terrainId,
    DateTime? start,
    DateTime? end,
  }) {
    final m = maintenances;

    final sumManto = m.sacsMantoUtilises.sum();
    final sumSotto = m.sacsSottomantoUtilises.sum();
    final sumSil = m.sacsSiliceUtilises.sum();

    final q = selectOnly(m)..addColumns([sumManto, sumSotto, sumSil]);

    final predicates = <Expression<bool>>[
      m.terrainId.equals(terrainId),
    ];
    if (start != null) {
      predicates.add(m.date.isBiggerOrEqualValue(start));
    }
    if (end != null) {
      predicates.add(m.date.isSmallerOrEqualValue(end));
    }
    q.where(predicates.reduce((a, b) => a & b));

    // watchSingle() : renvoie 1 ligne d'agrégat ; SUM(...) peut retourner NULL si 0 ligne → coalesce à 0.
    return q.watchSingle().map((row) {
      final manto = row.read(sumManto) ?? 0;
      final sotto = row.read(sumSotto) ?? 0;
      final sil = row.read(sumSil) ?? 0;
      return (manto: manto, sottomanto: sotto, silice: sil);
    });
  }
}

extension TotalsWatchQueriesAll on AppDatabase {
  Stream<({int manto, int sottomanto, int silice})> watchSacsTotalsAllTerrains({
    DateTime? start,
    DateTime? end,
  }) {
    final m = maintenances;
    final sumManto = m.sacsMantoUtilises.sum();
    final sumSotto = m.sacsSottomantoUtilises.sum();
    final sumSil = m.sacsSiliceUtilises.sum();

    final q = selectOnly(m)..addColumns([sumManto, sumSotto, sumSil]);

    final predicates = <Expression<bool>>[];
    if (start != null) {
      predicates.add(m.date.isBiggerOrEqualValue(start));
    }
    if (end != null) {
      predicates.add(m.date.isSmallerOrEqualValue(end));
    }
    if (predicates.isNotEmpty) {
      q.where(predicates.reduce((a, b) => a & b));
    }

    return q.watchSingle().map((row) {
      final manto = row.read(sumManto) ?? 0;
      final sotto = row.read(sumSotto) ?? 0;
      final sil = row.read(sumSil) ?? 0;
      return (manto: manto, sottomanto: sotto, silice: sil);
    });
  }
}

// Série d’un point agrégé
class SacsTotalsPoint {
  final String bucket; // ex: "2026-02-07", "2026-W05", "2026-02"
  final int manto;
  final int sottomanto;
  final int silice;
  SacsTotalsPoint({
    required this.bucket,
    required this.manto,
    required this.sottomanto,
    required this.silice,
  });
}

extension StatsSeriesQueries on AppDatabase {
  // Group by day (YYYY-MM-DD) within range, optional terrain filter
  Stream<List<SacsTotalsPoint>> watchDailySeries({
    required DateTime start,
    required DateTime end,
    int? terrainId,
  }) {
    final whereTerrain = terrainId != null ? ' AND terrain_id = ?' : '';
    // IMPORTANT: date est en ms epoch -> convertir en secondes pour sqlite datetime()
    const dateExpr = "datetime(date/1000, 'unixepoch')";

    final sql = '''
      SELECT strftime('%Y-%m-%d', $dateExpr) AS bucket,
             COALESCE(SUM(sacs_manto_utilises), 0) AS manto,
             COALESCE(SUM(sacs_sottomanto_utilises), 0) AS sotto,
             COALESCE(SUM(sacs_silice_utilises), 0) AS sil
      FROM maintenances
      WHERE $dateExpr BETWEEN ? AND ? $whereTerrain
      GROUP BY bucket
      ORDER BY bucket ASC;
    ''';

    final vars = <Variable>[
      Variable<DateTime>(start),
      Variable<DateTime>(end),
      if (terrainId != null) Variable<int>(terrainId),
    ];

    return customSelect(sql, variables: vars, readsFrom: {maintenances})
        .watch()
        .map((rows) {
      return rows.map((r) {
        return SacsTotalsPoint(
          bucket: r.read<String>('bucket'),
          manto: r.read<int>('manto'),
          sottomanto: r.read<int>('sotto'),
          silice: r.read<int>('sil'),
        );
      }).toList();
    });
  }

  // Group by week (YYYY-Www) within range
  Stream<List<SacsTotalsPoint>> watchWeeklySeries({
    required DateTime start,
    required DateTime end,
    int? terrainId,
  }) {
    final whereTerrain = terrainId != null ? ' AND terrain_id = ?' : '';
    const dateExpr = "datetime(date/1000, 'unixepoch')";

    final sql = '''
      SELECT strftime('%Y', $dateExpr) || '-W' || strftime('%W', $dateExpr) AS bucket,
             COALESCE(SUM(sacs_manto_utilises), 0) AS manto,
             COALESCE(SUM(sacs_sottomanto_utilises), 0) AS sotto,
             COALESCE(SUM(sacs_silice_utilises), 0) AS sil
      FROM maintenances
      WHERE $dateExpr BETWEEN ? AND ? $whereTerrain
      GROUP BY bucket
      ORDER BY bucket ASC;
    ''';

    final vars = <Variable>[
      Variable<DateTime>(start),
      Variable<DateTime>(end),
      if (terrainId != null) Variable<int>(terrainId),
    ];

    return customSelect(sql, variables: vars, readsFrom: {maintenances})
        .watch()
        .map((rows) {
      return rows.map((r) {
        return SacsTotalsPoint(
          bucket: r.read<String>('bucket'),
          manto: r.read<int>('manto'),
          sottomanto: r.read<int>('sotto'),
          silice: r.read<int>('sil'),
        );
      }).toList();
    });
  }

  // Group by month (YYYY-MM) within range
  Stream<List<SacsTotalsPoint>> watchMonthlySeries({
    required DateTime start,
    required DateTime end,
    int? terrainId,
  }) {
    final whereTerrain = terrainId != null ? ' AND terrain_id = ?' : '';
    const dateExpr = "datetime(date/1000, 'unixepoch')";

    final sql = '''
      SELECT strftime('%Y-%m', $dateExpr) AS bucket,
             COALESCE(SUM(sacs_manto_utilises), 0) AS manto,
             COALESCE(SUM(sacs_sottomanto_utilises), 0) AS sotto,
             COALESCE(SUM(sacs_silice_utilises), 0) AS sil
      FROM maintenances
      WHERE $dateExpr BETWEEN ? AND ? $whereTerrain
      GROUP BY bucket
      ORDER BY bucket ASC;
    ''';

    final vars = <Variable>[
      Variable<DateTime>(start),
      Variable<DateTime>(end),
      if (terrainId != null) Variable<int>(terrainId),
    ];

    return customSelect(sql, variables: vars, readsFrom: {maintenances})
        .watch()
        .map((rows) {
      return rows.map((r) {
        return SacsTotalsPoint(
          bucket: r.read<String>('bucket'),
          manto: r.read<int>('manto'),
          sottomanto: r.read<int>('sotto'),
          silice: r.read<int>('sil'),
        );
      }).toList();
    });
  }
}

// ------------------- DB CONNECTION -------------------
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'court_care.sqlite'));
    return NativeDatabase(file);
  });
}

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
          type: (i <= 6 ? TerrainType.terreBattue : TerrainType.synthetique).name,
          statut: TerrainStatut.ouvert.name,
        ),
      );
    }
  }

  // ------------------- TERRAINS -------------------
  Future<List<Terrain>> getAllTerrains() async {
    final rows = await select(terrainTable).get();
    return rows.map((row) => Terrain(
      id: row.id,
      numero: row.numero,
      type: TerrainType.values.byName(row.type),
      statut: TerrainStatut.values.byName(row.statut),
    )).toList();
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

  Future<List<domain.Maintenance>> getMaintenancesForTerrain(int terrainId) async {
    final rows = await (select(maintenances)
          ..where((m) => m.terrainId.equals(terrainId)))
        .get();



    // Conversion MaintenanceEntity -> domain.Maintenance
 return rows.map((row) => domain.Maintenance(
  id: row.id,
  terrainId: row.terrainId,
  type: row.type,
  commentaire: row.commentaire,
  date: row.date,
  sacsMantoUtilises: row.sacsMantoUtilises,
  sacsSottomantoUtilises: row.sacsSottomantoUtilises,
  sacsSiliceUtilises: row.sacsSiliceUtilises,
)).toList();

  }
Future<void> deleteMaintenance(int maintenanceId) async {
  await (delete(maintenances)
        ..where((m) => m.id.equals(maintenanceId)))
      .go();
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

// ------------------- DB CONNECTION -------------------
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'court_care.sqlite'));
    return NativeDatabase(file);
  });
}

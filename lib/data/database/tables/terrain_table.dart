import 'package:drift/drift.dart';

class TerrainTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get numero => integer()();
  TextColumn get type => text()(); // 'terreBattue' | 'synthetique'
  TextColumn get statut => text()(); // 'ouvert' | 'ferme' | 'maintenance'
}

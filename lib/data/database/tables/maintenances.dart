import 'package:drift/drift.dart';

@DataClassName('MaintenanceEntity') // <-- ici, nom différent
class Maintenances extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get terrainId => integer()();

  TextColumn get type => text()();
  TextColumn get commentaire => text().nullable()();
  DateTimeColumn get date => dateTime()();

  IntColumn get sacsMantoUtilises => integer().withDefault(const Constant(0))();

  IntColumn get sacsSottomantoUtilises =>
      integer().withDefault(const Constant(0))();

  IntColumn get sacsSiliceUtilises =>
      integer().withDefault(const Constant(0))();
}

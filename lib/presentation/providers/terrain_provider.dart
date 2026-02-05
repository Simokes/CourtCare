import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:court_care/data/database/app_database.dart';
import 'package:court_care/domain/entities/terrain.dart';

// Provider de la base de données
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Provider pour tous les terrains
final terrainsProvider = FutureProvider<List<Terrain>>((ref) async {
  final db = ref.read(databaseProvider);
  return db.getAllTerrains();
});

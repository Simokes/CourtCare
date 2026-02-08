import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:court_care/domain/entities/terrain.dart';
import 'package:court_care/presentation/providers/database_provider.dart';


// Provider pour tous les terrains
final terrainsProvider = FutureProvider<List<Terrain>>((ref) async {
  final db = ref.read(databaseProvider);
  return db.getAllTerrains();
});

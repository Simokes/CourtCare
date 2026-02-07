import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:court_care/data/database/app_database.dart';
import 'package:court_care/presentation/providers/terrain_provider.dart'; // databaseProvider
import 'package:court_care/presentation/providers/stats_period_provider.dart';

/// Série de stats pour un terrain (ou tous terrains si null), selon la période sélectionnée.
final statsSeriesProvider =
    StreamProvider.family<List<SacsTotalsPoint>, int?>((ref, terrainId) {
  final db = ref.watch(databaseProvider);
  final period = ref.watch(statsPeriodProvider); // sync state
  final start = period.range.startInclusive;
  final end = period.range.endInclusive;

  switch (period.kind) {
    case PeriodKind.day:
      // série journalière sur 1 jour -> 1 point (ok pour bar simple)
      return db.watchDailySeries(start: start, end: end, terrainId: terrainId);
    case PeriodKind.week:
      // on préfère daily pour afficher un bar par jour de la semaine
      return db.watchDailySeries(start: start, end: end, terrainId: terrainId);
    case PeriodKind.month:
      // daily pour affichage par jour du mois ; si tu veux plus compact, passe à watchWeeklySeries
      return db.watchDailySeries(start: start, end: end, terrainId: terrainId);
    case PeriodKind.custom:
      // par défaut daily ; on pourra adapter selon la durée (ex: > 60 jours -> weekly)
      return db.watchDailySeries(start: start, end: end, terrainId: terrainId);
  }
});

/// Série mensuelle groupée par mois (utile pour comparaison multi-mois)
final monthlySeriesProvider = StreamProvider.family<List<SacsTotalsPoint>,
    ({DateTime start, DateTime end, int? terrainId})>(
  (ref, p) {
    final db = ref.watch(databaseProvider);
    return db.watchMonthlySeries(
        start: p.start, end: p.end, terrainId: p.terrainId);
  },
);

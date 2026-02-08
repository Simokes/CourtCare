import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PeriodKind { day, week, month, custom }

class PeriodRange {
  final DateTime startInclusive;
  final DateTime endInclusive;
  const PeriodRange(this.startInclusive, this.endInclusive);
}

// === helpers existants ===
DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime endOfDay(DateTime d) =>
    DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
DateTime startOfWeek(DateTime d) =>
    startOfDay(d).subtract(Duration(days: d.weekday - 1));
DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
DateTime endOfMonth(DateTime d) {
  final f = (d.month == 12)
      ? DateTime(d.year + 1, 1, 1)
      : DateTime(d.year, d.month + 1, 1);
  return f.subtract(const Duration(milliseconds: 1));
}

// === AJOUT : fin de semaine stable (dimanche 23:59:59.999 si lundi=1) ===
DateTime endOfWeek(DateTime d) {
  final s = startOfWeek(d);
  final e = s.add(const Duration(days: 6));
  return endOfDay(e);
}

// === (optionnel mais utile) : clé stable = 1er du mois pour les family ===
DateTime monthKey(DateTime anyDayInMonth) => startOfMonth(anyDayInMonth);

class StatsPeriodState {
  final PeriodKind kind;
  final PeriodRange range;
  const StatsPeriodState({required this.kind, required this.range});
}

class StatsPeriodNotifier extends StateNotifier<StatsPeriodState> {
  StatsPeriodNotifier()
      : super(
          StatsPeriodState(
            kind: PeriodKind.month,
            range: PeriodRange(
                startOfMonth(DateTime.now()), endOfMonth(DateTime.now())),
          ),
        );

  void setKind(PeriodKind kind) {
    final now = DateTime.now();
    switch (kind) {
      case PeriodKind.day:
        state = StatsPeriodState(
            kind: kind, range: PeriodRange(startOfDay(now), endOfDay(now)));
        break;
      case PeriodKind.week:
        final s = startOfWeek(now);
        final e = endOfWeek(now); // ✅ borne stable
        state = StatsPeriodState(kind: kind, range: PeriodRange(s, e));
        break;
      case PeriodKind.month:
        state = StatsPeriodState(
            kind: kind, range: PeriodRange(startOfMonth(now), endOfMonth(now)));
        break;
      case PeriodKind.custom:
        // use setCustomRange
        break;
    }
  }

  void setCustomRange(DateTime start, DateTime end) {
    // On force des bornes jour stables pour éviter le flapping
    state = StatsPeriodState(
        kind: PeriodKind.custom,
        range: PeriodRange(startOfDay(start), endOfDay(end)));
  }

  void setMonth(DateTime anyDay) {
    state = StatsPeriodState(
        kind: PeriodKind.month,
        range: PeriodRange(startOfMonth(anyDay), endOfMonth(anyDay)));
  }

  void setDay(DateTime day) {
    state = StatsPeriodState(
        kind: PeriodKind.day,
        range: PeriodRange(startOfDay(day), endOfDay(day)));
  }
}

final statsPeriodProvider =
    StateNotifierProvider<StatsPeriodNotifier, StatsPeriodState>(
  (ref) => StatsPeriodNotifier(),
);

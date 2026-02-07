import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PeriodKind { day, week, month, custom }

class PeriodRange {
  final DateTime startInclusive;
  final DateTime endInclusive;
  const PeriodRange(this.startInclusive, this.endInclusive);
}

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime endOfDay(DateTime d) =>
    DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

DateTime startOfWeek(DateTime d) =>
    startOfDay(d).subtract(Duration(days: d.weekday - 1));
DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
DateTime endOfMonth(DateTime d) {
  final firstNextMonth = (d.month == 12)
      ? DateTime(d.year + 1, 1, 1)
      : DateTime(d.year, d.month + 1, 1);
  return firstNextMonth.subtract(const Duration(milliseconds: 1));
}

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
              startOfMonth(DateTime.now()),
              endOfMonth(DateTime.now()),
            ),
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
        state =
            StatsPeriodState(kind: kind, range: PeriodRange(s, endOfDay(now)));
        break;
      case PeriodKind.month:
        state = StatsPeriodState(
            kind: kind, range: PeriodRange(startOfMonth(now), endOfMonth(now)));
        break;
      case PeriodKind.custom:
        // no-op, utiliser setCustomRange
        break;
    }
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = StatsPeriodState(
        kind: PeriodKind.custom, range: PeriodRange(start, end));
  }
}

final statsPeriodProvider =
    StateNotifierProvider<StatsPeriodNotifier, StatsPeriodState>(
  (ref) => StatsPeriodNotifier(),
);

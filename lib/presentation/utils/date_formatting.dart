// lib/presentation/utils/date_formatting.dart
import 'package:intl/intl.dart';

/// Retourne une date longue en français (tout en minuscules),
/// ex: "vendredi 7 février 2026".
String formatLongFr(DateTime date) {
  // Important: Intl respecte la locale passée ici.
  final df = DateFormat('EEEE d MMMM y', 'fr_FR');
  final s = df.format(date.toLocal());
  // Par convention en français, jours et mois en minuscules.
  return s.toLowerCase();
}

/// Variante avec l'heure, ex: "vendredi 7 février 2026 à 14:05"
String formatLongFrWithTime(DateTime date) {
  final dfDate = DateFormat('EEEE d MMMM y', 'fr_FR');
  final dfTime = DateFormat('HH:mm', 'fr_FR');
  final local = date.toLocal();
  return '${dfDate.format(local).toLowerCase()} à ${dfTime.format(local)}';
}

String formatHumanizedFr(DateTime date) {
  final now = DateTime.now();
  final d = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = d.difference(today).inDays;

  if (diff == 0) return 'aujourd\'hui';
  if (diff == -1) return 'hier';
  if (diff == 1) return 'demain';

  return formatLongFr(date);
}


import 'package:hive/hive.dart';

class HiveDayStorage {
  /// Deletes all entries in the box (including all pictures)
  static Future<void> clearAllEntries() async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }

  /// Deletes the entry for the given [date] (if exists, including its pictures)
  static Future<void> deleteDay(DateTime date) async {
    final box = await Hive.openBox(boxName);
    final key = _dateKey(date);
    await box.delete(key);
  }
  static const String boxName = 'daily_entries';

  /// Stores [data] for the given [date] (uses 'YYYY-MM-DD' as key)
  /// Data is always normalized to {date, note, rating, pictures}
  static Future<void> storeDay(DateTime date, Map<String, dynamic> data) async {
    final box = await Hive.openBox(boxName);
    final key = _dateKey(date);
    final normalized = {
      'date': key,
      'note': data['note'] ?? '',
      'rating': data['rating'] ?? null,
      'pictures': data['pictures'] ?? <String>[],
    };
    await box.put(key, normalized);
  }

  /// Retrieves the object for the given [date] (returns null if not found)
  /// Always returns a normalized object {date, note, rating, pictures} or null
  static Future<Map<String, dynamic>?> retrieveDay(DateTime date) async {
    final box = await Hive.openBox(boxName);
    final key = _dateKey(date);
    final result = box.get(key);
    if (result == null) return null;
    final map = result is Map<String, dynamic>
        ? result
        : (result is Map ? Map<String, dynamic>.from(result) : null);
    if (map == null) return null;
    return {
      'date': map['date'] ?? key,
      'note': map['note'] ?? '',
      'rating': map['rating'] ?? null,
      'pictures': List<String>.from(map['pictures'] ?? []),
    };
  }

  /// Retrieves all objects for the given [month] and [year]
  /// Always returns a list of normalized objects {date, note, rating, pictures}
  static Future<List<Map<String, dynamic>>> retrieveMonth(int year, int month) async {
    final box = await Hive.openBox(boxName);
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    return box.keys
        .where((k) => k is String && k.startsWith(prefix))
        .map((k) {
          final m = box.get(k);
          if (m is Map<String, dynamic>) {
            return {
              'date': m['date'] ?? k,
              'note': m['note'] ?? '',
              'rating': m['rating'] ?? null,
              'pictures': List<String>.from(m['pictures'] ?? []),
            };
          } else if (m is Map) {
            final map = Map<String, dynamic>.from(m);
            return {
              'date': map['date'] ?? k,
              'note': map['note'] ?? '',
              'rating': map['rating'] ?? null,
              'pictures': List<String>.from(map['pictures'] ?? []),
            };
          }
          return null;
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  /// Retrieves all objects for the given [year]
  /// Always returns a list of normalized objects {date, note, rating, pictures}
  static Future<List<Map<String, dynamic>>> retrieveYear(int year) async {
    final box = await Hive.openBox(boxName);
    final prefix = '$year-';
    return box.keys
        .where((k) => k is String && k.startsWith(prefix))
        .map((k) {
          final m = box.get(k);
          if (m is Map<String, dynamic>) {
            return {
              'date': m['date'] ?? k,
              'note': m['note'] ?? '',
              'rating': m['rating'] ?? null,
              'pictures': List<String>.from(m['pictures'] ?? []),
            };
          } else if (m is Map) {
            final map = Map<String, dynamic>.from(m);
            return {
              'date': map['date'] ?? k,
              'note': map['note'] ?? '',
              'rating': map['rating'] ?? null,
              'pictures': List<String>.from(map['pictures'] ?? []),
            };
          }
          return null;
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  /// Helper to format date as 'YYYY-MM-DD'
  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:dailyme/utils/storage/util_hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

/// Helper to select a date range using the same logic as CSV export, but returns the picked range or null.
Future<DateTimeRange?> pickDateRangeForPictures(BuildContext context, List<String> allDates) async {
  // Like CSV: initial range is first and last entry
  DateTime minDate = DateTime.now();
  DateTime maxDate = DateTime.now();
  final dateList = allDates.map((d) {
    try {
      return DateTime.parse(d);
    } catch (_) {
      return null;
    }
  }).whereType<DateTime>().toList();
  if (dateList.isNotEmpty) {
    dateList.sort();
    minDate = dateList.first;
    maxDate = dateList.last;
    // For pictures, allow up to the last day of the last month for better UX (like CSV)
    final lastDay = DateTime(maxDate.year, maxDate.month + 1, 0).day;
    maxDate = DateTime(maxDate.year, maxDate.month, lastDay);
  } else {
    // fallback: allow user to pick any date
    minDate = DateTime(DateTime.now().year - 5, 1, 1);
    maxDate = DateTime(DateTime.now().year + 1, 12, 31);
  }
  await Future.delayed(Duration.zero);
  return await showDateRangePicker(
    context: context,
    firstDate: minDate,
    lastDate: maxDate,
    initialDateRange: DateTimeRange(start: minDate, end: maxDate),
  );
}


/// Exports entries with a note or rating to CSV for a selected period.
/// Prompts the user to pick a date range, then saves the CSV to device storage.
Future<void> exportEntriesToCsv(BuildContext context) async {
  // 1. Get all entries
  final allEntries = <Map<String, dynamic>>[];
  int minYear = DateTime.now().year, maxYear = DateTime.now().year;
  int minMonth = DateTime.now().month, maxMonth = DateTime.now().month;

  // Find earliest and latest entry
  for (int year = 2020; year <= DateTime.now().year; year++) {
    final yearEntries = await HiveDayStorage.retrieveYear(year);
    for (final entry in yearEntries) {
      if ((entry['note'] as String?)?.trim().isNotEmpty == true || entry['rating'] != null) {
        allEntries.add(entry);
        final date = DateTime.parse(entry['date']);
        if (date.year < minYear || (date.year == minYear && date.month < minMonth)) {
          minYear = date.year;
          minMonth = date.month;
        }
        if (date.year > maxYear || (date.year == maxYear && date.month > maxMonth)) {
          maxYear = date.year;
          maxMonth = date.month;
        }
      }
    }
  }
  if (allEntries.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No entries to export.')));
    return;
  }

  // 2. Ask user for date range
  // Use showDateRangePicker in a separate microtask to avoid context async issues
  DateTimeRange? picked;
  await Future.delayed(Duration.zero);
  picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(minYear, minMonth),
    lastDate: DateTime(maxYear, maxMonth, 31),
    initialDateRange: DateTimeRange(
      start: DateTime(minYear, minMonth),
      end: DateTime(maxYear, maxMonth, 31),
    ),
  );
  if (picked == null) return;

  // 3. Filter entries in range
  final filtered = allEntries.where((e) {
    final d = DateTime.parse(e['date']);
    return !d.isBefore(picked!.start) && !d.isAfter(picked.end);
  }).toList();

  // 4. Convert to CSV
  final rows = <List<String>>[
    ['Date', 'Note', 'Rating'],
    ...filtered.map((e) => [e['date'] ?? '', e['note'] ?? '', e['rating']?.toString() ?? ''])
  ];
  final csv = const ListToCsvConverter().convert(rows);

  // 5. Save to file
  final dir = await getExternalStorageDirectory();
  final file = File('${dir!.path}/dailyme_export_${DateTime.now().millisecondsSinceEpoch}.csv');
  await file.writeAsString(csv);

  // 6. Notify user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Exported ${filtered.length} entries to ${file.path}')),
  );
}

/// Exports entries with a note or rating to CSV for a selected period.
/// Prompts the user to pick a date range, then lets the user choose where to save the CSV.
Future<void> exportEntriesToCsvWithPicker(BuildContext context) async {
  // 1. Get all entries
  final allEntries = <Map<String, dynamic>>[];
  int minYear = DateTime.now().year, maxYear = DateTime.now().year;
  int minMonth = DateTime.now().month, maxMonth = DateTime.now().month;

  for (int year = 2020; year <= DateTime.now().year; year++) {
    final yearEntries = await HiveDayStorage.retrieveYear(year);
    if (!context.mounted) return;
    for (final entry in yearEntries) {
      if ((entry['note'] as String?)?.trim().isNotEmpty == true || entry['rating'] != null) {
        allEntries.add(entry);
        final date = DateTime.parse(entry['date']);
        if (date.year < minYear || (date.year == minYear && date.month < minMonth)) {
          minYear = date.year;
          minMonth = date.month;
        }
        if (date.year > maxYear || (date.year == maxYear && date.month > maxMonth)) {
          maxYear = date.year;
          maxMonth = date.month;
        }
      }
    }
  }
  if (!context.mounted) return;
  if (allEntries.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No entries to export.')));
    return;
  }

  await Future.delayed(Duration.zero);
  if (!context.mounted) return;
  DateTimeRange? picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(minYear, minMonth),
    lastDate: DateTime(maxYear, maxMonth, 31),
    initialDateRange: DateTimeRange(
      start: DateTime(minYear, minMonth),
      end: DateTime(maxYear, maxMonth, 31),
    ),
  );
  if (!context.mounted) return;
  if (picked == null) return;

  final filtered = allEntries.where((e) {
    final d = DateTime.parse(e['date']);
    return !d.isBefore(picked.start) && !d.isAfter(picked.end);
  }).toList();

  final rows = <List<String>>[
    ['Date', 'Note', 'Rating'],
    ...filtered.map((e) => [e['date'] ?? '', e['note'] ?? '', e['rating']?.toString() ?? ''])
  ];
  final csv = const ListToCsvConverter().convert(rows);

  // 5. Save to file (always to app directory for sharing)
  final dir = await getApplicationDocumentsDirectory();
  // Format start and end dates as yyyyMMdd
  String formatDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
  final startStr = formatDate(picked.start);
  final endStr = formatDate(picked.end);
  final filename = 'dailyme_${startStr}_${endStr}.csv';
  final file = File('${dir.path}/$filename');
  await file.writeAsString(csv);

  if (!context.mounted) return;
  // 6. Open share dialog
  await Share.shareXFiles([XFile(file.path)], text: 'DailyMe export CSV');

  // 7. Optionally, show a snackbar after sharing
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Exported ${filtered.length} entries. Share completed or cancelled.')),
  );
}

/// Imports entries from a CSV file. Overwrites entries for dates already present.
Future<void> importEntriesFromCsv(BuildContext context) async {
  // 1. Let user pick a CSV file
  // Expected CSV format:
  //   Date,Note,Rating
  //   2025-06-29,Some note,5
  //   2025-06-30,,3
  //   ...
  // The first row must be the header: Date,Note,Rating (case-insensitive, order required)
  // Date must be in YYYY-MM-DD format. Rating is optional and can be blank or integer.
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );
  if (result == null || result.files.single.path == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected.')),
      );
    }
    return;
  }
  final file = File(result.files.single.path!);
  final csvString = await file.readAsString();
  final rows = const CsvToListConverter().convert(csvString, eol: '\n');
  if (rows.isEmpty || rows.first.length < 3) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or empty CSV file.')),
      );
    }
    return;
  }
  // 2. Parse and import
  int imported = 0;
  for (int i = 1; i < rows.length; i++) {
    final row = rows[i];
    if (row.length < 3) continue;
    final date = row[0]?.toString();
    final note = row[1]?.toString() ?? '';
    final rating = row[2] is int ? row[2] : int.tryParse(row[2]?.toString() ?? '');
    if (date == null || date.length != 10) continue;
    final entry = {'date': date, 'note': note, 'rating': rating};
    // Overwrite entry for this date
    final parts = date.split('-');
    if (parts.length == 3) {
      final dt = DateTime.tryParse(date);
      if (dt != null) {
        await HiveDayStorage.storeDay(dt, entry);
        imported++;
      }
    }
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported $imported entries from CSV.')),
    );
  }
}

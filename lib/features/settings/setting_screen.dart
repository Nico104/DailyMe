import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dailyme/features/settings/setting_screens/statistics/statistics.dart';
import 'package:dailyme/features/settings/setting_screens/theme_settings/theme_settings.dart';
import 'package:dailyme/features/settings/setting_screens/weekstart/weekstart.dart';
import 'package:dailyme/features/settings/setting_screens/delete_day_dialog/delete_day_dialog.dart';
import 'package:dailyme/features/settings/utils/u_settings.dart';
import 'package:dailyme/utils/utils_general.dart';
import 'package:dailyme/utils/widgets/custom_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'utils/widgets/settings_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dailyme/utils/widgets/custom_nico_modal.dart';
import 'package:dailyme/utils/storage/util_hive.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';


class Settings extends StatefulWidget {


  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: CustomNicoScrollView(
          title: Text(
            "Settings",
            style: GoogleFonts.libreBaskerville(
              textStyle: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ),
          centerTitle: true,
          onScroll: () {},
          body: Column(
            // controller: _scrollSontroller,
            children: [
              const SizedBox(height: 42),
              SettingsContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Export/Import",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                  SettingsItem(
                      label: "Export as CSV",
                      leading: const Icon(Icons.save_as_outlined),
                      suffix: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        exportEntriesToCsvWithPicker(context);
                      }),
                  const SizedBox(height: 12),
                  SettingsItem(
                      label: "Import from CSV",
                      leading: const Icon(Icons.file_upload_outlined),
                      suffix: const Icon(Icons.keyboard_arrow_right),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('CSV Format Required'),
                            content: const Text(
                              'The CSV must have the following format:\n\n'
                              'Date,Note,Rating\n'
                              '2025-06-29,Some note,5\n'
                              '2025-06-30,,3\n\n'
                              'The first row must be the header: Date,Note,Rating (order required).\n'
                              'Date must be YYYY-MM-DD. Rating is optional.'
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
                            ],
                          ),
                        );
                        importEntriesFromCsv(context);
                      }),
                  const SizedBox(height: 12),
                  SettingsItem(
                      label: "Export pictures as ZIP",
                      leading: const Icon(Icons.archive_outlined),
                      suffix: const Icon(Icons.keyboard_arrow_right),
                      onTap: () async {
                        await _exportPicturesAsZip(context);
                      },
                  ),
  
                  ],
                ),
              ),
              // const SizedBox(height: 22),
              SettingsContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "settingsSectionTitleGeneral",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    SettingsItem(
                      label: "Week start day",
                      leading: const Icon(Icons.calendar_view_week_outlined),
                      suffix: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const WeekStartSettings(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SettingsItem(
                      label: "App appearance",
                      leading: const Icon(Icons.palette_outlined),
                      suffix: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        navigatePerSlide(
                          context,
                          const ThemeSettings(),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SettingsItem(
                      label: "Statistics",
                      leading: const Icon(Icons.bar_chart_outlined),
                      suffix: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StatisticsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SettingsItem(
                      label: "Delete entry of a single day",
                      leading: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                      suffix: const Icon(Icons.keyboard_arrow_right),
                      onTap: () async {
                        // Get all available days from Hive
                        final box = await Hive.openBox(HiveDayStorage.boxName);
                        final keys = box.keys.toList();
                        final availableDays = keys
                            .whereType<String>()
                            .map((k) {
                              try {
                                final parts = k.split('-');
                                if (parts.length == 3) {
                                  return DateTime(
                                    int.parse(parts[0]),
                                    int.parse(parts[1]),
                                    int.parse(parts[2]),
                                  );
                                }
                              } catch (_) {}
                              return null;
                            })
                            .whereType<DateTime>()
                            .toList()
                          ..sort((a, b) => b.compareTo(a));
                        if (availableDays.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No entries available.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (ctx) => DeleteDayDialog(
                            availableDays: availableDays,
                            onDelete: (selectedDay) async {
                              showCustomNicoLoadingModalBottomSheet(
                                context: context,
                                future: (() async {
                                  // Delete Hive entry
                                  await HiveDayStorage.deleteDay(selectedDay);
                                  // Remove picture paths for this day
                                  final prefs = await SharedPreferences.getInstance();
                                  final allPictures = prefs.getStringList('today_pictures') ?? [];
                                  final dateStr = "${selectedDay.year.toString().padLeft(4, '0')}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
                                  final filtered = allPictures.where((path) {
                                    final fileName = path.split(Platform.pathSeparator).last;
                                    return !(fileName.contains(dateStr));
                                  }).toList();
                                  await prefs.setStringList('today_pictures', filtered);
                                })(),
                                callback: (_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Entry for ${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')} deleted.'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SettingsItem(
                      label: "Delete all entries",
                      leading: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
                      suffix: const Icon(Icons.keyboard_arrow_right),
                      onTap: () async {
                        showCustomNicoModalBottomSheet(
                          context: context,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
                              const SizedBox(height: 18),
                              Text(
                                'Delete all entries?',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'This will permanently delete all your journal entries.\nThis action cannot be undone.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        showCustomNicoLoadingModalBottomSheet(
                                          context: context,
                                          future: (() async {
                                            await HiveDayStorage.clearAllEntries();
                                          })(),
                                          callback: (_) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('All entries deleted.'),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),


              Padding(
                padding: const EdgeInsets.all(16),
                // child: Text(
                //   "Every change gets saved and uploaded automatically",
                //   style: Theme.of(context).textTheme.labelSmall,
                //   textAlign: TextAlign.center,
                // ),
                child: _buildVersionInfoText(),
              ),
              const SizedBox(height: 28),
            ],
          ),
   
        ),
      ),
    );
  }
}

Future<void> _exportPicturesAsZip(BuildContext context) async {
    // Use HiveDayStorage for all picture paths
    final box = await Hive.openBox(HiveDayStorage.boxName);
    final keys = box.keys.whereType<String>().toList();
    final dateToPaths = <String, List<String>>{};
    final allDates = <String>[];
    for (final key in keys) {
      final entry = box.get(key);
      if (entry is Map && entry.containsKey('pictures')) {
        final pics = entry['pictures'];
        if (pics is List) {
          for (final path in pics) {
            if (path is String && path.isNotEmpty) {
              dateToPaths.putIfAbsent(key, () => []).add(path);
              allDates.add(key);
            }
          }
        }
      }
    }
    if (dateToPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pictures to export.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    // Limit selectable range to first and last picture date, like CSV export
    DateTime? minDate, maxDate;
    final dateObjs = allDates.map((d) {
      try {
        return DateTime.parse(d);
      } catch (_) {
        return null;
      }
    }).whereType<DateTime>().toList();
    if (dateObjs.isNotEmpty) {
      dateObjs.sort();
      minDate = dateObjs.first;
      maxDate = dateObjs.last;
    }
    // Use the same date range picker as CSV export, but limit range
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: minDate ?? DateTime(DateTime.now().year - 5, 1, 1),
      lastDate: maxDate != null
          ? DateTime(maxDate.year, maxDate.month, DateTime(maxDate.year, maxDate.month + 1, 0).day)
          : DateTime(DateTime.now().year + 1, 12, 31),
      initialDateRange: (minDate != null && maxDate != null)
          ? DateTimeRange(start: minDate, end: DateTime(maxDate.year, maxDate.month, DateTime(maxDate.year, maxDate.month + 1, 0).day))
          : null,
    );
    if (picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export cancelled.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    // Collect selected dates in range
    final selectedDates = dateToPaths.keys.where((d) {
      try {
        final dt = DateTime.parse(d);
        return !dt.isBefore(picked.start) && !dt.isAfter(picked.end);
      } catch (_) {
        return false;
      }
    }).toList();
    if (selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pictures found in selected range.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    showCustomNicoLoadingModalBottomSheet(
      context: context,
      future: (() async {
        final archive = Archive();
        for (final date in selectedDates) {
          final paths = dateToPaths[date] ?? [];
          for (final path in paths) {
            final file = File(path);
            if (await file.exists()) {
              final fileName = path.split(Platform.pathSeparator).last;
              // Folder structure: year/month/day/file
              String archivePath;
              final parts = date.split('-');
              if (parts.length == 3) {
                archivePath = '${parts[0]}/${parts[1]}/${parts[2]}/$fileName';
              } else {
                archivePath = '$date/$fileName';
              }
              archive.addFile(ArchiveFile(archivePath, await file.length(), await file.readAsBytes()));
            }
          }
        }
        if (archive.isEmpty) {
          throw Exception('No valid picture files found to export.');
        }
        final zipData = ZipEncoder().encode(archive);
        // Save to temp file
        final tempDir = Directory.systemTemp;
        final tempZip = File('${tempDir.path}/pictures_export.zip');
        await tempZip.writeAsBytes(zipData, flush: true);
        // Share the file
        await Share.shareXFiles([
          XFile(tempZip.path, mimeType: 'application/zip')
        ], text: 'Pictures export');
        return 'shared';
      })(),
      callback: (result) {
        if (result is Exception || result is Error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else if (result == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export cancelled.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pictures ZIP ready to share.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

Widget _buildVersionInfoText() {
  return FutureBuilder<PackageInfo>(
    future: PackageInfo.fromPlatform(),
    builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
      if (snapshot.hasData) {
        return Text(
          "Version: ${snapshot.data!.version}",
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        );
      } else if (snapshot.hasError) {
        return Text(
          "error loading version",
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        );
      } else {
        return Text(
          "Loading Version",
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        );
      }
    },
  );
}

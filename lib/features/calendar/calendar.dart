import 'package:dailyme/features/calendar/_future_note_overlay_input.dart';

import 'package:flutter/material.dart';
import 'package:dailyme/utils/storage/util_hive.dart';
import 'package:dailyme/features/calendar/day_info.dart';
import 'package:dailyme/features/calendar/future_day_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dailyme/features/calendar/_month_picker_dialog.dart' show MonthPickerDialog;


/// Returns true if the given [date] is the last day of its month.
bool isLastDayOfMonth(DateTime date) {
  final nextDay = date.add(const Duration(days: 1));
  return nextDay.month != date.month;
}

/// Change this if your data starts earlier than 2020-01.
const _baseYear = 2020;



class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  Future<DateTime?> _findEarliestEntry() async {
    // Find the earliest event date in _events, or null if none
    if (_events.isNotEmpty) {
      final allDates = _events.keys.toList();
      allDates.sort((a, b) => a.compareTo(b));
      return allDates.first;
    }
    // If no events loaded, try to load from storage for all years
    // (for performance, just try the base year)
    final data = await HiveDayStorage.retrieveYear(_baseYear);
    if (data.isNotEmpty) {
      final first = data.first;
      if (first['date'] != null && first['date'] is String) {
        final parts = (first['date'] as String).split('-');
        if (parts.length == 3) {
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
      }
    }
    return null;
  }

  void _showMonthPickerDialog() async {
    final earliest = await _findEarliestEntry();
    final selected = await showDialog<DateTime>(
      context: context,
      builder: (context) => MonthPickerDialog(
        initialMonth: _focusedMonth,
        baseYear: _baseYear,
        earliestEntry: earliest,
      ),
    );
    if (selected != null) {
      setState(() {
        _focusedMonth = DateTime(selected.year, selected.month);
        _pageController.jumpToPage(_monthIndex(_focusedMonth));
        _selectDay(DateTime(_focusedMonth.year, _focusedMonth.month, 1));
      });
    }
  }
  bool _weekStartsOnMonday = true;

  Future<void> _loadWeekStartPref() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt('weekStart');
    setState(() {
      _weekStartsOnMonday = (value == null) ? true : value == 1;
      debugPrint('Week start setting on calendar screen: \\${value == null ? 'default (Monday)' : (value == 1 ? 'Monday' : 'Sunday')}');
    });
  }
  String _formatDateLong(DateTime date) {
    // Example: 23. June 2025
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day}. ${months[date.month]} ${date.year}';
  }
  // ---------- STATE ----------
  late final PageController _pageController;
  late final DateTime _today;
  late DateTime _focusedMonth;        // First day of month currently in view
  DateTime? _selectedDay;             // Currently tapped day (may be null)

  /// Map of events keyed by exact date (year-month-day)
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};
  List<Map<String, dynamic>> _selectedDayEntries = [];

  // ---------- INIT ----------
  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _focusedMonth = DateTime(_today.year, _today.month);           // 1st of current month
    _pageController = PageController(initialPage: _monthIndex(_focusedMonth));
    _loadWeekStartPref().then((_) {
      _loadYearEvents(_focusedMonth.year).then((_) => _selectDay(_today));
    });
  }

  // ---------- HELPERS ----------

  /// How many months have elapsed since the base year/month.
  int _monthIndex(DateTime d) => (d.year - _baseYear) * 12 + (d.month - 1);

  /// Convert a page index back to a DateTime (1st of that month).
  DateTime _dateFromIndex(int index) =>
      DateTime(_baseYear + (index ~/ 12), (index % 12) + 1);


  Future<void> _loadYearEvents(int year) async {
    // Fetch once per year and cache.
    if (_events.keys.any((d) => d.year == year)) return;

    final data = await HiveDayStorage.retrieveYear(year); // [{date: 'YYYY-MM-DD', ...}, ...]
    for (var entry in data) {
      final key = entry['date'] as String?;                // Expect 'YYYY-MM-DD'
      if (key == null || key.length != 10) continue;
      final parts = key.split('-');
      final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      _events.putIfAbsent(dt, () => []).add(entry);
    }
    setState(() {});                                       // Refresh dots
  }

  Future<void> _selectDay(DateTime day) async {
    // Allow selecting any day, including future days
    final entry = await HiveDayStorage.retrieveDay(day);
    setState(() {
      _selectedDay = day;
      if (entry != null) {
        _selectedDayEntries = entry.entries
            .map((e) => {'key': e.key, 'value': e.value})
            .toList();
      } else if (day.isAfter(_today)) {
        // For future days, create a virtual entry with empty future_note
        _selectedDayEntries = [
          {'key': 'future_note', 'value': ''},
        ];
      } else {
        _selectedDayEntries = [];
      }
    });
  }

  void _jumpToToday() {
    final idx = _monthIndex(_today);
    _pageController.jumpToPage(idx);
    _selectDay(_today);
    setState(() => _focusedMonth = DateTime(_today.year, _today.month));
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {

    // final theme = Theme.of(context);
    // final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Pick month',
            onPressed: _showMonthPickerDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Go to Today',
        onPressed: _jumpToToday,
        icon: const Icon(Icons.today, color: Colors.black87, size: 28),
        label: const Text(
          'Today',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
        splashColor: Colors.black12,
      ),
      body: Column(
        children: [
          // ---------- Month cards ----------
          AspectRatio(
            aspectRatio:  0.96, // square card for aesthetic; tweak as desired
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) async {
                final month = _dateFromIndex(index);
                setState(() => _focusedMonth = month);
                await _loadYearEvents(month.year);
              },
              itemBuilder: (context, index) {
                final firstOfMonth = _dateFromIndex(index);
                return _MonthCard(
                  month: firstOfMonth,
                  today: _today,
                  events: _events,
                  selectedDay: _selectedDay,
                  onDayTap: _selectDay,
                  weekStartsOnMonday: _weekStartsOnMonday,
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ---------- Entries list ----------
          Expanded(
            child: (_selectedDay == null)
                ? const SizedBox.shrink()
                : Builder(
                    builder: (context) {
                      final isFuture = _selectedDay != null && _selectedDay!.isAfter(_today);
                      final hasEntry = _selectedDayEntries.isNotEmpty;
                      final futureNote = _selectedDayEntries.firstWhere(
                        (e) => e['key'] == 'future_note',
                        orElse: () => {'value': ''},
                      )['value'] as String? ?? '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: ListView(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const SizedBox(height: 18),
                            // Date header now handled by FutureDayInfo/DayInfo
                            const SizedBox(height: 18),
                            if (isFuture)
                              FutureDayInfo(
                                date: _selectedDay!,
                                futureNote: hasEntry && futureNote.isNotEmpty ? futureNote : null,
                                onEdit: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      contentPadding: EdgeInsets.all(8),
                                      content: FutureNoteOverlayInput(date: _selectedDay!),
                                    ),
                                  ).then((value) {
                                    setState(() {
                                      // Force reload: clear cache and reload events for the selected year
                                      _events.removeWhere((d, _) => d.year == _selectedDay!.year);
                                      _loadYearEvents(_selectedDay!.year);
                                    });
                                  },);
                                  // After editing, ensure an entry exists for this future day
                                  final entry = await HiveDayStorage.retrieveDay(_selectedDay!);
                                  if (entry == null) {
                                    // Create a new entry with the future note (handled by overlay input)
                                    await _loadYearEvents(_selectedDay!.year);
                                  }
                                  await _loadYearEvents(_selectedDay!.year);
                                  await _selectDay(_selectedDay!);
                                },
                              )
                            else
                              Expanded(
                                child: FutureBuilder<List<String>>(
                                  future: HiveDayStorage.retrieveDay(_selectedDay!).then((entry) => entry != null ? List<String>.from(entry['pictures'] ?? []) : <String>[]),
                                  builder: (context, snapshot) {
                                    return DayInfo(
                                      date: _selectedDay!,
                                      note: _selectedDayEntries.firstWhere(
                                        (e) => e['key'] == 'note',
                                        orElse: () => {'value': null},
                                      )['value'] as String?,
                                      rating: _selectedDayEntries.firstWhere(
                                        (e) => e['key'] == 'rating',
                                        orElse: () => {'value': null},
                                      )['value'] is int
                                          ? _selectedDayEntries.firstWhere(
                                              (e) => e['key'] == 'rating',
                                              orElse: () => {'value': null},
                                            )['value'] as int
                                          : null,
                                      picturePaths: snapshot.data ?? const <String>[],
                                      showDate: false,
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          )
       ],
      ),
    );
  }
}


// ===================================================================
/// Single card showing one month and its day grid.
/// - Future days are blank.
/// - Past/present days tappable & show a small dot if events exist.

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.month,
    required this.today,
    required this.events,
    required this.selectedDay,
    required this.onDayTap,
    this.weekStartsOnMonday = true,
  });

  final DateTime month; // first of month
  final DateTime today;
  final Map<DateTime, List<Map<String, dynamic>>> events;
  final DateTime? selectedDay;

  final ValueChanged<DateTime> onDayTap;
  final bool weekStartsOnMonday;


  String _monthName(int m) => const [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m];

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // DEBUG: Print all events for this month
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (events.isNotEmpty) {
        debugPrint('--- EVENTS FOR MONTH ${month.year}-${month.month.toString().padLeft(2, '0')} ---');
        events.forEach((date, entries) {
          if (date.year == month.year && date.month == month.month) {
            debugPrint('  $date: $entries');
          }
        });
        debugPrint('--- END EVENTS ---');
      }
    });

    // Calculate first weekday and leading empty slots based on week start
    int firstWeekday = month.weekday; // 1 = Mon, 7 = Sun
    int leadingEmpty;
    List<String> weekdayLabels;
    if (weekStartsOnMonday) {
      leadingEmpty = firstWeekday - 1;
      weekdayLabels = const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    } else {
      // Week starts on Sunday
      firstWeekday = month.weekday % 7; // 0 = Sun, 1 = Mon, ...
      leadingEmpty = firstWeekday;
      weekdayLabels = const ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    }
    final totalCells =
        leadingEmpty + daysInMonth + (7 - (leadingEmpty + daysInMonth) % 7) % 7;

    final isFutureMonth = month.year > today.year || (month.year == today.year && month.month > today.month);

    // Removed unused isFutureDay helper
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.white.withOpacity(isFutureMonth ? 0.8 : 1.0)
        : Colors.black.withOpacity(isFutureMonth ? 0.8 : 1.0);
    final double borderThickness = isFutureMonth ? 0.8 : 1.2;
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: borderThickness,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // -------- Month title --------
            Opacity(
              opacity: isFutureMonth ? 0.8 : 1.0,
              child: isFutureMonth
                  ? Text(
                      '${_monthName(month.month)} ${month.year}',
                      style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w300),
                    )
                  : Text(
                      '${_monthName(month.month)} ${month.year}',
                      style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 20),
            // -------- Weekday headers --------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekdayLabels
                  .map((d) => Expanded(
                        child: Center(
                          child: Opacity(
                            opacity: isFutureMonth ? 0.4 : 1.0,
                            child: Text(
                              d,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            // -------- Grid --------
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: totalCells,
                itemBuilder: (_, idx) {
                  final dayNum = idx - leadingEmpty + 1;
                  if (idx < leadingEmpty || dayNum > daysInMonth) {
                    return const SizedBox.shrink(); // outside current month
                  }
              
                  final date = DateTime(month.year, month.month, dayNum);
                  final isFuture = date.isAfter(today);
                  final isSelected = selectedDay != null &&
                      selectedDay!.year == date.year &&
                      selectedDay!.month == date.month &&
                      selectedDay!.day == date.day;
              

                  final hasEvent = events.containsKey(date);
                  Color? ratingColor;
                  bool hasNoteNoRating = false;
                  bool hasFutureNote = false;
                  if (hasEvent) {
                    // Use the first entry's rating for color (or average, or max, as needed)
                    final entry = events[date]!.firstWhere(
                      (e) => e['rating'] != null,
                      orElse: () => events[date]!.first,
                    );
                    final rating = entry['rating'];
                    if (rating is int) {
                      // Simple color mapping: 1=red, 2=orange, 3=yellow, 4=light green, 5=green
                      switch (rating) {
                        case 1:
                          ratingColor = Colors.red;
                          break;
                        case 2:
                          ratingColor = Colors.orange;
                          break;
                        case 3:
                          ratingColor = Colors.yellow;
                          break;
                        case 4:
                          ratingColor = Colors.lightGreen;
                          break;
                        case 5:
                          ratingColor = Colors.green;
                          break;
                        default:
                          ratingColor = theme.colorScheme.primary;
                      }
                    } 
                    else {
                      // No rating, but check if there is a note
                      hasNoteNoRating = events[date]!.any((e) => (e['note'] as String?)?.trim().isNotEmpty == true && (e['rating'] == null));
                    }
                    // Check for future note (robust: support string, map, and ignore empty/whitespace)
                    hasFutureNote = events[date]!.any((e) {
                      final val = e['future_note'];
                      if (val == null) return false;
                      if (val is String) return val.trim().isNotEmpty;
                      if (val is Map) {
                        // Accept if any value in the map is a non-empty string
                        return val.values.any((v) => v is String && v.trim().isNotEmpty);
                      }
                      return false;
                    });
                  }

                  Widget dayContent = Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: TextStyle(
                              color: isSelected
                                  ? (theme.brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  : null,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (hasEvent)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Builder(
                                builder: (context) {
                                  if (ratingColor != null) {
                                    return Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: ratingColor,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  } else if (hasNoteNoRating) {
                                    // Draw a circle with background color and thin border
                                    return Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: theme.scaffoldBackgroundColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: theme.brightness == Brightness.dark
                                              ? Colors.white54
                                              : Colors.black54,
                                          width: 1.0,
                                        ),
                                      ),
                                    );
                                  } else if (isFuture && hasFutureNote) {
                                    return Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: theme.scaffoldBackgroundColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: theme.brightness == Brightness.dark
                                              ? Colors.white54
                                              : Colors.black54,
                                          width: 1.0,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                     
                        
                    ],
                  );
              
                  if (isFuture) {
                    dayContent = Opacity(
                      opacity: 0.4,
                      child: dayContent,
                    );
                  }
              
                  return GestureDetector(
                    onTap: () async {
                      onDayTap(date);
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: (theme.brightness == Brightness.dark
                                      ? Colors.grey[900]
                                      : Colors.grey[300]),
                              borderRadius: BorderRadius.circular(8),
                            )
                          : null,
                      child: dayContent,
                    ),
                  );
                },
              ),
            ),
            // SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

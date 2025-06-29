import 'package:dailyme/features/calendar/calendar.dart';
import 'package:dailyme/features/settings/setting_screen.dart';
import 'package:dailyme/features/pictures/pictures_screen.dart';
import 'package:dailyme/utils/utils_color/hex_color.dart';
import 'package:dailyme/utils/widgets/auto_save_info.dart';
import 'package:dailyme/utils/widgets/custom_textformfield.dart';
import 'package:dailyme/utils/widgets/loading_indicator.dart';
import 'package:dailyme/utils/widgets/day_rating.dart';
import 'package:dailyme/utils/storage/util_hive.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  // Helper to format date as 'YYYY-MM-DD'
  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
  Future<Map<String, dynamic>> _loadToday() async {
    final today = DateTime.now();
    final data = await HiveDayStorage.retrieveDay(today);
    // Always ensure normalized {date, note, rating}
    final initialData = {
      'date': data?['date'] ?? _dateKey(today),
      'note': data?['note'] ?? '',
      'rating': data?['rating'] ?? null,
    };
    // If no data existed, create an empty object for today in Hive
    if (data == null) {
      await HiveDayStorage.storeDay(today, initialData);
    }
    return initialData;
  }

  void _openSettings(BuildContext context) {
    // TODO: Implement settings navigation
     Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => Settings()),
    );
  }

  void _openCalendar(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CalendarPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Today',
          style: GoogleFonts.libreBaskerville(
            textStyle: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettings(context),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _openCalendar(context),
            tooltip: 'Calendar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Go to Pictures',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PicturesScreen()),
          );
        },
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        splashColor: Colors.black12,
        child: const Icon(Icons.photo_camera, color: Colors.black87, size: 28),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadToday(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CustomLoadingIndicatior();
          }
          final todayData = snapshot.data ?? {'note': '', 'mood': null};
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: _TodayContent(
              initialData: todayData,
            ),
          );
        },
      ),
    );
  }
}

class _TodayContent extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const _TodayContent({required this.initialData});

  @override
  State<_TodayContent> createState() => _TodayContentState();
}

class _TodayContentState extends State<_TodayContent> {
  late Map<String, dynamic> _todayData;

  @override
  void initState() {
    super.initState();
    _todayData = Map<String, dynamic>.from(widget.initialData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DayRatingBar(
          selectedRating: _todayData['rating'],
          onRatingSelected: (rating) async {
            setState(() {
              _todayData['rating'] = rating;
            });
            // Merge with latest Hive data to preserve pictures
            final today = DateTime.now();
            final latest = await HiveDayStorage.retrieveDay(today) ?? {};
            final merged = {
              ...latest,
              ..._todayData,
              'pictures': latest['pictures'] ?? <String>[],
            };
            HiveDayStorage.storeDay(today, merged);
            print('Today data: $merged');
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextFormField(
              showSuffix: false,
              expands: true,
              labelText: 'Whats going on today?',
              initialValue: _todayData['note'] ?? '',
              onChanged: (value) async {
                _todayData['note'] = value;
                // Merge with latest Hive data to preserve pictures
                final today = DateTime.now();
                final latest = await HiveDayStorage.retrieveDay(today) ?? {};
                final merged = {
                  ...latest,
                  ..._todayData,
                  'pictures': latest['pictures'] ?? <String>[],
                };
                HiveDayStorage.storeDay(today, merged);
                print('Today data: $merged');
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          // child: const AutoSaveInfo(),
        ),
      ],
    );
  }
}
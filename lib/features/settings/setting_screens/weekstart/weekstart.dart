import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class WeekStartSettings extends StatefulWidget {
  const WeekStartSettings({super.key});

  @override
  State<WeekStartSettings> createState() => _WeekStartSettingsState();
}

class _WeekStartSettingsState extends State<WeekStartSettings> {
  int _weekStart = 1; // 0 = Sunday, 1 = Monday

  @override
  void initState() {
    super.initState();
    _loadWeekStart();
  }

  Future<void> _loadWeekStart() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weekStart = prefs.getInt('weekStart') ?? 1;
    });
  }

  Future<void> _setWeekStart(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weekStart', value);
    setState(() {
      _weekStart = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Week Start Day',
          style: GoogleFonts.libreBaskerville(
            textStyle: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          RadioListTile<int>(
            value: 0,
            groupValue: _weekStart,
            onChanged: (v) => _setWeekStart(v!),
            title: const Text('Sunday'),
          ),
          RadioListTile<int>(
            value: 1,
            groupValue: _weekStart,
            onChanged: (v) => _setWeekStart(v!),
            title: const Text('Monday'),
          ),
        ],
      ),
    );
  }
}

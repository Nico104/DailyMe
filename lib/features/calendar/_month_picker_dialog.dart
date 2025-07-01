import 'package:flutter/material.dart';

class MonthPickerDialog extends StatefulWidget {
  final DateTime initialMonth;
  final int baseYear;

  /// The earliest entry in the data (if available)
  final DateTime? earliestEntry;

  const MonthPickerDialog({
    Key? key,
    required this.initialMonth,
    required this.baseYear,
    this.earliestEntry,
  }) : super(key: key);

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialMonth.year;
    _selectedMonth = widget.initialMonth.month;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentYear = now.year;
    // Determine earliest year (from earliestEntry if available, else baseYear)
    final int minYear = widget.earliestEntry?.year ?? widget.baseYear;
    // Allow up to 4 years in the future
    final int maxYear = currentYear + 4;
    final years = List.generate(maxYear - minYear + 1, (i) => maxYear - i);
    final months = const [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return AlertDialog(
      title: const Text('Select Month'),
      content: SizedBox(
        width: 320,
        height: 400,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: years.length,
                itemBuilder: (context, yearIdx) {
                  final year = years[years.length - 1 - yearIdx]; // most recent first
                  return ExpansionTile(
                    title: Text('$year'),
                    initiallyExpanded: year == _selectedYear,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(12, (monthIdx) {
                          // Only allow months >= earliestEntry (if in minYear)
                          bool beforeEarliest = false;
                          if (widget.earliestEntry != null && year == minYear) {
                            beforeEarliest = (monthIdx + 1) < widget.earliestEntry!.month;
                          }
                          final isSelected = year == _selectedYear && monthIdx + 1 == _selectedMonth;
                          // Hide non-clickable months
                          if (beforeEarliest) return const SizedBox.shrink();
                          return ElevatedButton(
                            onPressed: isSelected
                                ? null
                                : () {
                                    setState(() {
                                      _selectedYear = year;
                                      _selectedMonth = monthIdx + 1;
                                    });
                                    Navigator.of(context).pop(DateTime(year, monthIdx + 1));
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Theme.of(context).disabledColor
                                  : null,
                            ),
                            child: Text(months[monthIdx]),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

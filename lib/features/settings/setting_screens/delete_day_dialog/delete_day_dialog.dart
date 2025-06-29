import 'package:flutter/material.dart';

class DeleteDayDialog extends StatefulWidget {
  final List<DateTime> availableDays;
  final Future<void> Function(DateTime selectedDay) onDelete;

  const DeleteDayDialog({
    super.key,
    required this.availableDays,
    required this.onDelete,
  });

  @override
  State<DeleteDayDialog> createState() => _DeleteDayDialogState();
}

class _DeleteDayDialogState extends State<DeleteDayDialog> {
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete Day Entry',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButton<DateTime>(
              isExpanded: true,
              hint: const Text('Select a day'),
              value: _selectedDay,
              items: widget.availableDays
                  .map(
                    (day) => DropdownMenuItem<DateTime>(
                      value: day,
                      child: Text(
                        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}",
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDay = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedDay == null
                      ? null
                      : () async {
                          widget.onDelete(_selectedDay!).then((value) {
                            Navigator.pop(context);
                          },);
                          if (mounted) {
                            Navigator.pop(context);
                            // Show snackbar after popping dialog
                            Future.delayed(const Duration(milliseconds: 100), () {
                              final rootContext = Navigator.of(context).context;
                              ScaffoldMessenger.of(rootContext).showSnackBar(
                                SnackBar(
                                  content: Text('Entry for '
                                      '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')} deleted.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            });
                          }
                        },
                  child: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Usage example (showing the dialog):
// showDialog(
//   context: context,
//   builder: (context) => DeleteDayDialog(
//     availableDays: yourListOfDays,
//     onDelete: (selectedDay) { /* handle deletion */ },
//   ),
// );
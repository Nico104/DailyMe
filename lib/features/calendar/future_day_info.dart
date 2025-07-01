import 'package:flutter/material.dart';

/// Minimalist future day summary widget
/// ------------------------------------------------------------
/// • No card wrapper – blends into any parent
/// • Shows the date (optionally)
/// • Shows the future note or a fallback message
/// • Edit button for the future note
class FutureDayInfo extends StatelessWidget {
  final DateTime date;
  final String? futureNote;
  final VoidCallback? onEdit;
  final bool showDate;

  const FutureDayInfo({
    super.key,
    required this.date,
    this.futureNote,
    this.onEdit,
    this.showDate = true,
  });

  static const _monthShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')} ${_monthShort[d.month - 1]} ${d.year}";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDate)
                  Text(
                    _formatDate(date),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Spacer(),
                if (onEdit != null)
                  Container(
                    decoration: BoxDecoration(
                     color:  theme.brightness == Brightness.light
                        ? Colors.white
                        : Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:  theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                        width: 1.0,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit Future Note',
                      onPressed: onEdit,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              (futureNote != null && futureNote!.trim().isNotEmpty)
                  ? futureNote!
                  : 'No future note.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

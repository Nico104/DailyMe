import 'package:flutter/material.dart';
import 'dart:io';

/// Minimalist day summary widget (super subtle empty state)
class DayInfo extends StatelessWidget {
  final DateTime date;
  final String? note;
  final int? rating; // 1‑5
  final List<String>? picturePaths;
  final bool showDate;

  const DayInfo({
    super.key,
    required this.date,
    this.note,
    this.rating,
    this.picturePaths,
    this.showDate = true,
  });

  static const _monthShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')} ${_monthShort[d.month - 1]} ${d.year}";

  Color _ratingColor(BuildContext context, int? r) {
    switch (r) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.amber;
      case 4: return Colors.lightGreen;
      case 5: return Colors.green;
      default: return Theme.of(context).colorScheme.outlineVariant;
    }
  }

  Widget _buildRatingDot(BuildContext context) {
    if (rating == null) return const SizedBox.shrink();
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: _ratingColor(context, rating),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildEmptyStateText(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 2),
      child: Text(
        'Nothing added for this day.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.22),
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNote = note != null && note!.trim().isNotEmpty;
    final hasPictures = picturePaths != null && picturePaths!.isNotEmpty;

    void showImageDialog(String path) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 64),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Super-subtle faded text if empty
    if (!hasNote && !hasPictures) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildRatingDot(context),
              Text(
                _formatDate(date),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w100,
                ),
              ),
            ],
          ),
          _buildEmptyStateText(context),
        ],
      );
    }

    // Normal state with notes or pictures
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildRatingDot(context),
            Text(
              _formatDate(date),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w100,
              ),
            ),
          ],
        ),
        if (hasNote)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              note!,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        if (hasPictures)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: picturePaths!.length,
                separatorBuilder: (context, idx) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final path = picturePaths![idx];
                  return GestureDetector(
                    onTap: () => showImageDialog(path),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 32),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

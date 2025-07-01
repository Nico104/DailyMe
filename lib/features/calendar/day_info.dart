import 'package:flutter/material.dart';
import 'dart:io';

/// Minimalist day summary widget (rev 4)
/// ------------------------------------------------------------
/// • No card wrapper – blends into any parent
/// • Rating shown as a tiny colour dot (no icons / numbers)
/// • Friendly date in “02 May 2025” format
/// • Optional note underneath with subtle styling
class DayInfo extends StatelessWidget {
  final DateTime date;
  final String? note;
  final int? rating; // 1‑5
  final List<String>? picturePaths; // List of image file paths for this day
  final bool showDate;

  const DayInfo({
    super.key,
    required this.date,
    this.note,
    this.rating,
    this.picturePaths,
    this.showDate = true,
  });

  // ------------------------------------------------------------- Helpers
  static const _monthShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')} ${_monthShort[d.month - 1]} ${d.year}";

  /// Map rating 1‑5 → solid colour
  Color _ratingColor(BuildContext context, int? r) {
    switch (r) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        // outlineVariant is never null in recent Flutter, so just use it
        return Theme.of(context).colorScheme.outlineVariant;
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

  // --------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Date and rating dot
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildRatingDot(context),
            Text(
              _formatDate(date),
              // "xdfff",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w100,
              ),
            ),
          ],
        ),
    
        // Note section
        if (note != null && note!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              note!,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          )
          else
           Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 0),
                  child: Text(
                    'No pictures for this entry.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
    
        // Pictures section
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: (picturePaths != null && picturePaths!.isNotEmpty)
              ? SizedBox(
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
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Text(
                    'No pictures for this entry.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

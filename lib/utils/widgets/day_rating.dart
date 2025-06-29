import 'package:dailyme/utils/utils_color/hex_color.dart';
import 'package:dailyme/utils/utils_color/u_day_rating_colors.dart';
import 'package:flutter/material.dart';

class DayRatingBar extends StatelessWidget {
  final int? selectedRating;
  final ValueChanged<int> onRatingSelected;

  const DayRatingBar({super.key, required this.selectedRating, required this.onRatingSelected});

  final selectedBackgroundOpacity = 0.3; // Opacity for selected background color
  final selectedNumberOpacity = 1.0; // Opacity for selected number color

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 3.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.black
                    : Colors.grey[900]!,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: List.generate(5, (index) {
                final ratingValue = index + 1;
                final isSelected = selectedRating == ratingValue;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus(); // Unfocus any text field
                      if (isSelected) {
                        onRatingSelected(0); // Unselect if already selected
                      } else {
                        onRatingSelected(ratingValue);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? HexColor([
                                dayRatingColor1,
                                dayRatingColor2,
                                dayRatingColor3,
                                dayRatingColor4,
                                dayRatingColor5,
                              ][index]).withValues(alpha: selectedBackgroundOpacity)
                            : Colors.transparent,
                        borderRadius: index == 0
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(14),
                                bottomLeft: Radius.circular(14),
                              )
                            : index == 4
                                ? const BorderRadius.only(
                                    topRight: Radius.circular(14),
                                    bottomRight: Radius.circular(14),
                                  )
                                : BorderRadius.zero,
                        boxShadow: [],
                        border: isSelected
                            ? Border.all(
                                color: Colors.transparent,
                                width: 0,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: isSelected
                              ? HexColor([
                                  dayRatingColor1,
                                  dayRatingColor2,
                                  dayRatingColor3,
                                  dayRatingColor4,
                                  dayRatingColor5,
                                ][index]).withValues(alpha: selectedNumberOpacity)
                              : theme.textTheme.bodyLarge?.color,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 18,
                        ),
                        child: Text(ratingValue.toString()),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
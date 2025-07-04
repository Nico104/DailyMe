
import 'package:dailyme/features/today.dart';
import 'package:flutter/material.dart';

class ThemeSelectionContainer extends StatefulWidget {
  const ThemeSelectionContainer({
    super.key,
    required this.isActive,
    // required this.onTap,
    required this.label,
    required this.themeData,
  });

  final bool isActive;
  // final VoidCallback onTap;

  final String label;
  final ThemeData themeData;

  @override
  State<ThemeSelectionContainer> createState() =>
      _ThemeSelectionContainerState();
}

class _ThemeSelectionContainerState extends State<ThemeSelectionContainer> {
  final double _borderRadius = 22;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeData,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(_borderRadius),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.themeData.primaryColor,
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        widget.label,
                        style: widget.themeData.appBarTheme.titleTextStyle
                            ?.copyWith(
                          fontSize: widget.themeData.appBarTheme.titleTextStyle!
                                  .fontSize! *
                              1.3,
                        ),
                      ),
                    ),
                    // const SizedBox(height: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(36),
                          topRight: const Radius.circular(36),
                          bottomLeft: Radius.circular(_borderRadius),
                          bottomRight: Radius.circular(_borderRadius),
                        ),
                        child: IgnorePointer(
                          child: TodayScreen(
                            // petProfileDetails: widget.petProfileDetails,
                            // showAppbar: false,
                            // showDescriptions: false,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: SizedBox.shrink(
                //     child: ClipRRect(
                //       borderRadius: BorderRadius.circular(69),
                //       child: BackdropFilter(
                //         filter: ImageFilter.blur(
                //           sigmaX: 16,
                //           sigmaY: 16,
                //         ),
                //         child: Container(
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(69),
                //             gradient: LinearGradient(
                //               begin: Alignment.topLeft,
                //               end: Alignment.bottomRight,
                //               colors: [
                //                 Color(0xFFffffff).withOpacity(0.1),
                //                 Color(0xFFFFFFFF).withOpacity(0.05),
                //               ],
                //               stops: [
                //                 0.1,
                //                 1,
                //               ],
                //             ),
                //           ),
                //           padding: EdgeInsets.all(32),
                //           margin: EdgeInsets.all(32),
                //           alignment: Alignment.center,
                //           child: Text(
                //             widget.label,
                //             style: widget.themeData.appBarTheme.titleTextStyle
                //                 ?.copyWith(
                //               fontSize: widget.themeData.appBarTheme.titleTextStyle!
                //                       .fontSize! *
                //                   1.3,
                //             ),
                //             textAlign: TextAlign.start,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: GlassmorphicContainer(
                //     width: double.infinity,
                //     height: 80,
                //     borderRadius: 60,
                //     blur: 20,
                //     padding: EdgeInsets.all(16),
                //     margin: EdgeInsets.fromLTRB(32, 16, 32, 16),
                //     alignment: Alignment.center,
                //     border: 0.5,
                //     linearGradient: LinearGradient(
                //         begin: Alignment.topLeft,
                //         end: Alignment.bottomRight,
                //         colors: [
                //           // Color(0xFFffffff).withOpacity(0.1),
                //           // Color(0xFFFFFFFF).withOpacity(0.05),
                //           Colors.white
                //         ],
                //         stops: [
                //           0.1,
                //           1,
                //         ]),
                //     borderGradient: LinearGradient(
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //       colors: [
                //         Color(0xFFffffff).withOpacity(0.5),
                //         Color((0xFFFFFFFF)).withOpacity(0.5),
                //       ],
                //     ),
                //     child: Text(
                //       widget.label,
                //       style: widget.themeData.appBarTheme.titleTextStyle?.copyWith(
                //         fontSize:
                //             widget.themeData.appBarTheme.titleTextStyle!.fontSize! *
                //                 1.3,
                //       ),
                //       textAlign: TextAlign.start,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

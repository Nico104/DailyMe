import 'package:dailyme/utils/utils_theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoadingIndicatior extends StatelessWidget {
  const CustomLoadingIndicatior({super.key});

  @override
  Widget build(BuildContext context) {
    return SpinKitPulse(
      // color: getCustomColors(context).accent,
      color: Colors.black,
      duration: const Duration(milliseconds: 250),
    );
  //   return SpinKitSpinningLines(
  //   color: getCustomColors(context).accent ?? Theme.of(context).colorScheme.primary,
  // );
  }
}

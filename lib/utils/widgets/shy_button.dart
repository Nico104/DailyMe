import 'package:auto_size_text/auto_size_text.dart';
import 'package:dailyme/utils/utils_theme/custom_colors.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';

class ShyButton extends StatelessWidget {
  const ShyButton({
    super.key,
    required this.showUploadButton,
    required this.onTap,
    required this.label,
    this.icon,
    this.bgColor,
    this.fontColor,
    this.iconBgColor,
  });

  final bool showUploadButton;
  final void Function() onTap;
  final String label;

  final double _borderRadius = 32;
  final double _height = 65;

  final Icon? icon;

  final Color? bgColor;
  final Color? iconBgColor;
  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: AnimatedAlign(
          alignment: showUploadButton
              ? const Alignment(0.0, 1.0)
              : const Alignment(0.0, 3.0),
          duration: const Duration(milliseconds: 80),
          curve: Curves.fastOutSlowIn,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
              onTap: () => onTap(),
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
                elevation: 6,
                child: Container(
                  height: _height,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.circular(_borderRadius)),
                    // color: Theme.of(context).primaryColor.withOpacity(1),
                    color: bgColor ?? getCustomColors(context).accent,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: icon != null
                              ? const EdgeInsets.only(left: 32, right: 24)
                              : const EdgeInsets.only(left: 32, right: 32),
                          child: AutoSizeText(
                            label,
                            maxLines: 1,
                            // style: GoogleFonts.prompt(
                            //   fontWeight: FontWeight.w400,
                            //   fontSize: 16,
                            //   color: fontColor ?? Colors.white,
                            // ),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: fontColor ?? Colors.white),
                          ),
                        ),
                        icon != null
                            ? AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  height: _height,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(_borderRadius)),
                                    // color: Theme.of(context).primaryColor.withOpacity(1),
                                    color: iconBgColor ??
                                        getCustomColors(context).lightBorder,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Center(
                                    child: icon,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void handleShyButtonShown({required Function(bool) setShowShyButton}) {
  //hideBar
  // setState(() {
  //   _showUploadButton = false;
  // });
  setShowShyButton(false);
  EasyDebounce.debounce(
    'handleShyButton',
    const Duration(milliseconds: 200),
    () {
      //shwoNavbar
      // setState(() {
      //   _showUploadButton = true;
      // });
      setShowShyButton(true);
    },
  );
}

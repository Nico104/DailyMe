
import 'package:dailyme/utils/utils_theme/custom_colors.dart';
import 'package:dailyme/utils/utils_theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeSettings extends StatefulWidget {
  const ThemeSettings({super.key});

  @override
  State<ThemeSettings> createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "appBarTitleThemeSettings",
          style: GoogleFonts.libreBaskerville(
            textStyle: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
      ),
      // --- Original theme selection UI commented out ---
      /*
      body: Consumer<ThemeNotifier>(
        builder: (context, theme, _) => ListView(
          children: [
            ThemeSelectionContainer(
              isActive: theme.getTheme() == theme.lightTheme,
              onTap: () {
                if (theme.getTheme() != theme.lightTheme) {
                  theme.setLightTheme();
                }
              },
              label: "lightModeLabel",
              themeData: theme.lightTheme,
            ),
            ThemeSelectionContainer(
              isActive: theme.getTheme() == theme.darkTheme,
              onTap: () {
                if (theme.getTheme() != theme.darkTheme) {
                  theme.setDarkTheme();
                }
              },
              label: "darkModeLabel",
              themeData: theme.darkTheme,
            ),
          ],
        ),
      ),
      */
      body: Consumer<ThemeNotifier>(
        builder: (context, theme, _) {
          final currentTheme = theme.themeMode;
          return ListView(
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Theme'),
                value: ThemeMode.system,
                groupValue: currentTheme,
                onChanged: (mode) {
                  if (mode != null) theme.setSystemTheme();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light Theme'),
                value: ThemeMode.light,
                groupValue: currentTheme,
                onChanged: (mode) {
                  if (mode != null) theme.setLightTheme();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Theme'),
                value: ThemeMode.dark,
                groupValue: currentTheme,
                onChanged: (mode) {
                  if (mode != null) theme.setDarkTheme();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class ThemeSelectionContainer extends StatelessWidget {
  const ThemeSelectionContainer({
    super.key,
    required this.isActive,
    required this.onTap,
    required this.label,
    required this.themeData,
  });

  final bool isActive;
  final VoidCallback onTap;

  final String label;
  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(28),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          // color: isActive ? themeData.primaryColor : Colors.transparent,
          color: isActive ? themeData.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: kElevationToShadow[isActive ? 4 : 0],
        ),
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: themeData.primaryColorDark,
                border: Border.all(
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignOutside,
                  // color: themeData.extension<CustomColors>()?.lightBorder ??
                  //     Colors.transparent,
                  color: themeData.canvasColor,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.85,
                heightFactor: 0.75,
                alignment: FractionalOffset.bottomRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: themeData.primaryColor,
                    //To only have it on top and left side plus keep border Radius
                    boxShadow: [
                      BoxShadow(
                          color: themeData
                                  .extension<CustomColors>()
                                  ?.lightBorder ??
                              Colors.transparent,
                          blurRadius: 0,
                          offset: const Offset(-1, -1)),
                    ],
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Aa",
                    style: themeData.textTheme.headlineLarge,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                isActive
                    ? Chip(
                        label: Text(
                        "themeActiveLabel",
                        style: themeData.textTheme.labelSmall,
                      ))
                    : const SizedBox(),
              ],
            )
          ],
        ),
      ),
    );
  }
}

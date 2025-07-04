import 'dart:ui';
import 'package:dailyme/features/settings/setting_screens/theme_settings/system_theme_widget.dart';
import 'package:dailyme/features/settings/setting_screens/theme_settings/theme_item.dart';
import 'package:dailyme/utils/utils_theme/store_manager.dart';
import 'package:dailyme/utils/utils_theme/theme_provider.dart';
import 'package:flutter/material.dart';
class ThemeSelectionPage extends StatefulWidget {
  const ThemeSelectionPage({
    super.key,
    required this.theme,
  });

  final ThemeNotifier theme;

  @override
  State<ThemeSelectionPage> createState() => _ThemeSelectionPageState();
}

class _ThemeSelectionPageState extends State<ThemeSelectionPage> {
  final PageController _pageController = PageController(viewportFraction: 1);

  Map<int, ThemeSelectionContainer> map = {};
  int darkTheme = 0;
  int lightTheme = 1;

  bool isSystemActive = false;

  late ThemeNotifier theme;
  final double _buttonHeight = 55 + 18;

  @override
  void initState() {
    super.initState();

    theme = widget.theme;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await StorageManager.readData('themeMode').then(
        (value) {
          if (value == 'system') {
            setState(() {
              isSystemActive = true;
            });
          }
        },
      );
    });

    generateMap();
  }

  void generateMap() {
    map.clear();
    if (theme.getTheme() == theme.lightTheme) {
      darkTheme = 1;
      lightTheme = 0;
    } else {
      darkTheme = 0;
      lightTheme = 1;
    }
    map[darkTheme] = ThemeSelectionContainer(
      isActive: theme.getTheme() == theme.darkTheme,
      label: "darkModeLabel",
      themeData: theme.darkTheme,
    );
    map[lightTheme] = ThemeSelectionContainer(
      isActive: theme.getTheme() == theme.lightTheme,
      label: "lightModeLabel",
      themeData: theme.lightTheme,
    );
    var mapEntries = map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    map
      ..clear()
      ..addEntries(mapEntries);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("appBarTitleThemeSettings"),
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: _buttonHeight),
                child: PageView(
                  physics: const BouncingScrollPhysics(),
                  controller: _pageController,
                  pageSnapping: true,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    if (index == darkTheme) {
                      if (theme.getTheme() != theme.darkTheme) {
                        theme.setDarkTheme();
                      }
                    } else if (index == lightTheme) {
                      if (theme.getTheme() != theme.lightTheme) {
                        theme.setLightTheme();
                      }
                    }
                  },
                  children: map.values.toList(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ChooseSystemTheme(
              isActive: isSystemActive,
              setSystemThemeActivity: (p0) async {
                if (p0) {
                  theme.setSystemTheme().then((value) {
                    generateMap();
                    _pageController.jumpToPage(0);
                  });
                  await Future.delayed(const Duration(milliseconds: 125));
                  setState(() {
                    isSystemActive = true;
                  });

                  // refreshThemeData();
                  // map.clear();
                } else {
                  setState(() {
                    isSystemActive = false;
                  });
                  if (Theme.of(context).brightness == Brightness.dark) {
                    await theme.setDarkTheme();
                    generateMap();
                    _pageController.jumpToPage(0);
                  } else {
                    await theme.setLightTheme();
                    generateMap();
                    _pageController.jumpToPage(0);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

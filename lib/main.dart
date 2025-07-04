// import 'dart:js';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

import 'package:dailyme/features/today.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dailyme/utils/storage/util_hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sizer/sizer.dart';
import 'package:toastification/toastification.dart';
import 'package:dailyme/utils/utils_theme/theme_provider.dart';
import 'package:provider/provider.dart';
// import 'general/utils_firebase/firebase_options.dart';
// import 'init_app.dart';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;

// if (Platform.isIOS) {
//   await Firebase.initializeApp(
//       options: FirebaseOptions(
//           apiKey: "your api key Found in GoogleService-info.plist",
//           appId: "Your app id found in Firebase",
//           messagingSenderId: "Your Sender id found in Firebase",
//           projectId: "Your Project id found in Firebase"));
// } else {
//   await Firebase.initializeApp();
// }

// ...existing imports...
void main() async {
  // Uncomment to generate random test data:
  
  // Needs to be called so that we can await for EasyLocalization.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  // await EasyLocalization.ensureInitialized();
  // await _initFirebase();

  WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // FlutterNativeSplash.removeAfter(initialization);
  // FlutterNativeSplash.remove();

  final runnableApp = _buildRunnableApp(
    isWeb: kIsWeb,
    // webAppWidth: double.infinity,
    // webAppWidth: 680,
    // webAppHeight: 1080,
    webAppWidth: 1179 / 2,
    webAppHeight: 2556 / 2,
    app: const MyApp(),
  );
  // Hive.init(Directory.current.path);
  await Hive.initFlutter();
  runApp(
    MultiProvider(
        providers: [
          // ChangeNotifierProvider<ConnectionService>(
          //     create: (_) => ConnectionService()),
          ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier()),
          // ChangeNotifierProvider<UploadStatus>(create: (_) => UploadStatus())
        ],
        // child: const MyApp(),
        child: runnableApp,
      ),
    // EasyLocalization(
    //   useOnlyLangCode: true,
    //   supportedLocales: const [
    //     Locale('en'),
    //     Locale('de'),
    //     Locale('it'),
    //     Locale('hu'),
    //     // Locale('no'),
    //     // Locale('fr'),
    //   ],
    //   path:
    //       'assets/translations', // <-- change the path of the translation files
    //   // startLocale: ,
    //   fallbackLocale: const Locale('en'),
    //   child: MultiProvider(
    //     providers: [
    //       // ChangeNotifierProvider<ConnectionService>(
    //       //     create: (_) => ConnectionService()),
    //       ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier()),
    //       // ChangeNotifierProvider<UploadStatus>(create: (_) => UploadStatus())
    //     ],
    //     // child: const MyApp(),
    //     child: runnableApp,
    //   ),
    // ),
  );
}

Widget _buildRunnableApp({
  required bool isWeb,
  required double webAppWidth,
  required double webAppHeight,
  required Widget app,
}) {
  if (!isWeb) {
    return app;
  }

  return SizedBox(
    width: double.infinity,
    height: double.infinity,
    child: Center(
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: webAppWidth,
            height: webAppHeight,
            child: app,
          ),
        ),
      ),
    ),
  );
}

Future initialization(BuildContext? context) async {
  /// Load resources
  await Future.delayed(const Duration(seconds: 3));
}

// Future<void> _initFirebase() async {
//   // if (!kIsWeb) {
//   //   if (Platform.isAndroid || Platform.isIOS) {
//   //     await Firebase.initializeApp(
//   //       options: DefaultFirebaseOptions.currentPlatform,
//   //     );
//   //   }
//   // }
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // context.setLocale(Locale('hu'));
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Consumer<ThemeNotifier>(builder: (context, theme, _) {
          return ToastificationWrapper(
            child: MaterialApp(
              // localizationsDelegates: context.localizationDelegates,
              // supportedLocales: context.supportedLocales,
              // locale: context.locale,
              title: 'DailyMe',
              debugShowCheckedModeBanner: false,
              theme: theme.getTheme(),
              home: const TodayScreen(),
            ),
          );
        });
      },
    );
  }
}

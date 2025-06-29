
// import 'package:dailyme/utils/utils_general.dart';
// import 'package:dailyme/utils/widgets/custom_scroll_view.dart';
// import 'package:flutter/material.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:provider/provider.dart';
// import '../features/settings/utils/widgets/settings_widgets.dart';

// import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart' show kIsWeb;

// class Settings extends StatefulWidget {


//   @override
//   State<Settings> createState() => _SettingsState();
// }

// class _SettingsState extends State<Settings> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ScrollConfiguration(
//         behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
//         child: CustomNicoScrollView(
//           title: Text(
//             "appBarTitleSettings",
//             style: Theme.of(context).appBarTheme.titleTextStyle,
//           ),
//           centerTitle: true,
//           onScroll: () {},
//           body: Column(
//             // controller: _scrollSontroller,
//             children: [
//               const SizedBox(height: 42),
//               SettingsContainer(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "settingsSectionTitleGeneral",
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 20),
//                     SettingsItem(
//                       label: "settingsItemAccount",
//                       leading: const Icon(Icons.person_outline),
//                       suffix: const Icon(Icons.keyboard_arrow_right),
//                       onTap: () {
//                         navigatePerSlide(context, const AccountSettings());
//                       },
//                     ),
//                     const SizedBox(height: settingItemSpacing),
//                     SettingsItem(
//                       label: "settingsItemMyTags",
//                       leading: const Icon(Icons.hexagon_outlined),
//                       suffix: const Icon(Icons.keyboard_arrow_right),
//                       onTap: () {
//                         navigatePerSlide(
//                           context,
//                           const MyTagsSettings(),
//                         );
//                         // Navigator.push(
//                         //   context,
//                         //   MaterialPageRoute(
//                         //     builder: (context) => const MyTagsSettings(),
//                         //   ),
//                         // );
//                       },
//                     ),
//                     const SizedBox(height: settingItemSpacing),
//                     SettingsItem(
//                       label: "settingsItemNotifications",
//                       leading: const Icon(CustomIcons.notification),
//                       suffix: const Icon(Icons.keyboard_arrow_right),
//                       onTap: () {
//                         navigatePerSlide(
//                           context,
//                           const NotificationSettingsPage(),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: settingItemSpacing),
              
//                     Hero(
//                       tag: "settingsLang",
//                       child: SettingsItem(
//                         label: "settingsItemLangauge",
//                         leading: const Icon(Icons.translate),
//                         suffix: const Icon(Icons.keyboard_arrow_right),
//                         onTap: () {
//                           // navigatePerSlide(
//                           //   context,
//                           //   const ChangeLanguage(),
//                           // );
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => LanguageSelector(
//                                 activeLanguage: getLanguageFromKey(
//                                     context.locale.toString())!,
//                                 unavailableLanguages: const [],
//                                 availableLanguages: availableLanguages,
//                                 title: "appBarLangaugeSettings",
//                                 heroTag: "settingsLang",
//                               ),
//                             ),
//                           ).then((value) async {
//                             if (value is Language) {
//                               await context
//                                   .setLocale(Locale(value.languageKey));
//                               //For Notification
//                               // updateUserAppLanguageBackendSync(
//                               //     value.languageKey);
//                               updateUserAppLanguageBackendSync(
//                                   context.locale.toString());

//                               //Wait otherwise Language doesnt update 
//                               await Future.delayed(
//                                   const Duration(milliseconds: 125));
//                               setState(() {});
//                             }
//                           });
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: settingItemSpacing),
//                     SettingsItem(
//                       label: "settingsItemHowToUse",
//                       leading: const Icon(Icons.lightbulb_outline),
//                       suffix: const Icon(Icons.keyboard_arrow_right),
//                       onTap: () {
//                         // showHowToDialog(context);
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               //Shop
//               SettingsContainer(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "settingsSectionTitleShop",
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 20),
//                     SettingsItem(
//                       label: "settingsItemGoShop",
//                       leading: const Icon(CustomIcons.shopping_bag_8),
//                       suffix: const Icon(Icons.keyboard_arrow_right),
//                       onTap: () async {
//                         // navigatePerSlide(
//                         //   context,
//                         //   const ComingSoonPage(title: "Shop"),
//                         // );
//                         await launchUrl(Uri.parse(shopUrl),
//                             mode: LaunchMode.externalApplication);
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               //Help and Support
//               SettingsContainer(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "settingsSectionTitleHelp",
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 20),
//                     // SettingsItem(
//                     //   label: "settingsItemReportBug",
//                     //   leading: Icon(Icons.warning_amber_rounded),
//                     //   suffix: Icon(Icons.keyboard_arrow_right),
//                     //   onTap: () {
//                     //     navigatePerSlide(
//                     //       context,
//                     //       const ComingSoonPage(title: "Report Bug"),
//                     //     );
//                     //   },
//                     // ),
//                     // const SizedBox(height: settingItemSpacing),
//                     SettingsItem(
//                       label: "settingsItemContactUs",
//                       leading: const Icon(CustomIcons.notification),
//                       suffix: const Icon(Icons.keyboard_arrow_right),
//                       // onTap: () {
//                       //   navigatePerSlide(context, const ContactUs());
//                       // },
//                       onTap: () {
//                         showContactUsOptions(context);
//                         // navigatePerSlide(
//                         //   context,
//                         //   const ContactUs(),
//                         // );
//                       },
//                     ),
//                     const SizedBox(height: settingItemSpacing),
//                     // SettingsItem(
//                     //   label: "settingsItemFAQ",
//                     //   leading: const Icon(Icons.question_answer_outlined),
//                     //   suffix: const Icon(Icons.keyboard_arrow_right),
//                     //   onTap: () async {
//                     //     // navigatePerSlide(
//                     //       // context,
//                     //     //   const ComingSoonPage(title: "FAQ"),
//                     //     // );
//                     //     await launchUrl(Uri.parse("http://finmapet.com"),
//                     //         mode: LaunchMode.externalApplication);
//                     //   },
//                     // ),
//                     // const SizedBox(height: settingItemSpacing),
//                     SettingsItem(
//                       label: "settingsItemPrivacy",
//                       leading: const Icon(Icons.privacy_tip_outlined),
//                       suffix: const Icon(Icons.keyboard_arrow_right),
//                       onTap: () async {
//                         // navigatePerSlide(
//                         //   context,
//                         //   const ComingSoonPage(title: "Privacy"),
//                         // );
//                         await launchUrl(Uri.parse("http://finmapet.com"),
//                             mode: LaunchMode.externalApplication);
//                       },
//                     ),
//                     // const SizedBox(height: settingItemSpacing),
//                     // SettingsItem(
//                     //   label: "settingsItemAbout",
//                     //   leading: const Icon(Icons.question_mark),
//                     //   suffix: const Icon(Icons.keyboard_arrow_right),
//                     //   onTap: () async {
//                     //     // navigatePerSlide(
//                     //     //   context,
//                     //     //   const ComingSoonPage(title: "About"),
//                     //     // );
//                     //     await launchUrl(Uri.parse("http://finmapet.com"),
//                     //         mode: LaunchMode.externalApplication);
//                     //   },
//                     // ),
//                   ],
//                 ),
//               ),

//               SettingsContainer(
//                 child: SettingsItem(
//                   label: "settingsItemLogout",
//                   leading: const Icon(
//                     Icons.logout_outlined,
//                     color: Colors.red,
//                   ),
//                   suffix: const Icon(Icons.keyboard_arrow_right),
//                   onTap: () async {
//                     BuildContext context2 = context;
//                     showCustomNicoLoadingModalBottomSheet(
//                       context: context2,
//                       future: null,
//                       callback: (p0) {},
//                     );
//                     // showNicoModalBottomSheet(
//                     //     context: context2,
//                     //     backgroundColor: Colors.transparent,
//                     //     builder: (context) {
//                     //       return const Center(
//                     //         child: SizedBox(
//                     //           width: 40,
//                     //           height: 40,
//                     //           child: CustomLoadingIndicatior(),
//                     //         ),
//                     //       );
//                     //     });

//                     if (!kIsWeb) {
//                       if (Platform.isAndroid || Platform.isIOS) {
//                         firebaseMessaging.FirebaseMessaging messaging =
//                             firebaseMessaging.FirebaseMessaging.instance;
//                         await messaging.getToken().then((fcmToken) async {
//                           if (fcmToken != null) {
//                             await deleteDeviceToken(fcmToken);
//                           }
//                         });
//                       }
//                     }

//                     // logout();

//                     logout().then(
//                       (value) {
//                         Future.delayed(Durations.short4).then(
//                           (value) {
//                             Navigator.pop(context2);
//                             Navigator.pushAndRemoveUntil(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => const InitApp()),
//                                 (route) => false);
//                           },
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),

//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 // child: Text(
//                 //   "Every change gets saved and uploaded automatically",
//                 //   style: Theme.of(context).textTheme.labelSmall,
//                 //   textAlign: TextAlign.center,
//                 // ),
//                 child: _buildVersionInfoText(),
//               ),
//               const SizedBox(height: 28),
//             ],
//           ),
//           // SliverToBoxAdapter(
//           //   child: Container(
//           //     color: Theme.of(context).primaryColor,
//           //     child:
//           //   ),
//           // ),
//         ),
//       ),
//     );
//   }
// }

// Widget _buildVersionInfoText() {
//   return FutureBuilder<PackageInfo>(
//     future: PackageInfo.fromPlatform(),
//     builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
//       if (snapshot.hasData) {
//         return Text(
//           "Version: ${snapshot.data!.version}",
//           style: Theme.of(context).textTheme.labelSmall,
//           textAlign: TextAlign.center,
//         );
//       } else if (snapshot.hasError) {
//         return Text(
//           "error loading version",
//           style: Theme.of(context).textTheme.labelSmall,
//           textAlign: TextAlign.center,
//         );
//       } else {
//         return Text(
//           "Loading Version",
//           style: Theme.of(context).textTheme.labelSmall,
//           textAlign: TextAlign.center,
//         );
//       }
//     },
//   );
// }

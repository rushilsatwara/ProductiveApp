import 'dart:io';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:zest/app/controller/isar_contoller.dart';
import 'package:zest/app/ui/home.dart';
import 'package:zest/app/ui/onboarding.dart';
import 'package:zest/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isar/isar.dart';
import 'package:zest/theme/theme_controller.dart';
import 'package:zest/app/utils/device_info.dart';
import 'app/data/db.dart';
// import 'translation/translation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

late Isar isar;
late Settings settings;

bool amoledTheme = false;
bool materialColor = false;
bool isImage = true;
String timeformat = '24';
String firstDay = 'monday';
Locale locale = const Locale('en', 'US');

List<String> allScreens = [];

void main() async {
  final String timeZoneName;
  WidgetsFlutterBinding.ensureInitialized();
  DeviceFeature().init();
  if (Platform.isAndroid) {
    await setOptimalDisplayMode();
  }
  timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  const DarwinInitializationSettings initializationSettingsIos =
      DarwinInitializationSettings();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Zest');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    linux: initializationSettingsLinux,
    iOS: initializationSettingsIos,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await IsarController().openDB();
  await initSettings();
  runApp(const MyApp());
}

Future<void> setOptimalDisplayMode() async {
  final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  final DisplayMode active = await FlutterDisplayMode.active;
  final List<DisplayMode> sameResolution =
      supported
          .where(
            (DisplayMode m) =>
                m.width == active.width && m.height == active.height,
          )
          .toList()
        ..sort(
          (DisplayMode a, DisplayMode b) =>
              b.refreshRate.compareTo(a.refreshRate),
        );
  final DisplayMode mostOptimalMode =
      sameResolution.isNotEmpty ? sameResolution.first : active;
  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
}

Future<void> initSettings() async {
  settings = isar.settings.where().findFirstSync() ?? Settings();
  if (settings.language == null) {
    settings.language = '${Get.deviceLocale}';
    isar.writeTxnSync(() => isar.settings.putSync(settings));
  }

  if (settings.theme == null) {
    settings.theme = 'system';
    isar.writeTxnSync(() => isar.settings.putSync(settings));
  }

  if (settings.isImage == null) {
    settings.isImage = true;
    isar.writeTxnSync(() => isar.settings.putSync(settings));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static Future<void> updateAppState(
    BuildContext context, {
    bool? newAmoledTheme,
    bool? newMaterialColor,
    bool? newIsImage,
    String? newTimeformat,
    String? newFirstDay,
    Locale? newLocale,
  }) async {
    final state = context.findAncestorStateOfType<_MyAppState>()!;

    if (newAmoledTheme != null) {
      state.changeAmoledTheme(newAmoledTheme);
    }
    if (newMaterialColor != null) {
      state.changeMarerialTheme(newMaterialColor);
    }
    if (newTimeformat != null) {
      state.changeTimeFormat(newTimeformat);
    }
    if (newFirstDay != null) {
      state.changeFirstDay(newFirstDay);
    }
    if (newLocale != null) {
      state.changeLocale(newLocale);
    }
    if (newIsImage != null) {
      state.changeIsImage(newIsImage);
    }
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final themeController = Get.put(ThemeController());

  void changeAmoledTheme(bool newAmoledTheme) {
    setState(() {
      amoledTheme = newAmoledTheme;
    });
  }

  void changeMarerialTheme(bool newMaterialColor) {
    setState(() {
      materialColor = newMaterialColor;
    });
  }

  void changeIsImage(bool newIsImage) {
    setState(() {
      isImage = newIsImage;
    });
  }

  void changeTimeFormat(String newTimeformat) {
    setState(() {
      timeformat = newTimeformat;
    });
  }

  void changeFirstDay(String newFirstDay) {
    setState(() {
      firstDay = newFirstDay;
    });
  }

  void changeLocale(Locale newLocale) {
    setState(() {
      locale = newLocale;
    });
  }

  @override
  void initState() {
    amoledTheme = settings.amoledTheme;
    materialColor = settings.materialColor;
    timeformat = settings.timeformat;
    firstDay = settings.firstDay;
    isImage = settings.isImage!;
    locale = Locale(
      settings.language!.substring(0, 2),
      settings.language!.substring(3),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final edgeToEdgeAvailable = DeviceFeature().isEdgeToEdgeAvailable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) {
          final lightMaterialTheme = lightTheme(
            lightColorScheme?.surface,
            lightColorScheme,
            edgeToEdgeAvailable,
          );
          final darkMaterialTheme = darkTheme(
            darkColorScheme?.surface,
            darkColorScheme,
            edgeToEdgeAvailable,
          );
          final darkMaterialThemeOled = darkTheme(
            oledColor,
            darkColorScheme,
            edgeToEdgeAvailable,
          );

          return GetMaterialApp(
            theme:
                materialColor
                    ? lightColorScheme != null
                        ? lightMaterialTheme
                        : lightTheme(
                          lightColor,
                          colorSchemeLight,
                          edgeToEdgeAvailable,
                        )
                    : lightTheme(
                      lightColor,
                      colorSchemeLight,
                      edgeToEdgeAvailable,
                    ),
            darkTheme:
                amoledTheme
                    ? materialColor
                        ? darkColorScheme != null
                            ? darkMaterialThemeOled
                            : darkTheme(
                              oledColor,
                              colorSchemeDark,
                              edgeToEdgeAvailable,
                            )
                        : darkTheme(
                          oledColor,
                          colorSchemeDark,
                          edgeToEdgeAvailable,
                        )
                    : materialColor
                    ? darkColorScheme != null
                        ? darkMaterialTheme
                        : darkTheme(
                          darkColor,
                          colorSchemeDark,
                          edgeToEdgeAvailable,
                        )
                    : darkTheme(
                      darkColor,
                      colorSchemeDark,
                      edgeToEdgeAvailable,
                    ),
            themeMode: themeController.theme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // translations: Translation(),
            locale: locale,
            fallbackLocale: const Locale('en', 'US'),
            // supportedLocales:
            //     appLanguages.map((e) => e['locale'] as Locale).toList(),
            debugShowCheckedModeBanner: false,
            home: settings.onboard ? const HomePage() : const OnBording(),
            builder: EasyLoading.init(),
            title: 'zest',
          );
        },
      ),
    );
  }
}

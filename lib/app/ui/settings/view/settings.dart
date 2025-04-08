import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/controller/isar_contoller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/settings/widgets/settings_card.dart';
import 'package:zest/main.dart';
import 'package:zest/theme/theme_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final todoController = Get.put(TodoController());
  final isarController = Get.put(IsarController());
  final themeController = Get.put(ThemeController());

 

  void updateDefaultScreen(String defaultScreen) {
    settings.defaultScreen = defaultScreen;
    isar.writeTxnSync(() => isar.settings.putSync(settings));
    Get.back();
  }

  void urlLauncher(String uri) async {
    final Uri url = Uri.parse(uri);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'settings'.tr,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingCard(
              icon: const Icon(IconsaxPlusLinear.brush_1),
              text: 'appearance'.tr,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      child: StatefulBuilder(
                        builder: (BuildContext context, setState) {
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                  child: Text(
                                    'appearance'.tr,
                                    style: context.textTheme.titleLarge
                                        ?.copyWith(fontSize: 20),
                                  ),
                                ),
                                SettingCard(
                                  elevation: 4,
                                  icon: const Icon(IconsaxPlusLinear.moon),
                                  text: 'theme'.tr,
                                  dropdown: true,
                                  dropdownName: settings.theme?.tr,
                                  dropdownList: <String>[
                                    'system'.tr,
                                    'dark'.tr,
                                    'light'.tr,
                                  ],
                                  dropdownCange: (String? newValue) {
                                    ThemeMode themeMode =
                                        newValue?.tr == 'system'.tr
                                            ? ThemeMode.system
                                            : newValue?.tr == 'dark'.tr
                                            ? ThemeMode.dark
                                            : ThemeMode.light;
                                    String theme =
                                        newValue?.tr == 'system'.tr
                                            ? 'system'
                                            : newValue?.tr == 'dark'.tr
                                            ? 'dark'
                                            : 'light';
                                    themeController.saveTheme(theme);
                                    themeController.changeThemeMode(themeMode);
                                    setState(() {});
                                  },
                                ),
                                SettingCard(
                                  elevation: 4,
                                  icon: const Icon(IconsaxPlusLinear.mobile),
                                  text: 'amoledTheme'.tr,
                                  switcher: true,
                                  value: settings.amoledTheme,
                                  onChange: (value) {
                                    themeController.saveOledTheme(value);
                                    MyApp.updateAppState(
                                      context,
                                      newAmoledTheme: value,
                                    );
                                  },
                                ),
                                SettingCard(
                                  elevation: 4,
                                  icon: const Icon(
                                    IconsaxPlusLinear.colorfilter,
                                  ),
                                  text: 'materialColor'.tr,
                                  switcher: true,
                                  value: settings.materialColor,
                                  onChange: (value) {
                                    themeController.saveMaterialTheme(value);
                                    MyApp.updateAppState(
                                      context,
                                      newMaterialColor: value,
                                    );
                                  },
                                ),
                                SettingCard(
                                  elevation: 4,
                                  icon: const Icon(IconsaxPlusLinear.image),
                                  text: 'isImages'.tr,
                                  switcher: true,
                                  value: settings.isImage,
                                  onChange: (value) {
                                    isar.writeTxnSync(() {
                                      settings.isImage = value;
                                      isar.settings.putSync(settings);
                                    });
                                    MyApp.updateAppState(
                                      context,
                                      newIsImage: value,
                                    );
                                  },
                                ),
                                const Gap(10),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(IconsaxPlusLinear.code_1),
              text: 'functions'.tr,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      child: StatefulBuilder(
                        builder: (BuildContext context, setState) {
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                  child: Text(
                                    'functions'.tr,
                                    style: context.textTheme.titleLarge
                                        ?.copyWith(fontSize: 20),
                                  ),
                                ),
                                SettingCard(
                                  elevation: 4,
                                  icon: const Icon(IconsaxPlusLinear.clock_1),
                                  text: 'timeformat'.tr,
                                  dropdown: true,
                                  dropdownName: settings.timeformat.tr,
                                  dropdownList: <String>['12'.tr, '24'.tr],
                                  dropdownCange: (String? newValue) {
                                    isar.writeTxnSync(() {
                                      settings.timeformat =
                                          newValue == '12'.tr ? '12' : '24';
                                      isar.settings.putSync(settings);
                                    });
                                    MyApp.updateAppState(
                                      context,
                                      newTimeformat:
                                          newValue == '12'.tr ? '12' : '24',
                                    );
                                    setState(() {});
                                  },
                                ),
                               
                                const Gap(10),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(IconsaxPlusLinear.mobile),
              text: 'defaultScreen'.tr,
              info: true,
              infoSettings: true,
              textInfo:
                  settings.defaultScreen.isNotEmpty
                      ? settings.defaultScreen.tr
                      : allScreens[0].tr,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      child: StatefulBuilder(
                        builder: (BuildContext context, setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                child: Text(
                                  'defaultScreen'.tr,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: allScreens.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 5,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        allScreens[index].tr,
                                        style: context.textTheme.labelLarge,
                                        textAlign: TextAlign.center,
                                      ),
                                      onTap: () {
                                        this.setState(() {
                                          updateDefaultScreen(
                                            allScreens[index],
                                          );
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                              const Gap(10),
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
         
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:math';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/main.dart';

class IsarController {
  var now = DateTime.now();

  var platform = MethodChannel('directory_picker');

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationSupportDirectory();

      return isar = await Isar.open(
        [TasksSchema, TodosSchema, SettingsSchema],
        directory: dir.path,
        inspector: true,
      );
    }

    return Future.value(Isar.getInstance());
  }

  Future<String?> pickDirectory() async {
    if (Platform.isAndroid) {
      try {
        final String? uri = await platform.invokeMethod('pickDirectory');
        return uri;
      } on PlatformException {
        return null;
      }
    } else if (Platform.isIOS) {
      return await getDirectoryPath();
    }
    return null;
  }

  // Future<String?> getDownloadsDirectory() async {
  //   Directory? downloadsDir;

  //   if (Platform.isAndroid) {
  //     downloadsDir = Directory('/storage/emulated/0/Download');
  //   } else if (Platform.isIOS) {
  //     downloadsDir = await getApplicationDocumentsDirectory();
  //   }

  //   return downloadsDir?.path;
  // }

  // Future<void> createBackUp() async {
  //   final backUpDir = await pickDirectory();
  //   String? allowedPath =
  //       Platform.isAndroid ? await getDownloadsDirectory() : backUpDir;

  //   if (backUpDir == null || allowedPath == null) {
  //     EasyLoading.showInfo('errorPath'.tr);
  //     return;
  //   }

  //   try {
  //     final timeStamp = DateFormat('yyyyMMdd_HHmmss').format(now);
  //     final backupFileName = 'backup_zest_db$timeStamp.isar';
  //     final backUpFile = File('$allowedPath/$backupFileName');

  //     if (await backUpFile.exists()) {
  //       await backUpFile.delete();
  //     }

  //     await isar.copyToFile(backUpFile.path);

  //     if (Platform.isAndroid) {
  //       Uint8List backupData = await backUpFile.readAsBytes();

  //       final bool success = await platform.invokeMethod('writeFile', {
  //         "directoryUri": backUpDir,
  //         "fileName": backupFileName,
  //         "fileContent": backupData,
  //       });

  //       backUpFile.delete();

  //       if (success) {
  //         EasyLoading.showSuccess('successBackup'.tr);
  //       } else {
  //         EasyLoading.showError('error'.tr);
  //         return Future.error(e);
  //       }
  //     } else {
  //       EasyLoading.showSuccess('successBackup'.tr);
  //     }
  //   } catch (e) {
  //     EasyLoading.showError('error'.tr);
  //     return Future.error(e);
  //   }
  // }

  // Future<void> restoreDB() async {
  //   final dbDirectory = await getApplicationSupportDirectory();
  //   final XFile? backupFile = await openFile();

  //   if (backupFile == null) {
  //     EasyLoading.showInfo('errorPathRe'.tr);
  //     return;
  //   }

  //   try {
  //     await isar.close();
  //     final dbFile = File(backupFile.path);
  //     final dbPath = p.join(dbDirectory.path, 'default.isar');

  //     if (await dbFile.exists()) {
  //       await dbFile.copy(dbPath);
  //     }
  //     EasyLoading.showSuccess('successRestoreCategory'.tr);
  //     Future.delayed(
  //       const Duration(milliseconds: 500),
  //       () => Restart.restartApp(),
  //     );
  //   } catch (e) {
  //     EasyLoading.showError('error'.tr);
  //     return Future.error(e);
  //   }
  // }
}

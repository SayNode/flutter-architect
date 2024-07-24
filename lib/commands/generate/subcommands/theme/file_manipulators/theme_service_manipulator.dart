import 'dart:io';

import '../../../../../interfaces/service_manipulator.dart';
import '../../../../../util/util.dart';

class ThemeServiceManipulator extends ServiceManipulator {
  ThemeServiceManipulator(String themeName) {
    _themeName = themeName;
  }

  late String _themeName;

  @override
  String get name => 'ThemeService';

  @override
  String get path => 'lib/services/theme_service.dart';

  Future<void> update() async {
    final String content = '''
      case '$_themeName':
        return ThemeData(
          extensions: const <ThemeExtension<CustomTheme>>[
            CustomTheme.$_themeName,
          ],
        );
        ''';
    final List<String> lines = await File(path).readAsLines();
    final StringBuffer buffer = StringBuffer();
    for (final String line in lines) {
      buffer.writeln(line);

      if (line.contains('// List of themes')) {
        buffer.write(content);
      }
    }

    await File(path).writeAsString(buffer.toString());
    printColor(
      'Theme Service file updated (lib/theme/theme_service.dart) ✔',
      ColorText.green,
    );
  }

  @override
  String content() => """
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/theme.dart';
import 'storage/storage_exception.dart';
import 'storage/storage_service.dart';

class ThemeService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();
  ThemeData get themeData => _getThemeData();

  CustomTheme get theme => Get.theme.extension<CustomTheme>()!;

  ThemeData _getThemeData() {
    final String theme = _getSavedTheme();

    switch (theme) {
      //List of themes

      case '$_themeName':
        return ThemeData(
          extensions: const <ThemeExtension<CustomTheme>>[
            CustomTheme.$_themeName,
          ],
        );

      default:
        return ThemeData(
          extensions: const <ThemeExtension<CustomTheme>>[
            CustomTheme.$_themeName,
          ],
        );
    }
  }

  String _getSavedTheme() {
    String value;
    try {
      value = _storage.shared.readString('themeMode');
    } on StorageException catch (_) {
      setTheme('$_themeName');
      value = '$_themeName';
    }

    return value;
  }

  Future<void> setTheme(String theme) async {
    await _storage.shared.writeString('themeMode', theme);
    Get.changeTheme(_getThemeData());
  }
}""";
}

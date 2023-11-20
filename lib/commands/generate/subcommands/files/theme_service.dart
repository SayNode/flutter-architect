String content(String name) {
  return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/theme.dart';
import 'storage_service.dart';

class ThemeService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();
  ThemeData get themeData => _getThemeData();

  CustomTheme get theme => Get.theme.extension<CustomTheme>()!;

  ThemeData _getThemeData() {
    final String theme = _getSavedTheme();

    switch (theme) {
      //List of themes

      case '$name':
        return ThemeData(
          extensions: const <ThemeExtension<CustomTheme>>[
            CustomTheme.$name,
          ],
        );

      default:
        return ThemeData(
          extensions: const <ThemeExtension<CustomTheme>>[
            CustomTheme.$name,
          ],
        );
    }
  }

  String _getSavedTheme() {
    String value;
    try {
      value = _storage.getString('themeMode');
    } on StorageException catch (_) {
      setTheme('$name');
      value = '$name';
    }

    return value;
  }

  Future<void> setTheme(String theme) async {
    await _storage.setString('themeMode', theme);
    Get.changeTheme(_getThemeData());
  }
}

''';
}

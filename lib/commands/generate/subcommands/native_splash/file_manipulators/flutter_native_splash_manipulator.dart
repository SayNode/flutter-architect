import 'dart:io';

import '../../../../../interfaces/file_manipulator.dart';
import '../../../../../util/util.dart';

class FlutterNativeSplashManipulator extends FileManipulator {
  @override
  String get name => 'FlutterNativeSplash';

  @override
  String get path => 'flutter_native_splash.yaml';

  @override
  String content() => '';

  String contentParameters(String color, String iconFile) => '''
flutter_native_splash:
  color: "$color"
  image: $iconFile
  android: ${Directory('android').existsSync()}
  ios: ${Directory('ios').existsSync()}
  web: ${Directory('web').existsSync()}''';

  Future<void> createParameters(String color, String iconFile) async {
    await writeFile(
      path,
      contentParameters(color, iconFile),
    );
    printColor(
      '$path - successfully created ✔',
      ColorText.green,
    );
  }
}

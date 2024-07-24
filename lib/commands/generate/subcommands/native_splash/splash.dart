import 'dart:io';

import 'package:args/command_runner.dart';

import '../../../../util/util.dart';
import '../../../new/file_manipulators/main_file_manipulator.dart';
import 'file_manipulators/flutter_native_splash_manipulator.dart';

class GenerateSplashService extends Command<dynamic> {
  GenerateSplashService() {
    // Add parser options or flag here
    argParser
      ..addFlag(
        'force',
        help: 'Force replace in case it already exists.',
      )
      ..addFlag(
        'remove',
        help: 'Remove in case it already exists.',
      );
  }
  @override
  String get description => 'Create splash files and boilerplate code;';

  @override
  String get name => 'splash';

  @override
  Future<void> run() async {
    await _run();
  }

  final String defaultIconPath = 'asset/image/splash.png';
  final String defaultColorHex = '#FFFFFF';

  Future<void> _run() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('splash');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        printColor('------- Creating Native Splash -------\n', ColorText.cyan);
        await addAlreadyRun('splash');
        addDependenciesToPubspecSync(<String>['flutter_native_splash'], null);
        final String iconFile = getIconFile();
        final String color = getColor();
        await FlutterNativeSplashManipulator()
            .createParameters(color, iconFile);
        runNativeSplash(null);
        await MainFileManipulator().addSplashScreen();
      },
      remove: () async {
        printColor('------- Removing Native Splash -------\n', ColorText.cyan);
        await removeAlreadyRun('splash');
        removeDependenciesFromPubspecSync(
          <String>['flutter_native_splash'],
          null,
        );
        await FlutterNativeSplashManipulator().remove();
        await MainFileManipulator().removeSplashScreen();
      },
      rejectAdd: () async {
        printColor(
          "Can't add Native Splash as it's already configured.",
          ColorText.red,
        );
      },
      rejectRemove: () async {
        printColor(
          "Can't remove Native Splash as it's not yet configured.",
          ColorText.red,
        );
      },
    );
  }

  /// Request the user for the image path.
  String getIconFile() {
    stdout.writeln(
      'Enter the path to your splash image (> $defaultIconPath):',
    );
    final String ret = stdin.readLineSync() ?? '';
    if (ret.isEmpty) {
      return defaultIconPath;
    }
    return ret;
  }

  /// Request the user for the background color.
  String getColor() {
    stdout.writeln(
      'Enter the background color hexadecimal (> $defaultColorHex):',
    );
    final RegExp hex = RegExp('^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})');
    for (int i = 0; i < 10; i++) {
      final String value = stdin.readLineSync() ?? '';
      if (hex.hasMatch(value)) {
        return value;
      } else {
        if (value.isEmpty) {
          return defaultColorHex;
        }
        printColor(
          'Invalid hexadecimal value. Try the #xxxxxx format.',
          ColorText.red,
        );
      }
    }
    exit(1);
  }
}

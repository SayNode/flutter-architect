import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../util.dart';
import 'code/flutter_native_splash.dart' as flutter_native_splash;

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
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('splash');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Native Splash...');
        await addAlreadyRun('splash');
        addDependenciesToPubspecSync(<String>['flutter_native_splash'], null);
        final String iconFile = getIconFile();
        final String color = getColor();
        await _writeSplashFile(iconFile, color);
        runNativeSplash(null);
        await _addMainChanges();
      },
      remove: () async {
        print('Removing Native Splash...');
        await removeAlreadyRun('splash');
        removeDependenciesFromPubspecSync(
          <String>['flutter_native_splash'],
          null,
        );
        await _removeSplashFile();
        await _removeMainChanges();
      },
      rejectAdd: () async {
        print("Can't add Native Splash as it's already configured.");
      },
      rejectRemove: () async {
        print("Can't remove Native Splash as it's not yet configured.");
      },
    );
    formatCode();
    dartFixCode();
  }

  Future<void> _removeSplashFile() async {
    await File(path.join('flutter_native_splash.yaml')).delete();
  }

  Future<void> _writeSplashFile(String iconFile, String color) async {
    await File(path.join('flutter_native_splash.yaml'))
        .writeAsString(flutter_native_splash.content(color, iconFile));
  }

  // Request the user for the image path.
  String getIconFile() {
    stdout.writeln(
      'Enter the path to your splash image (ex. asset/image/splash.png):',
    );
    return stdin.readLineSync() ?? '';
  }

  // Request the user for the background color.
  String getColor() {
    stdout.writeln('Enter the background color hexadecimal (ex. #EAF2FF):');
    final RegExp hex = RegExp('^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})');
    for (int i = 0; i < 10; i++) {
      final String value = stdin.readLineSync() ?? '';
      if (hex.hasMatch(value)) {
        return value;
      } else {
        print('Invalid hexadecimal value. Try the #xxxxxx format.');
      }
    }
    exit(1);
  }

  // Remove the Storage-related lines from main.
  Future<void> _removeMainChanges() async {
    final String mainPath = path.join('lib', 'main.dart');
    await removeLinesFromFile(mainPath, <String>[
      'await Future.delayed(const Duration(seconds: 2));',
      'FlutterNativeSplash.remove();',
      'FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);',
      "import 'package:flutter_native_splash/flutter_native_splash.dart';",
    ]);
  }

  Future<void> _addMainChanges() async {
    final String mainPath = path.join('lib', 'main.dart');

    await addLinesBeforeLineInFile(
      mainPath,
      <String, List<String>>{
        'runApp(const MyApp());': <String>[
          'await Future.delayed(const Duration(seconds: 2));',
          'FlutterNativeSplash.remove();',
        ],
      },
    );

    await addLinesAfterLineInFile(
      mainPath,
      <String, List<String>>{
        'WidgetsFlutterBinding.ensureInitialized();': <String>[
          'FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);',
        ],
        '// https://saynode.ch': <String>[
          "import 'package:flutter_native_splash/flutter_native_splash.dart';",
        ],
      },
    );
  }
}

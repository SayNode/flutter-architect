import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/generate/subcommands/native_splash/code/flutter_native_splash.dart'
    as flutter_native_splash;
import 'package:project_initialization_tool/commands/util.dart';

class GenerateSplashService extends Command {
  @override
  String get description => 'Create splash files and boilerplate code;';

  @override
  String get name => 'splash';

  GenerateSplashService() {
    // Add parser options or flag here
    argParser.addFlag('force',
        defaultsTo: false, help: 'Force replace in case it already exists.');
    argParser.addFlag('remove',
        defaultsTo: false, help: 'Remove in case it already exists.');
  }

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    bool alreadyBuilt = await checkIfAlreadyRunWithReturn("splash");
    bool force = argResults?['force'] ?? false;
    bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Native Splash...');
        await addAlreadyRun('splash');
        addDependenciesToPubspecSync(['flutter_native_splash'], null);
        String iconFile = getIconFile();
        String color = getColor();
        await _writeSplashFile(iconFile, color);
        runNativeSplash(null);
        await _addMainChanges();
      },
      remove: () async {
        print('Removing Native Splash...');
        await removeAlreadyRun('splash');
        removeDependenciesFromPubspecSync(['flutter_native_splash'], null);
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
        'Enter the path to your splash image (ex. asset/image/splash.png):');
    return stdin.readLineSync() ?? '';
  }

  // Request the user for the background color.
  String getColor() {
    stdout.writeln('Enter the background color hexadecimal (ex. #EAF2FF):');
    RegExp hex = RegExp('^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})');
    for (int i = 0; i < 10; i++) {
      String value = stdin.readLineSync() ?? '';
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
    String mainPath = path.join('lib', 'main.dart');
    await removeLinesFromFile(mainPath, [
      "await Future.delayed(const Duration(seconds: 2));",
      "FlutterNativeSplash.remove();",
      "FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);",
      "import 'package:flutter_native_splash/flutter_native_splash.dart';",
    ]);
  }

  Future<void> _addMainChanges() async {
    String mainPath = path.join('lib', 'main.dart');

    await addLinesBeforeLineInFile(
      mainPath,
      {
        'runApp(const MyApp());': [
          'await Future.delayed(const Duration(seconds: 2));',
          'FlutterNativeSplash.remove();',
        ],
      },
    );

    await addLinesAfterLineInFile(
      mainPath,
      {
        'WidgetsFlutterBinding.ensureInitialized();': [
          "FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);",
        ],
        '// https://saynode.ch': [
          "import 'package:flutter_native_splash/flutter_native_splash.dart';",
        ],
      },
    );
  }
}

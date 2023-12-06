import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/util.dart';

class GenerateSplashService extends Command {
  @override
  String get description => 'Create splash files and boilerplate code;.';

  @override
  String get name => 'splash';

  GenerateSplashService() {
    // Add parser options or flag here
    argParser.addFlag('force',
        defaultsTo: false, help: 'Force replace in case it already exists.');
  }

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    bool value = await checkIfAlreadyRunWithReturn('splash');
    bool force = argResults?['force'] ?? false;
    if (value && force) {
      print('Replacing splash...');
      addDependencyToPubspecSync('flutter_native_splash', null);
      await _removeSplashFile();
      await _removeMainLines();
      String iconFile = getIconFile();
      String color = getColor();
      await _writeSplashFile(iconFile, color);
      runNativeSplash(null);
      await _modifyMain();
    } else if (!value) {
      print('Creating splash...');
      await addAlreadyRun('splash');
      addDependencyToPubspecSync('flutter_native_splash', null);
      String iconFile = getIconFile();
      String color = getColor();
      await _writeSplashFile(iconFile, color);
      runNativeSplash(null);
      await _modifyMain();
    } else {
      print('splash already exists.');
      exit(0);
    }
    await formatCode();
    await dartFixCode();
  }

  Future<void> _removeSplashFile() async {
    await File(path.join('flutter_native_splash.yaml')).delete();
  }

  Future<void> _writeSplashFile(String iconFile, String color) async {
    String content = """
flutter_native_splash:
  color: "$color"
  image: $iconFile
  android: true
  ios: true
    """;
    await File(path.join('flutter_native_splash.yaml')).writeAsString(content);
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
  Future<void> _removeMainLines() async {
    String mainPath = path.join('lib', 'main.dart');
    List<String> lines = await File(mainPath).readAsLines();
    String mainContent = '';

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      if (!line.contains("await Future.delayed(const Duration(seconds: 2));") &&
          !line.contains("FlutterNativeSplash.remove();") &&
          !line.contains(
              "FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);") &&
          !line.contains(
              "import 'package:flutter_native_splash/flutter_native_splash.dart';")) {
        mainContent += '$line\n';
      }
    }
    await File(mainPath).writeAsString(mainContent).then((file) {
      print('- Remove Splash from main ✔');
    });
  }

  Future<void> _modifyMain() async {
    String mainPath = path.join('lib', 'main.dart');
    List<String> lines = await File(mainPath).readAsLines();
    String mainContent = '';
    mainContent +=
        "import 'package:flutter_native_splash/flutter_native_splash.dart';";
    for (String line in lines) {
      if (line.contains('runApp(const MyApp());')) {
        mainContent += 'await Future.delayed(const Duration(seconds: 2));\n';
        mainContent += 'FlutterNativeSplash.remove();\n';
      }
      mainContent += '$line\n';
      if (line.contains('WidgetsFlutterBinding.ensureInitialized();')) {
        mainContent +=
            "FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);\n";
      }
    }
    await File(mainPath).writeAsString(mainContent).then((file) {
      print('- Add Splash to main  ✔');
    });
  }
}

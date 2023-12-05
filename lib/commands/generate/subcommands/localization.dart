import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/generate/subcommands/files/language_model.dart'
    as language_model;
import 'package:project_initialization_tool/commands/generate/subcommands/files/localization_controller.dart'
    as localization_controller;
import 'package:project_initialization_tool/commands/generate/subcommands/files/message.dart'
    as message;
import 'package:project_initialization_tool/commands/util.dart';

class LocalizationGenerator extends Command {
  @override
  String get description => 'Create localization files and boilerplate code;.';

  @override
  String get name => 'localization';

  LocalizationGenerator() {
    // Add parser options or flag here
    argParser.addFlag('force',
        defaultsTo: false, help: 'Force replace in case it already exists.');
  }

  @override
  void run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    bool value = await checkIfAlreadyRunWithReturn('localization');
    bool force = argResults?['force'] ?? false;
    if (value && force) {
      print('Replacing localization...');
      await _removeMainLines();
      await _removeLanguageModel();
      await _removeMessageFile();
      await _removeLocalizationController();
      await _removeLanguageJson();
      await _rewriteMain();
      await _addLanguageModel();
      await _addMessageFile();
      await _addLocalizationController();
      await _addLanguageJson();
    } else if (!value) {
      print('Creating localization...');
      await addAlreadyRun("localization");
      await _rewriteMain();
      await _addLanguageModel();
      await _addMessageFile();
      await _addLocalizationController();
      await _addLanguageJson();
    } else {
      print('Localization already exists.');
      exit(0);
    }
    await formatCode();
    await dartFixCode();
  }

  Future<void> _removeLanguageModel() async {
    await File(path.join('lib', 'model', 'language_model.dart')).delete();
  }

  Future<void> _removeLanguageJson() async {
    await Directory(path.join('asset', 'locale')).delete(recursive: true);
  }

  Future<void> _removeMessageFile() async {
    await File(path.join('lib', 'model', 'message.dart')).delete();
  }

  Future<void> _removeLocalizationController() async {
    await File(path.join('lib', 'service', 'localization_controller.dart'))
        .delete();
  }

  // Remove the Storage-related lines from main.
  Future<void> _removeMainLines() async {
    String mainPath = path.join('lib', 'main.dart');
    List<String> lines = await File(mainPath).readAsLines();
    String mainContent = '';

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      if (!line.contains("import 'service/localization_controller.dart';") &&
          !line.contains("import 'model/message.dart';") &&
          !line.contains("return GetBuilder<LocalizationController>(") &&
          !line.contains(
              "builder: (LocalizationController localizationController) {") &&
          !line.contains("locale: localizationController.locale,") &&
          !line.contains("translations:") &&
          !line.contains(
              "Messages(languages: localizationController.translations),") &&
          !line.contains(
              "final LocalizationController localizationController =") &&
          !line.contains("Get.put(LocalizationController());") &&
          !line.contains("await localizationController.init();")) {
        mainContent += '$line\n';
        if (line.contains('//End MaterialApp')) {
          i += 2;
        }
      }
    }
    await File(mainPath).writeAsString(mainContent).then((file) {
      print('- Remove Localization from main ✔');
    });
  }

  Future<void> _addLanguageModel() async {
    File(path.join('lib', 'model', 'language_model.dart'))
        .writeAsString(language_model.content());
  }

  Future<void> _addLanguageJson() async {
    Directory(path.join('asset', 'locale')).createSync();
    File(path.join('asset', 'locale', 'en.json')).writeAsString('{}');
  }

  Future<void> _addMessageFile() async {
    File(path.join('lib', 'model', 'message.dart'))
        .writeAsString(message.content());
  }

  Future<void> _addLocalizationController() async {
    File(path.join('lib', 'service', 'localization_controller.dart'))
        .writeAsString(localization_controller.content());
  }

  Future<void> _rewriteMain() async {
    String mainPath = path.join('lib', 'main.dart');
    List<String> lines = await File(mainPath).readAsLines();
    String mainContent = '';

    mainContent += "import 'service/localization_controller.dart';\n";
    mainContent += "import 'model/message.dart';\n";
    for (String line in lines) {
      if (line.contains('//Start MaterialApp')) {
        mainContent +=
            "return GetBuilder<LocalizationController>(\nbuilder: (localizationController) {\n";
      }
      mainContent += '$line\n';
      if (line.contains('//End MaterialApp')) {
        mainContent += '},);\n';
      }

      if (line.contains('GetMaterialApp(')) {
        mainContent += 'locale: localizationController.locale,\n';
        mainContent +=
            'translations:\nMessages(languages: localizationController.translations),\n';
      }
      if (line.contains('main(')) {
        mainContent +=
            'final LocalizationController localizationController = Get.put(LocalizationController());\nawait localizationController.init();\n';
      }
    }

    File(mainPath).writeAsString(mainContent).then((file) {
      print('- Localization added to main ✔');
    });
  }
}

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/generate/subcommands/localization/code/language_model.dart'
    as language_model;
import 'package:project_initialization_tool/commands/generate/subcommands/localization/code/localization_controller.dart'
    as localization_controller;
import 'package:project_initialization_tool/commands/generate/subcommands/localization/code/message.dart'
    as message;
import 'package:project_initialization_tool/commands/util.dart';

class GenerateLocalizationService extends Command {
  @override
  String get description => 'Create localization files and boilerplate code;';

  @override
  String get name => 'localization';

  GenerateLocalizationService() {
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
    bool alreadyBuilt = await checkIfAlreadyRunWithReturn("localization");
    bool force = argResults?['force'] ?? false;
    bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Localization...');
        await addAlreadyRun("localization");
        await _addLanguageModel();
        await _addMessageFile();
        await _addLocalizationController();
        await _addLanguageJson();
        await _addMainChanges();
      },
      remove: () async {
        print('Removing Localization...');
        await removeAlreadyRun("localization");
        await _removeMainChanges();
        await _removeLanguageModel();
        await _removeMessageFile();
        await _removeLocalizationController();
        await _removeLanguageJson();
      },
      rejectAdd: () async {
        print("Can't add Localization as it's already configured.");
      },
      rejectRemove: () async {
        print("Can't remove Localization as it's not yet configured.");
      },
    );
    formatCode();
    dartFixCode();
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
  Future<void> _removeMainChanges() async {
    String mainPath = path.join('lib', 'main.dart');

    await deleteLinesFromFile(
      mainPath,
      [
        "import 'service/localization_controller.dart';",
        "import 'model/message.dart';",
        "return GetBuilder<LocalizationController>(",
        "builder: (LocalizationController localizationController) {",
        "locale: localizationController.locale,",
        "translations:",
        "Messages(languages: localizationController.translations),",
        "final LocalizationController localizationController =",
        "Get.put(LocalizationController());",
        "await localizationController.init();",
      ],
    );

    await deleteLinesAfterFromFile(
      mainPath,
      '//End MaterialApp',
      2,
    );
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

  Future<void> _addMainChanges() async {
    String mainPath = path.join('lib', 'main.dart');

    await addLinesAfterLineInFile(
      mainPath,
      {
        '//End MaterialApp': [
          '},);',
        ],
        'return GetMaterialApp(': [
          'locale: localizationController.locale,',
          'translations:',
          'Messages(languages: localizationController.translations),',
        ],
      },
    );

    await addLinesBeforeLineInFile(
      mainPath,
      {
        '//Start MaterialApp': [
          "return GetBuilder<LocalizationController>(",
          "builder: (LocalizationController localizationController) {",
        ],
        'runApp(const MyApp());': [
          'final LocalizationController localizationController = Get.put(LocalizationController());',
          'await localizationController.init();',
        ],
      },
      leading: [
        "import 'service/localization_controller.dart';",
        "import 'model/message.dart';",
      ],
    );
  }
}

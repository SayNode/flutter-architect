import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../util.dart';
import 'code/language_model.dart' as language_model;
import 'code/localization_controller.dart' as localization_controller;
import 'code/message.dart' as message;

class GenerateLocalizationService extends Command<dynamic> {
  GenerateLocalizationService() {
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
  String get description => 'Create localization files and boilerplate code;';

  @override
  String get name => 'localization';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('localization');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        stderr.writeln('Creating Localization...');
        await addAlreadyRun('localization');
        await _addLanguageModel();
        await _addMessageFile();
        await _addLocalizationController();
        await _addLanguageJson();
        await _addAssetToPubspec();
        await _addMainChanges();
      },
      remove: () async {
        stderr.writeln('Removing Localization...');
        await removeAlreadyRun('localization');
        await _removeMainChanges();
        await _removeLanguageModel();
        await _removeMessageFile();
        await _removeLocalizationController();
        await _removeLanguageJson();
        await _removeAssetFromPubspec();
      },
      rejectAdd: () async {
        stderr.writeln("Can't add Localization as it's already configured.");
      },
      rejectRemove: () async {
        stderr.writeln("Can't remove Localization as it's not yet configured.");
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

  Future<void> _removeAssetFromPubspec() async {
    final String pubspecPath = path.join('pubspec.yaml');
    await removeLinesFromFile(
      pubspecPath,
      <String>[
        '    - asset/locale/',
      ],
    );
  }

  // Remove the Storage-related lines from main.
  Future<void> _removeMainChanges() async {
    final String mainPath = path.join('lib', 'main.dart');

    await removeLinesFromFile(
      mainPath,
      <String>[
        "import 'service/localization_controller.dart';",
        "import 'model/message.dart';",
        'return GetBuilder<LocalizationController>(',
        'builder: (LocalizationController localizationController) {',
        'locale: localizationController.locale,',
        'translations:',
        'Messages(languages: localizationController.translations),',
        'final LocalizationController localizationController =',
        'Get.put(LocalizationController());',
        'await localizationController.init();',
      ],
    );

    await removeLinesAfterFromFile(
      mainPath,
      '//End MaterialApp',
      2,
    );
  }

  Future<void> _addLanguageModel() async {
    await writeFileWithPrefix(
      path.join('lib', 'model', 'language_model.dart'),
      language_model.content(),
    );
  }

  Future<void> _addLanguageJson() async {
    Directory(path.join('asset', 'locale')).createSync();
    await File(path.join('asset', 'locale', 'en.json')).writeAsString('{}');
  }

  Future<void> _addMessageFile() async {
    await writeFileWithPrefix(
      path.join('lib', 'model', 'message.dart'),
      message.content(),
    );
  }

  Future<void> _addLocalizationController() async {
    await writeFileWithPrefix(
      path.join('lib', 'service', 'localization_controller.dart'),
      localization_controller.content(),
    );
  }

  Future<void> _addAssetToPubspec() async {
    final String pubspecPath = path.join('pubspec.yaml');
    await addLinesAfterLineInFile(
      pubspecPath,
      <String, List<String>>{
        '- asset/': <String>[
          '    - asset/locale/',
        ],
      },
    );
  }

  Future<void> _addMainChanges() async {
    final String mainPath = path.join('lib', 'main.dart');

    await addLinesAfterLineInFile(
      mainPath,
      <String, List<String>>{
        '//End MaterialApp': <String>[
          '},);',
        ],
        'return GetMaterialApp(': <String>[
          'locale: localizationController.locale,',
          'translations:',
          'Messages(languages: localizationController.translations),',
        ],
        '// https://saynode.ch': <String>[
          "import 'service/localization_controller.dart';",
          "import 'model/message.dart';",
        ],
      },
    );

    await addLinesBeforeLineInFile(
      mainPath,
      <String, List<String>>{
        '//Start MaterialApp': <String>[
          'return GetBuilder<LocalizationController>(',
          'builder: (LocalizationController localizationController) {',
        ],
        'runApp(const MyApp());': <String>[
          'final LocalizationController localizationController = Get.put(LocalizationController());',
          'await localizationController.init();',
        ],
      },
    );
  }
}

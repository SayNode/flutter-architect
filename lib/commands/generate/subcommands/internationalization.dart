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

class InternationalizationGenerator extends Command {
  @override
  String get description =>
      'Create internationalization files and boilerplate code;.';

  @override
  String get name => 'internationalization';

  @override
  void run() async {
    checkIfAllreadyRun().then((value) async {
      await addInternationalization();
    });
  }

  Future<void> checkIfAllreadyRun() async {
    await File('added_boilerplate.txt')
        .readAsLines()
        .then((List<String> lines) {
      for (var line in lines) {
        if (line.contains('internationalization')) {
          print('internationalization already added');
          exit(0);
        }
      }
    });
  }

  Future<void> addAllreadyRun() async {
    await File('added_boilerplate.txt')
        .writeAsString('internationalization\n', mode: FileMode.append);
  }

  addInternationalization() async {
    await addAllreadyRun();
    await _rewriteMain();
    await _addLanguageModel();
    await _addMessageFile();
    await _addLocalizationController();
    await _addLanguageJson();
    await formatCode();
  }

  Future<void> _addLanguageModel() async {
    File(path.join('lib', 'model', 'language_model.dart'))
        .writeAsString(language_model.content());
  }

  Future<void> _addLanguageJson() async {
    Directory(path.join('asset', 'locale')).createSync();
    File(path.join('asset', 'locale', 'en.json')).writeAsString('[]');
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
    File(mainPath).readAsLines().then((List<String> lines) {
      String mainContent = '';

      mainContent += "import 'service/localization_controller.dart';\n";
      mainContent += "import 'model/message.dart';\n";
      for (String line in lines) {
        if (line.contains('//Start MaterialApp')) {
          mainContent +=
              "return GetBuilder<LocalizationController>(builder: (localizationController) {\n";
        }
        mainContent += '$line\n';
        if (line.contains('//End MaterialApp')) {
          mainContent += '});\n';
        }

        if (line.contains('GetMaterialApp(')) {
          mainContent += 'locale: localizationController.locale,\n';
          mainContent +=
              'translations: Messages(languages: localizationController.translations),\n';
        }
        if (line.contains('main(')) {
          mainContent +=
              'final LocalizationController localizationController = Get.put(LocalizationController());\nawait localizationController.init();\n';
        }
      }

      File(mainPath).writeAsString(mainContent).then((file) {
        print(
            '- internationalization added to main added to mainContent.yaml ✔');
      });
    });
  }
}

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/generate/subcommands/files/language_model.dart'
    as language_model;
import 'package:project_initialization_tool/commands/generate/subcommands/files/localization_controller.dart'
    as localization_controller;
import 'package:project_initialization_tool/commands/util.dart';

class InternationalizationGenerator extends Command {
  @override
  String get description =>
      'Create internationalization files and boilerplate code;.';

  @override
  String get name => 'internationalization';

  @override
  void run() async {
    await addInternationalization();
  }

  addInternationalization() async {
    await _rewriteMain();
    await _addLanguageModel();
    await _addLocalizationController();
    await formatCode();
  }

  Future<void> _addLanguageModel() async {
    File(path.join('lib', 'model', 'language_model.dart'))
        .writeAsString(language_model.content());
  }

  Future<void> _addLocalizationController() async {
    File(path.join('lib', 'service', 'localization_controler.dart'))
        .writeAsString(localization_controller.content());
  }

  Future<void> _rewriteMain() async {
    String mainPath = path.join('lib', 'main.dart');
    File(mainPath).readAsLines().then((List<String> lines) {
      String mainContent = '';

      mainContent += "import 'service/localization_controller.dart';\n";
      for (String line in lines) {
        if (line.contains('//Start MaterialApp')) {
          mainContent +=
              "return GetBuilder<LocalizationController>(builder: (localizationController) {\n";
        }
        mainContent += '$line\n';
        if (line.contains('//End MaterialApp')) {
          mainContent += '});\n';
        }
        // if (line.contains('main(')) {
        //   mainContent +=
        //       'Map<String, Map<String, String>> languages = await dependency.init();\n';
        // }
      }

      File(mainPath).writeAsString(mainContent).then((file) {
        print(
            '- internationalization added to main added to mainContent.yaml ✔');
      });
    });
  }
}

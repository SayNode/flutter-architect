import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/generate/subcommands/files/language_model.dart'
    as language_model;
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
    //await _rewriteMain();
    await _addLanguageModel();
    await formatCode();
  }

  Future<void> _addLanguageModel() async {
    File(path.join('lib', 'model', 'language_model.dart'))
        .writeAsString(language_model.content());
  }

  Future<void> _rewriteMain() async {
    String mainPath = path.join('lib', 'main.dart');
    File(mainPath).readAsLines().then((List<String> lines) {
      String mainContent = '';

      for (String line in lines) {
        mainContent += '$line\n';

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

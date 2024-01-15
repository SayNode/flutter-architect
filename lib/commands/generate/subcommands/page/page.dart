import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/generate/subcommands/page/code/controller.dart'
    as controller;
import 'package:project_initialization_tool/commands/generate/subcommands/page/code/page.dart'
    as page;
import 'package:project_initialization_tool/commands/util.dart';

class GeneratePageService extends Command {
  @override
  String get description => 'Create new Page and boilerplate code;';

  @override
  String get name => 'page';

  GeneratePageService() {
    // Add parser options or flag here
    argParser.addFlag('force',
        defaultsTo: false, help: 'Force replace in case it already exists.');
    argParser.addFlag('remove',
        defaultsTo: false, help: 'Remove in case it already exists.');
    argParser.addOption(
      'name',
      abbr: 'n',
      help:
          '--name is mandatory (name of the page/controller to create). Use Pascal Case for naming convention (ex. ForgotPassword).',
      mandatory: true,
    );
  }

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    String pascalCase = argResults?['name'];
    String snakeCase = pascalCaseToSnakeCase(pascalCase);
    bool alreadyBuilt = Directory(
      path.join('lib', 'page', snakeCase),
    ).existsSync();
    bool force = argResults?['force'] ?? false;
    bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating lib/$snakeCase...');
        Directory(
          path.join('lib', 'page', snakeCase),
        ).createSync();
        Directory(
          path.join('lib', 'page', snakeCase, 'controller'),
        ).createSync();
        Directory(
          path.join('lib', 'page', snakeCase, 'widget'),
        ).createSync();
        _createController(pascalCase, snakeCase);
        _createPage(pascalCase, snakeCase);
        await _handleTheme(pascalCase, snakeCase);
      },
      remove: () async {
        print('Removing API Service...');
        Directory(
          path.join('lib', 'page', snakeCase),
        ).deleteSync(recursive: true);
      },
      rejectAdd: () async {
        print("Can't add page $pascalCase as it's already added.");
      },
      rejectRemove: () async {
        print("Can't remove page $pascalCase as it's not yet added.");
      },
    );
    formatCode();
    dartFixCode();
  }

  String pascalCaseToSnakeCase(String input) {
    final exp = RegExp('(?<=[a-z])[A-Z]');
    return input
        .replaceAllMapped(
          exp,
          (m) => '_${m.group(0)}',
        )
        .toLowerCase();
  }

  Future<void> _createController(String pascalCase, String snakeCase) async {
    await writeFileWithPrefix(
        path.join(
          'lib',
          'page',
          snakeCase,
          'controller',
          '${snakeCase}_controller.dart',
        ),
        controller.content(pascalCase, snakeCase));
  }

  Future<void> _createPage(String pascalCase, String snakeCase) async {
    await writeFileWithPrefix(
        path.join(
          'lib',
          'page',
          snakeCase,
          '${snakeCase}_page.dart',
        ),
        page.content(pascalCase, snakeCase));
  }

  Future<void> _handleTheme(pascalCase, snakeCase) async {
    if (File(path.join(
          'lib',
          'service',
          'theme_service.dart',
        )).existsSync() &&
        File(path.join(
          'lib',
          'theme',
          'theme.dart',
        )).existsSync()) {
      String file = path.join(
        'lib',
        'page',
        snakeCase,
        '${snakeCase}_page.dart',
      );
      await addLinesBeforeLineInFile(file, {
        'return Container();': [
          'final CustomTheme theme = ThemeService().theme;'
        ],
      });
      await addLinesAfterLineInFile(
        file,
        {
          '// https://saynode.ch': [
            "import '../../service/theme_service.dart';",
            "import '../../theme/theme.dart';",
          ],
        },
      );
    }
  }
}

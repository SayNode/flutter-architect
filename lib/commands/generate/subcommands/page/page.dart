import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../../util/util.dart';
import '../../../new/file_manipulators/dependency_injection.dart';
import 'code/controller.dart' as controller;
import 'code/page.dart' as page;

class GeneratePageService extends Command<dynamic> {
  GeneratePageService() {
    // Add parser options or flag here
    argParser
      ..addFlag(
        'force',
        help: 'Force replace in case it already exists.',
      )
      ..addFlag(
        'remove',
        help: 'Remove in case it already exists.',
      )
      ..addOption(
        'name',
        abbr: 'n',
        help:
            '--name is mandatory (name of the page/controller to create). Use Pascal Case for naming convention (ex. ForgotPassword).',
        mandatory: true,
      );
  }
  @override
  String get description => 'Create new Page and boilerplate code;';

  @override
  String get name => 'page';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    final String pascalCase = argResults?['name'];
    final String snakeCase = pascalCaseToSnakeCase(pascalCase);
    final bool alreadyBuilt = Directory(
      path.join('lib', 'page', snakeCase),
    ).existsSync();
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        stderr.writeln('Creating lib/$snakeCase...');
        Directory(
          path.join('lib', 'page', snakeCase),
        ).createSync();
        Directory(
          path.join('lib', 'page', snakeCase, 'controller'),
        ).createSync();
        Directory(
          path.join('lib', 'page', snakeCase, 'widget'),
        ).createSync();
        await _createController(pascalCase, snakeCase);
        await _createPage(pascalCase, snakeCase);
        await _handleTheme(pascalCase, snakeCase);
      },
      remove: () async {
        stderr.writeln('Removing API Service...');
        Directory(
          path.join('lib', 'page', snakeCase),
        ).deleteSync(recursive: true);
      },
      rejectAdd: () async {
        stderr.writeln("Can't add page $pascalCase as it's already added.");
      },
      rejectRemove: () async {
        stderr.writeln("Can't remove page $pascalCase as it's not yet added.");
      },
    );
    await DependencyInjection(projectName: '')
        .addController('${pascalCase}Controller');
    dartFormatCode();
    dartFixCode();
  }

  String pascalCaseToSnakeCase(String input) {
    final RegExp exp = RegExp('(?<=[a-z])[A-Z]');
    return input
        .replaceAllMapped(
          exp,
          (Match m) => '_${m.group(0)}',
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
      controller.content(pascalCase, snakeCase),
    );
  }

  Future<void> _createPage(String pascalCase, String snakeCase) async {
    await writeFileWithPrefix(
      path.join(
        'lib',
        'page',
        snakeCase,
        '${snakeCase}_page.dart',
      ),
      page.content(pascalCase, snakeCase),
    );
  }

  Future<void> _handleTheme(String pascalCase, String snakeCase) async {
    if (File(
          path.join(
            'lib',
            'service',
            'theme_service.dart',
          ),
        ).existsSync() &&
        File(
          path.join(
            'lib',
            'theme',
            'theme.dart',
          ),
        ).existsSync()) {
      final String file = path.join(
        'lib',
        'page',
        snakeCase,
        '${snakeCase}_page.dart',
      );
      await addLinesBeforeLineInFile(file, <String, List<String>>{
        'return Container();': <String>[
          'final CustomTheme theme = ThemeService().theme;',
        ],
      });
      await addLinesAfterLineInFile(
        file,
        <String, List<String>>{
          '// https://saynode.ch': <String>[
            "import '../../service/theme_service.dart';",
            "import '../../theme/theme.dart';",
          ],
        },
      );
    }
  }
}

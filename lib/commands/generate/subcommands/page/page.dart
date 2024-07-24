import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../../util/util.dart';
import 'file_manipulators/controller_manipulator.dart';
import 'file_manipulators/page_manipulator.dart';

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
    await _run();
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
        printColor(
          '---- Creating View-Controller $pascalCase ----\n',
          ColorText.cyan,
        );
        Directory(
          path.join('lib', 'page', snakeCase),
        ).createSync();
        Directory(
          path.join('lib', 'page', snakeCase, 'controller'),
        ).createSync();
        Directory(
          path.join('lib', 'page', snakeCase, 'widget'),
        ).createSync();
        await PageManipulator(
          snakeCase,
          pascalCase,
          'lib/page/$snakeCase/${snakeCase}_page.dart',
        ).create();
        await ControllerManipulator(
          pascalCase,
          'lib/page/$snakeCase/controller/${snakeCase}_controller.dart',
        ).create();
      },
      remove: () async {
        printColor(
          '---- Removing View-Controller $pascalCase ----\n',
          ColorText.cyan,
        );
        Directory(
          path.join('lib', 'page', snakeCase),
        ).deleteSync(recursive: true);
        printColor(
          '${path.join('lib', 'page', snakeCase)} - successfully removed ✔',
          ColorText.green,
        );
      },
      rejectAdd: () async {
        printColor(
          "Can't add page $pascalCase as it's already added.",
          ColorText.red,
        );
      },
      rejectRemove: () async {
        printColor(
          "Can't remove page $pascalCase as it's not yet added.",
          ColorText.red,
        );
      },
    );
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
}

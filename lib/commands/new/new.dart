import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/new/files/main.dart'
    as main_file;
import 'package:project_initialization_tool/commands/util.dart';

class Creator extends Command {
  late final String projectName;

  @override
  String get name => 'new';

  @override
  String get description => 'create new project';

  Creator() {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: '--name is mandatory(name of the project))',
      mandatory: true,
    );
  }

  @override
  Future<void> run() async {
    projectName = argResults?['name'];
    await Process.run('flutter', ['create', projectName, '-e'],
        runInShell: true);

    createCommonFolderStructure();
    await addDependencyToPubspec('get', path.join(projectName));
    rewriteMain();

    await File(path.join(projectName, 'added_boilerplate.txt'))
        .writeAsString('');
  }

  void createCommonFolderStructure() {
    Directory(path.join(projectName)).createSync();
    print('- $projectName/ ✔');

    String directory = path.join(
      projectName,
      'lib',
    );

    Directory(directory).createSync();
    print('- $directory/ ✔');

    // Asset
    Directory(path.join(projectName, 'asset')).createSync();
    print('- $projectName/asset ✔');

    // model
    Directory(path.join(directory, 'model')).createSync();
    print('- $directory/model ✔');

    // Page
    Directory(path.join(directory, 'page')).createSync();
    print('- $directory/page ✔');

    // service
    Directory(path.join(directory, 'service')).createSync();
    print('- $directory/service ✔');

    // Theme
    Directory(path.join(directory, 'theme')).createSync();
    print('- $directory/theme ✔');

    // Util
    Directory(path.join(directory, 'util')).createSync();
    print('- $directory/util ✔');

    // Helper
    Directory(path.join(directory, 'helper')).createSync();
    print('- $directory/helper ✔');

    // Widget
    Directory(path.join(directory, 'widget')).createSync();
    print('- $directory/widget ✔');
  }

  helperGenerator() {}

  /// Create the main.dart file
  void rewriteMain() {
    File(
      path.join(
        projectName,
        'lib',
        'main.dart',
      ),
    ).writeAsString(main_file.content(projectName)).then((File file) {
      print('-- /lib/main.dart ✔');
    });
  }
}

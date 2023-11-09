import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/new/files/main.dart'
    as main_file;

class Creator extends Command {
  //TODO: make path configurable
  String basePath = 'build';
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
    Process.run('flutter', ['create', '$basePath/$projectName', '-e'],
        runInShell: true);

    createCommonFolderStructure();
    rewriteMain();
  }

  void createCommonFolderStructure() {
    Directory(basePath).createSync();
    print('- $basePath/ ✔');

    Directory(path.join(basePath, projectName)).createSync();
    print('- $projectName/ ✔');

    String directory = path.join(
      basePath,
      projectName,
      'lib',
    );
    print("basepath: $basePath");
    print("directory: $directory");

    Directory(directory).createSync();
    print('- $directory/ ✔');

    // Asset
    Directory(path.join(basePath, projectName, 'asset')).createSync();
    print('- $projectName/asset ✔');

    // Module
    Directory(path.join(directory, 'module')).createSync();
    print('- $directory/module ✔');

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
  }

  /// Create the main.dart file
  void rewriteMain() {
    File(
      path.join(
        basePath,
        projectName,
        'lib',
        'main.dart',
      ),
    ).writeAsString(main_file.content(projectName)).then((File file) {
      print('-- /lib/main.dart ✔');
    });
  }
}

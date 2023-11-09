import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

class Creator extends Command {
  //TODO: make path configurable
  String basePath = 'build';

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
    final String projectName = argResults?['name'];

    createCommonFolderStructure(projectName);
  }

  void createCommonFolderStructure(String projectName) {
    Directory(basePath).createSync();
    print('- $basePath/ ✔');

    Directory(projectName).createSync();
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
    Directory(path.join(directory, 'asset')).createSync();
    print('- $directory/asset ✔');

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
}

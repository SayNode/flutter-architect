import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/new/files/main.dart'
    as main_file;
import 'package:project_initialization_tool/commands/new/files/splash_page.dart'
    as splash_page;
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
    _createSplashPage();
    rewriteMain();
    addAssetsToPubspec();

    await File(path.join(projectName, 'added_boilerplate.txt'))
        .writeAsString('');
  }

  /// Add assets folder to pubspec.yaml
  void addAssetsToPubspec() {
    String pubPath = path.join(projectName, 'pubspec.yaml');
    File(pubPath).readAsLines().then((List<String> lines) {
      String pubspec = '';

      for (String line in lines) {
        pubspec += '$line\n';

        if (line.contains('flutter:') &&
            pubspec.contains('dev_dependencies:\n')) {
          pubspec += '  assets:\n';
          pubspec += '    - asset/\n';
          pubspec += '\n';
        }
      }

      File(pubPath).writeAsString(pubspec).then((file) {
        print('- Assets added to pubspec.yaml ✔');
      });

      print('# add assets to pubspec CREATED');
    });
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

  _createSplashPage() {
    File(
      path.join(
        projectName,
        'lib',
        'page',
        'splash_page.dart',
      ),
    ).writeAsString(splash_page.content()).then((File file) {
      print('-- /lib/page/splash_page.dart ✔');
    });
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

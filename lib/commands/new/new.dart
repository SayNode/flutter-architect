import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/new/files/analysis_options.dart'
    as analysis_option;
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
    argParser.addFlag('ios');
    argParser.addFlag('android');
    argParser.addFlag('web');
    argParser.addFlag('macos');
    argParser.addFlag('windows');
    argParser.addFlag('linux');
    argParser.addOption(
      'name',
      abbr: 'n',
      help:
          '--name is mandatory(name of the project). Add flags for whatever platform you want to support.',
      mandatory: true,
    );
  }

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    if (!argResults?['ios'] &&
        !argResults?['android'] &&
        !argResults?['web'] &&
        !argResults?['macos'] &&
        !argResults?['windows'] &&
        !argResults?['linux']) {
      print(
          'At least one platform must be selected. Use --help for more information.');
      exit(0);
    }
    projectName = argResults?['name'];
    await Process.run('flutter', ['create', projectName, '-e'],
        runInShell: true);

    await addDependenciesToPubspec(['get'], path.join(projectName));
    createCommonFolderStructure();
    _createSplashPage();
    _rewriteMain();
    addAssetsToPubspec();
    await rewriteAnalysisOptions();

    await File(path.join(projectName, 'added_boilerplate.txt'))
        .writeAsString('');
    await addWorkflow();
    await deleteUnusedFolders();
  }

  deleteUnusedFolders() {
    if (argResults?['ios'] == false) {
      if (Directory(path.join(projectName, 'ios')).existsSync()) {
        Directory(path.join(projectName, 'ios')).deleteSync(recursive: true);
      }
    }
    if (argResults?['android'] == false) {
      if (Directory(path.join(projectName, 'android')).existsSync()) {
        Directory(path.join(projectName, 'android'))
            .deleteSync(recursive: true);
      }
    }
    if (argResults?['macos'] == false) {
      if (Directory(path.join(projectName, 'macos')).existsSync()) {
        Directory(path.join(projectName, 'macos')).deleteSync(recursive: true);
      }
    }
    if (argResults?['windows'] == false) {
      if (Directory(path.join(projectName, 'windows')).existsSync()) {
        Directory(path.join(projectName, 'windows'))
            .deleteSync(recursive: true);
      }
    }
    if (argResults?['web'] == false) {
      if (Directory(path.join(projectName, 'web')).existsSync()) {
        Directory(path.join(projectName, 'web')).deleteSync(recursive: true);
      }
    }
    if (argResults?['linux'] == false) {
      if (Directory(path.join(projectName, 'linux')).existsSync()) {
        Directory(path.join(projectName, 'linux')).deleteSync(recursive: true);
      }
    }
  }

  Future<void> addWorkflow() async {
    Directory(path.join(projectName, '.github')).createSync();
    Directory(path.join(projectName, '.github', 'workflow')).createSync();
    File(path.join(projectName, '.github', 'workflow', 'lint_action.yaml'))
        .writeAsString(
            " \n \nname: Linting Workflow \n \non: pull_request \n \njobs: \n  build: \n    name: Linting \n    runs-on: ubuntu-latest \n    steps: \n      - name: Setup Repository \n        uses: actions/checkout@v2 \n \n      - name: Set up Flutter \n        uses: subosito/flutter-action@v2 \n        with: \n          channel: 'stable' \n      - run: flutter --version \n \n      - name: Install Pub Dependencies \n        run: flutter pub get \n \n      - name: Verify Formatting \n        run: dart format --output=none --set-exit-if-changed . \n      - name: Analyze Project Source \n        run: dart analyze");
  }

  Future<void> rewriteAnalysisOptions() async {
    File(
      path.join(
        projectName,
        'analysis_options.yaml',
      ),
    ).writeAsString(analysis_option.content()).then((File file) {
      print('-- /analysis_options.yaml ✔');
    });
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

  void _createSplashPage() {
    writeFileWithPrefix(
            path.join(
              projectName,
              'lib',
              'page',
              'splash_page.dart',
            ),
            splash_page.content())
        .then((File file) {
      print('-- /lib/page/splash_page.dart ✔');
    });
  }

  helperGenerator() {}

  /// Create the main.dart file
  void _rewriteMain() {
    writeFileWithPrefix(
            path.join(
              projectName,
              'lib',
              'main.dart',
            ),
            main_file.content(projectName))
        .then((File file) {
      print('-- /lib/main.dart ✔');
    });
  }
}

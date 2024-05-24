// ignore_for_file: avoid_dynamic_calls

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../util/util.dart';
import 'files/analysis_options.dart' as analysis_option;
import 'files/codemagic_yaml.dart' as codemagic_yaml;
import 'files/dependency_injection.dart';
import 'files/main.dart' as main_file;
import 'files/splash_page.dart' as splash_page;

class Creator extends Command<dynamic> {
  Creator() {
    argParser
      ..addFlag('ios')
      ..addFlag('android')
      ..addFlag('web')
      ..addFlag('macos')
      ..addFlag('windows')
      ..addFlag('linux')
      ..addOption(
        'name',
        abbr: 'n',
        help:
            '--name is mandatory(name of the project). Add flags for whatever platform you want to support.',
        mandatory: true,
      );
  }
  late final String projectName;

  @override
  String get name => 'new';

  @override
  String get description => 'create new project';

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
      stderr.writeln(
        'At least one platform must be selected. Use --help for more information.',
      );
      exit(0);
    }
    projectName = argResults?['name'];
    await Process.run(
      'flutter',
      <String>['create', projectName, '-e'],
      runInShell: true,
    );
    Directory.current = '${Directory.current.path}/$projectName';
    await addDependenciesToPubspec(<String>['get'], null);
    createCommonFolderStructure();
    _createSplashPage();
    _rewriteMain();
    addAssetsToPubspec();
    await rewriteAnalysisOptions();
    await addCodemagicYaml();

    await File(path.join('added_boilerplate.txt')).writeAsString('');
    await addWorkflow();
    deleteUnusedFolders();
    await addMultidex();
    await _addDepencyInjection();
  }

  Future<void> addMultidex() async {
    if (argResults?['android'] == true) {
      await addLinesAfterLineInFile(
          path.join('android', 'app', 'build.gradle'), <String, List<String>>{
        'defaultConfig {': <String>['        multiDexEnabled true'],
      });
      await replaceLineInFile(
        path.join('android', 'app', 'build.gradle'),
        'dependencies {}',
        "dependencies {\n    implementation 'androidx.multidex:multidex:2.0.1'\n}",
      );
    }
  }

  void deleteUnusedFolders() {
    if (argResults?['ios'] == false) {
      if (Directory(path.join('ios')).existsSync()) {
        Directory(path.join('ios')).deleteSync(recursive: true);
      }
    }
    if (argResults?['android'] == false) {
      if (Directory(path.join('android')).existsSync()) {
        Directory(path.join('android')).deleteSync(recursive: true);
      }
    }
    if (argResults?['macos'] == false) {
      if (Directory(path.join('macos')).existsSync()) {
        Directory(path.join('macos')).deleteSync(recursive: true);
      }
    }
    if (argResults?['windows'] == false) {
      if (Directory(path.join('windows')).existsSync()) {
        Directory(path.join('windows')).deleteSync(recursive: true);
      }
    }
    if (argResults?['web'] == false) {
      if (Directory(path.join('web')).existsSync()) {
        Directory(path.join('web')).deleteSync(recursive: true);
      }
    }
    if (argResults?['linux'] == false) {
      if (Directory(path.join('linux')).existsSync()) {
        Directory(path.join('linux')).deleteSync(recursive: true);
      }
    }
  }

  Future<void> addWorkflow() async {
    Directory(path.join('.github')).createSync();
    Directory(path.join('.github', 'workflows')).createSync();
    await File(
      path.join('.github', 'workflows', 'lint_action.yaml'),
    ).writeAsString(
      " \n \nname: Linting Workflow \n \non: pull_request \n \njobs: \n  build: \n    name: Linting \n    runs-on: ubuntu-latest \n    steps: \n      - name: Setup Repository \n        uses: actions/checkout@v2 \n \n      - name: Set up Flutter \n        uses: subosito/flutter-action@v2 \n        with: \n          channel: 'stable' \n      - run: flutter --version \n \n      - name: Install Pub Dependencies \n        run: flutter pub get \n \n      - name: Verify Formatting \n        run: dart format --output=none --set-exit-if-changed . \n      - name: Analyze Project Source \n        run: dart analyze --fatal-infos",
    );
  }

  Future<void> rewriteAnalysisOptions() async {
    await File(
      path.join(
        'analysis_options.yaml',
      ),
    ).writeAsString(analysis_option.content()).then((File file) {
      stderr.writeln('-- /analysis_options.yaml ✔');
    });
  }

  Future<void> addCodemagicYaml() async {
    await File(
      path.join(
        'codemagic.yaml',
      ),
    ).writeAsString(codemagic_yaml.content()).then((File file) {
      stderr.writeln('-- /codemagic.yaml ✔');
    });
  }

  /// Add assets folder to pubspec.yaml
  void addAssetsToPubspec() {
    final String pubPath = path.join('pubspec.yaml');
    File(pubPath).readAsLines().then((List<String> lines) {
      final StringBuffer buffer = StringBuffer();

      for (final String line in lines) {
        buffer.write('$line\n');

        if (line.contains('flutter:') &&
            buffer.toString().contains('dev_dependencies:\n')) {
          buffer
            ..write('  assets:\n')
            ..write('    - asset/\n')
            ..write('\n');
        }
      }

      File(pubPath).writeAsString(buffer.toString()).then((File file) {
        stderr.writeln('- Assets added to pubspec.yaml ✔');
      });

      stderr.writeln('# add assets to pubspec CREATED');
    });
  }

  void createCommonFolderStructure() {
    Directory(Directory.current.path).createSync();
    stderr.writeln('- $projectName/ ✔');

    final String directory = path.join(
      'lib',
    );

    Directory(directory).createSync();
    stderr.writeln('- $directory/ ✔');

    // Asset
    Directory(path.join('asset')).createSync();
    stderr.writeln('- $projectName/asset ✔');

    // model
    Directory(path.join(directory, 'model')).createSync();
    stderr.writeln('- $directory/model ✔');

    // Page
    Directory(path.join(directory, 'page')).createSync();
    stderr.writeln('- $directory/page ✔');

    // service
    Directory(path.join(directory, 'service')).createSync();
    stderr.writeln('- $directory/service ✔');

    // Theme
    Directory(path.join(directory, 'theme')).createSync();
    stderr.writeln('- $directory/theme ✔');

    // Util
    Directory(path.join(directory, 'util')).createSync();
    stderr.writeln('- $directory/util ✔');

    // Helper
    Directory(path.join(directory, 'helper')).createSync();
    stderr.writeln('- $directory/helper ✔');

    // Widget
    Directory(path.join(directory, 'widget')).createSync();
    stderr.writeln('- $directory/widget ✔');
  }

  void _createSplashPage() {
    writeFileWithPrefix(
      path.join(
        'lib',
        'page',
        'splash_page.dart',
      ),
      splash_page.content(),
    ).then((File file) {
      stderr.writeln('-- /lib/page/splash_page.dart ✔');
    });
  }

  /// Create the main.dart file
  void _rewriteMain() {
    writeFileWithPrefix(
      path.join(
        'lib',
        'main.dart',
      ),
      main_file.content(projectName),
    ).then((File file) {
      stderr.writeln('-- /lib/main.dart ✔');
    });
  }

  Future<void> _addDepencyInjection() async {
    final DependencyInjection dependencyInjection = DependencyInjection();
    await dependencyInjection.create();
  }
}

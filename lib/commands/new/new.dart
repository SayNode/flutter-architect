// ignore_for_file: avoid_dynamic_calls

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../util/util.dart';
import 'files/analysis_options.dart' as analysis_option;
import 'files/codemagic_yaml.dart' as codemagic_yaml;
import 'files/constant_manipulator.dart';
import 'files/custom_scaffold_manipulator.dart';
import 'files/dependency_injection.dart';
import 'files/logger_service_manipulator.dart';
import 'files/main.dart' as main_file;
import 'files/splash_page.dart' as splash_page;
import 'files/util.dart' as util;
import 'files/error_page.dart' as error_page;
import 'files/error_page_controller.dart' as error_page_controller;

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
      )
      ..addOption(
        'org',
        abbr: 'o',
        help:
            '--org is mandatory(domain of the project). Organise the domain so that it is owned by SayNode or the customer before initializing the project.',
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
      <String>['create', '--org=${argResults?['org']}', projectName, '-e'],
      runInShell: true,
    ).then((ProcessResult result) {
      stderr.writeln(result.stdout);
    });
    Directory.current = '${Directory.current.path}/$projectName';
    await addDependenciesToPubspec(<String>['get', 'is_first_run'], null);
    createCommonFolderStructure();
    _createSplashPage();
    _rewriteMain();
    _createUtil();
    _createErrorPage();
    addAssetsToPubspec();
    await rewriteAnalysisOptions();
    await addCodemagicYaml();

    await File(path.join('added_boilerplate.txt')).writeAsString('');
    await addWorkflow();
    deleteUnusedFolders();

    //Add Dependency Injection
    final DependencyInjection dependencyInjection =
        DependencyInjection(projectName: projectName);
    await dependencyInjection.create();

    //Add constants
    final ConstantManipulator constantManipulator = ConstantManipulator();
    await constantManipulator.create();

    //Add Logger Service
    final LoggerServiceManipulator loggerServiceManipulator =
        LoggerServiceManipulator();
    await loggerServiceManipulator.create(projectName: projectName);
    await dependencyInjection.addService(
      loggerServiceManipulator.name,
      initialize: true,
      servicePath: loggerServiceManipulator.path,
    );

    //Add Logger Service
    final CustomScaffoldManipulator customScaffoldManipulator =
        CustomScaffoldManipulator();
    await customScaffoldManipulator.create();
    if (argResults?['ios'] == true || argResults?['android'] == true) {
      await updateGradleFile();
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
      bool isAssetsIncluded = false;
      for (final String line in lines) {
        if (line.contains('  assets:')) {
          isAssetsIncluded = true;
        }
      }

      for (final String line in lines) {
        buffer.write('$line\n');

        if (line.contains('flutter:') &&
            buffer.toString().contains('dev_dependencies:\n') &&
            !isAssetsIncluded) {
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

  /// Update the gradle file with the CI/CD configuration & multidex
  Future<void> updateGradleFile() async {
    final String pubPath = path.join('android', 'app', 'build.gradle');
    await File(pubPath).readAsLines().then((List<String> lines) {
      final StringBuffer buffer = StringBuffer();
      int lineNumber = 0;
      bool keystoreUpdated = false;
      bool isMultidexUpdated = false;
      bool isMultidexImplementationUpdated = false;
      bool isSigningConfigUpdated = false;
      for (final String line in lines) {
        if (line.contains('keystoreProperties')) {
          keystoreUpdated = true;
        }
        if (line.contains('multiDexEnabled')) {
          isMultidexUpdated = true;
        }
        if (line
            .contains("implementation 'androidx.multidex:multidex:2.0.1'")) {
          isMultidexImplementationUpdated = true;
        }
        if (line.contains('System.getenv()["CI"]')) {
          isSigningConfigUpdated = true;
        }
      }

      for (final String line in lines) {
        buffer.write('$line\n');

        if (lineNumber == 15 && !keystoreUpdated) {
          buffer
            ..write('\n')
            ..write('def keystoreProperties = new Properties()\n')
            ..write(
              "def keystorePropertiesFile = rootProject.file('key.properties')\n",
            )
            ..write('if (keystorePropertiesFile.exists()) {\n')
            ..write(
              ' keystoreProperties.load(new FileInputStream(keystorePropertiesFile))\n',
            )
            ..write('}\n')
            ..write('\n');
        }

        if (line.contains('android {') && !isSigningConfigUpdated) {
          buffer
            ..write('\n')
            ..write('    signingConfigs {\n')
            ..write('        release {\n')
            ..write('            if (System.getenv()["CI"]) {\n')
            ..write(
              '                storeFile file(System.getenv()["CM_KEYSTORE_PATH"])\n',
            )
            ..write(
              '                storePassword System.getenv()["CM_KEYSTORE_PASSWORD"]\n',
            )
            ..write(
              '                keyAlias System.getenv()["CM_KEY_ALIAS"]\n',
            )
            ..write(
              '                keyPassword System.getenv()["CM_KEY_PASSWORD"]\n',
            )
            ..write('            } else {\n')
            ..write("                keyAlias keystoreProperties['keyAlias']\n")
            ..write(
              "                keyPassword keystoreProperties['keyPassword']\n",
            )
            ..write(
              "                storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null\n",
            )
            ..write(
              "                storePassword keystoreProperties['storePassword']\n",
            )
            ..write('            }\n')
            ..write('        }\n')
            ..write('    }\n')
            ..write('\n');
        }

        if (line.contains('defaultConfig {') && !isMultidexUpdated) {
          buffer
            ..write('\n')
            ..write('        multiDexEnabled true\n')
            ..write('\n');
        }

        if (lines.length == lineNumber + 1 &&
            !isMultidexImplementationUpdated) {
          buffer
            ..write('\n')
            ..write(
              "dependencies {\n    implementation 'androidx.multidex:multidex:2.0.1'\n}",
            )
            ..write('\n');
        }
        lineNumber++;
      }

      File(pubPath).writeAsString(buffer.toString()).then((File file) {
        stderr.writeln('- Config updated in build.gradle ✔');
      });

      stderr.writeln('# config in build.gradle CREATED');
    });
    await replaceLineInFile(
      pubPath,
      'signingConfig = signingConfigs.debug',
      '            signingConfig = signingConfigs.release',
    );
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

  // Create the util.dart file
  void _createUtil() {
    writeFileWithPrefix(
      path.join('lib', 'util', 'util.dart'),
      util.content(),
    );
  }

  // Create the error_page.dart file
  void _createErrorPage() {
    Directory(path.join('lib', 'page', 'error')).createSync();
    Directory(path.join('lib', 'page', 'error', 'controller')).createSync();
    writeFileWithPrefix(
      path.join('lib', 'page', 'error', 'error_page.dart'),
      error_page.content(),
    ).then((File file) {
      stderr.writeln('-- /lib/page/error/error_page.dart ✔');
    });
    writeFileWithPrefix(
      path.join(
          'lib', 'page', 'error', 'controller', 'error_page_controller.dart'),
      error_page_controller.content(),
    ).then((File file) {
      stderr.writeln('-- /lib/page/error/error_page_controller.dart ✔');
    });
  }
}

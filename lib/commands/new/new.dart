// ignore_for_file: avoid_dynamic_calls

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../util.dart';
import 'files/analysis_options.dart' as analysis_option;
import 'files/codemagic_yaml.dart' as codemagic_yaml;
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
    );

    await addDependenciesToPubspec(<String>['get'], path.join(projectName));
    createCommonFolderStructure();
    _createSplashPage();
    _rewriteMain();
    addAssetsToPubspec();
    await rewriteAnalysisOptions();
    await addCodemagicYaml();

    await File(path.join(projectName, 'added_boilerplate.txt'))
        .writeAsString('');
    await addWorkflow();
    deleteUnusedFolders();
    await updateGradleFile();
  }

  void deleteUnusedFolders() {
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
    Directory(path.join(projectName, '.github', 'workflows')).createSync();
    await File(
      path.join(projectName, '.github', 'workflows', 'lint_action.yaml'),
    ).writeAsString(
      " \n \nname: Linting Workflow \n \non: pull_request \n \njobs: \n  build: \n    name: Linting \n    runs-on: ubuntu-latest \n    steps: \n      - name: Setup Repository \n        uses: actions/checkout@v2 \n \n      - name: Set up Flutter \n        uses: subosito/flutter-action@v2 \n        with: \n          channel: 'stable' \n      - run: flutter --version \n \n      - name: Install Pub Dependencies \n        run: flutter pub get \n \n      - name: Verify Formatting \n        run: dart format --output=none --set-exit-if-changed . \n      - name: Analyze Project Source \n        run: dart analyze --fatal-infos",
    );
  }

  Future<void> rewriteAnalysisOptions() async {
    await File(
      path.join(
        projectName,
        'analysis_options.yaml',
      ),
    ).writeAsString(analysis_option.content()).then((File file) {
      stderr.writeln('-- /analysis_options.yaml ✔');
    });
  }

  Future<void> addCodemagicYaml() async {
    await File(
      path.join(
        projectName,
        'codemagic.yaml',
      ),
    ).writeAsString(codemagic_yaml.content()).then((File file) {
      stderr.writeln('-- /codemagic.yaml ✔');
    });
  }

  /// Add assets folder to pubspec.yaml
  void addAssetsToPubspec() {
    final String pubPath = path.join(projectName, 'pubspec.yaml');
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

  /// Update the gradle file with the CI/CD configuration & multidex
  Future<void> updateGradleFile() async {
    final String pubPath =
        path.join(projectName, 'android', 'app', 'build.gradle');
    await replaceLineInFile(
      pubPath,
      'signingConfig = signingConfigs.debug',
      '            signingConfig = signingConfigs.release',
    );
    await File(pubPath).readAsLines().then((List<String> lines) {
      final StringBuffer buffer = StringBuffer();
      int lineNumber = 0;
      bool keystoreUpdated = false;
      bool isPluginUpdated = false;
      bool isMultidexUpdated = false;
      bool isMultidexImplementationUpdated = false;
      bool isSigningConfigUpdated = false;
      for (final String line in lines) {
        if (line.contains('com.google.firebase.firebase-perf')) {
          isPluginUpdated = true;
        }
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

        if (line.contains('dev.flutter.flutter-gradle-plugin') &&
            !isPluginUpdated) {
          buffer
            ..write('\n')
            ..write('    id "com.google.firebase.firebase-perf"\n')
            ..write('    id "com.google.firebase.crashlytics"\n')
            ..write('    id "com.google.gms.google-services"\n')
            ..write('\n');
        }

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
  }

  void createCommonFolderStructure() {
    Directory(path.join(projectName)).createSync();
    stderr.writeln('- $projectName/ ✔');

    final String directory = path.join(
      projectName,
      'lib',
    );

    Directory(directory).createSync();
    stderr.writeln('- $directory/ ✔');

    // Asset
    Directory(path.join(projectName, 'asset')).createSync();
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
        projectName,
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
        projectName,
        'lib',
        'main.dart',
      ),
      main_file.content(projectName),
    ).then((File file) {
      stderr.writeln('-- /lib/main.dart ✔');
    });
  }
}

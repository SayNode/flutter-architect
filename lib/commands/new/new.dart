// ignore_for_file: avoid_dynamic_calls

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../util/util.dart';
import 'file_manipulators/constant_manipulator.dart';
import 'file_manipulators/custom_scaffold_manipulator.dart';
import 'file_manipulators/dependency_injection.dart';
import 'file_manipulators/error_page.dart';
import 'file_manipulators/logger_service_manipulator.dart';
import 'file_manipulators/main_file_manipulator.dart';
import 'file_manipulators/main_base_file_manipulator.dart';
import 'file_manipulators/util_file_manipulator.dart';
import 'files/analysis_options.dart' as analysis_option;
import 'files/codemagic_yaml.dart' as codemagic_yaml;
import 'files/workflows.dart';

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
            '--name is mandatory (name of the project). Add flags for whatever platform you want the project to support.',
        mandatory: true,
      )
      ..addOption(
        'org',
        abbr: 'o',
        help:
            '--org is mandatory (domain of the project). Organise the domain so that it is owned by SayNode or the customer before initializing the project.',
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
    // Check if at least one platform was specified
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

    // Get name
    projectName = argResults?['name'];

    // Create project
    await Process.run(
      'flutter',
      <String>['create', '--org=${argResults?['org']}', projectName, '-e'],
      runInShell: true,
    ).then((ProcessResult result) {
      stderr.writeln(result.stdout);
    });

    // Set current directory to new project directory
    Directory.current = '${Directory.current.path}/$projectName';

    // Create common folder structure
    createCommonFolderStructure();

    // Add common dependencies
    await addDependenciesToPubspec(<String>['get', 'is_first_run'], null);

    // Create common dart files
    await MainFileManipulator().create();
    printColor('Main created ✔', ColorText.green);
    await MainBaseFileManipulator().create();
    printColor('Main Base file created ✔', ColorText.green);
    await UtilFileManipulator().create();
    printColor('Util file created ✔', ColorText.green);
    await ErrorPageManipulator().create();
    printColor('Error Page file created ✔', ColorText.green);
    await CustomScaffoldManipulator().create();
    printColor('Custom Scaffold file created ✔', ColorText.green);
    await ConstantManipulator().create();
    printColor('Constants file created ✔', ColorText.green);
    await DependencyInjection(projectName: projectName).create();
    printColor('Dependency Injection file created ✔', ColorText.green);
    await LoggerServiceManipulator().create(
      projectName: projectName,
    );
    printColor('Logger Service created ✔', ColorText.green);
    emptyLine();

    // Add analysis options with custom rules
    await rewriteAnalysisOptions();

    // Add assets paths to pubspec.yaml
    await addAssetsToPubspec();

    // Add codemagic.yaml for CI/CD
    await addCodemagicYaml();

    // Create "added boilerplate" file for generate commands
    await File(path.join('added_boilerplate.txt')).writeAsString('');
    await addWorkflow(prAgent);
    await addWorkflow(lintingWorkflow);
    deleteUnusedFolders();

    // Update gradle file for android only
    if (argResults?['android'] == true) {
      await updateGradleFile();
    }

    emptyLine();

    // Fix and format dart code
    dartFixCode();
    dartFormatCode();
  }

  /// Deleted directories for non-supported platforms
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

  Future<void> rewriteAnalysisOptions() async {
    await File(
      path.join(
        'analysis_options.yaml',
      ),
    ).writeAsString(analysis_option.content()).then((File file) {
      printColor('-- /analysis_options.yaml ✔', ColorText.green);
    });
  }

  /// Add CI/CD configuration to codemagic.yaml
  Future<void> addCodemagicYaml() async {
    await File(
      path.join(
        'codemagic.yaml',
      ),
    ).writeAsString(codemagic_yaml.content()).then((File file) {
      printColor('-- /codemagic.yaml ✔', ColorText.green);
    });
  }

  /// Add assets paths to pubspec.yaml
  Future<void> addAssetsToPubspec() async {
    final String pubPath = path.join('pubspec.yaml');
    final List<String> lines = await File(pubPath).readAsLines();
    // Find out if assets is already included
    for (final String line in lines) {
      if (line.contains('  assets:')) {
        return;
      }
    }

    // Add assets to pubspec.yaml
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

    await File(pubPath).writeAsString(buffer.toString()).then((File file) {
      printColor('Assets added to pubspec.yaml ✔', ColorText.green);
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
        printColor('Config in build.gradle ✔', ColorText.green);
      });
    });
    await replaceLineInFile(
      pubPath,
      'signingConfig = signingConfigs.debug',
      '            signingConfig = signingConfigs.release',
    );
  }

  /// Create common folder structure for an
  /// MVC (Model-View-Controller) architecture
  void createCommonFolderStructure() {
    printColor('Creating MVC directories:', ColorText.white);

    Directory(Directory.current.path).createSync();
    printColor('-- $projectName/ ✔', ColorText.green);

    final String directory = path.join('lib');

    Directory(directory).createSync();
    printColor('-- $directory/ ✔', ColorText.green);

    // Asset
    Directory(path.join('asset')).createSync();
    printColor('-- $projectName/asset ✔', ColorText.green);

    // model
    Directory(path.join(directory, 'model')).createSync();
    printColor('-- $directory/model ✔', ColorText.green);

    // Page
    Directory(path.join(directory, 'page')).createSync();
    printColor('-- $directory/page ✔', ColorText.green);

    // interface
    Directory(path.join(directory, 'interface')).createSync();
    printColor('-- $directory/interface ✔', ColorText.green);

    // service
    Directory(path.join(directory, 'service')).createSync();
    printColor('-- $directory/service ✔', ColorText.green);

    // Theme
    Directory(path.join(directory, 'theme')).createSync();
    printColor('-- $directory/theme ✔', ColorText.green);

    // Util
    Directory(path.join(directory, 'util')).createSync();
    printColor('-- $directory/util ✔', ColorText.green);

    // Helper
    Directory(path.join(directory, 'helper')).createSync();
    printColor('-- $directory/helper ✔', ColorText.green);

    // Widget
    Directory(path.join(directory, 'widget')).createSync();
    printColor('-- $directory/widget ✔', ColorText.green);

    emptyLine();
  }
}

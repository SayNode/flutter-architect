import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../../util/util.dart';
import 'code/firebase_configuration.dart' as firebase_configuration;
import 'code/main/imports.dart' as imports;
import 'code/main/fatal_error.dart' as fatal_error;
import 'code/main/non_fatal_error.dart' as non_fatal_error;
import 'code/main/dev_error.dart' as dev_error;

class GenerateCrashlyticsService extends Command<dynamic> {
  GenerateCrashlyticsService() {
    // Add parser options or flag here
    argParser
      ..addFlag(
        'force',
        help: 'Force replace in case it already exists.',
      )
      ..addFlag(
        'remove',
        help: 'Remove in case it already exists.',
      );
  }
  @override
  String get description => 'Create crashlytics files and boilerplate code;';

  @override
  String get name => 'crashlytics';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('crashlytics');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        stderr.writeln('Creating Crashlytics...');
        await addAlreadyRun('crashlytics');
        _printInitialInstructions();
        _addDependencies();
        await _addFirebaseConfigurationScript();
        await _addMainChanges();
        formatCode();
        dartFixCode();
        _printFinalInstructions();
      },
      remove: () async {
        stderr.writeln('Removing Crashlytics...');
        await removeAlreadyRun('crashlytics');
        _removeDependencies();
        await _removeFirebaseConfigurationScript();
        await _removeMainChanges();
        formatCode();
        dartFixCode();
      },
      rejectAdd: () async {
        stderr.writeln("Can't add Crashlytics as it's already configured.");
      },
      rejectRemove: () async {
        stderr.writeln("Can't remove Crashlytics as it's not yet configured.");
      },
    );
  }

  void _addDependencies() {
    addDependenciesToPubspecSync(
      <String>[
        'firebase_core',
        'firebase_crashlytics',
      ],
      null,
    );
  }

  void _removeDependencies() {
    removeDependenciesFromPubspecSync(
      <String>[
        'firebase_core',
        'firebase_crashlytics',
      ],
      null,
    );
  }

  void _printInitialInstructions() {
    printColor(
      'This script will add the code required to catch errors and send them to crashlytics.',
      ColorText.yellow,
    );
    printColor(
      'However, to use this feature, you need to first configure firebase and crashlytics for this project.',
      ColorText.yellow,
    );
    printColor(
      'You can do this with the following commands:',
      ColorText.yellow,
    );
    printColor(
      'chmod +x ./firebase_configuration.sh',
      ColorText.magenta,
    );
    printColor(
      './firebase_configuration.sh',
      ColorText.magenta,
    );
    printColor(
      'You can follow the official guide for flutter at https://firebase.google.com/docs/crashlytics/get-started?platform=flutter',
      ColorText.yellow,
    );
  }

  void _printFinalInstructions() {
    printColor(
      'Added following dependencies: firebase_core, firebase_crashalitics',
      ColorText.green,
    );
    printColor('REMEMBER TO RUN', ColorText.green);
    printColor('chmod +x ./firebase_configuration.sh', ColorText.magenta);
    printColor('./firebase_configuration.sh', ColorText.magenta);
  }

  Future<void> _addMainChanges() async {
    final String mainPath = path.join('lib', 'main.dart');

    await addLinesAfterLineInFile(
      mainPath,
      <String, List<String>>{
        '// Error in Development:': <String>[
          dev_error.content(),
        ],
        '// Fatal error in Production:': <String>[
          fatal_error.content(),
        ],
        '// Non-Fatal error in Production:': <String>[
          non_fatal_error.content(),
        ],
        '// https://saynode.ch': <String>[
          imports.content(),
        ],
      },
    );
  }

  Future<void> _removeMainChanges() async {
    final String mainPath = path.join('lib', 'main.dart');
    await removeTextFromFile(mainPath, imports.content());
    await removeTextFromFile(mainPath, non_fatal_error.content());
    await removeTextFromFile(mainPath, fatal_error.content());
    await removeTextFromFile(mainPath, dev_error.content());
  }

  Future<void> _addFirebaseConfigurationScript() async {
    await File(path.join('firebase_configuration.sh'))
        .writeAsString(firebase_configuration.content());
  }

  Future<void> _removeFirebaseConfigurationScript() async {
    await File(path.join('firebase_configuration.sh')).delete();
  }
}

import 'dart:io';

import 'package:args/command_runner.dart';
import '../../../../util/util.dart';
import '../../../new/file_manipulators/main_file_manipulator.dart';
import 'file_manipulators/firebase_configuration_manipulator.dart';

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
    await _run();
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
        printColor('--------- Adding Crashlytics ---------\n', ColorText.cyan);
        await addAlreadyRun('crashlytics');
        addDependenciesToPubspecSync(
          <String>[
            'firebase_core',
            'firebase_crashlytics',
          ],
          null,
        );
        await FirebaseConfigurationManipulator().create();
        await MainFileManipulator().addCrashlytics();
        printFinalInstructions();
      },
      remove: () async {
        stderr.writeln('Removing Crashlytics...');
        await removeAlreadyRun('crashlytics');
        removeDependenciesFromPubspecSync(
          <String>[
            'firebase_core',
            'firebase_crashlytics',
          ],
          null,
        );
        await FirebaseConfigurationManipulator().remove();
        await MainFileManipulator().removeCrashlytics();
      },
      rejectAdd: () async {
        printColor(
          "Can't add Crashlytics as it's already configured.",
          ColorText.red,
        );
      },
      rejectRemove: () async {
        printColor(
          "Can't remove Crashlytics as it's not yet configured.",
          ColorText.red,
        );
      },
    );
  }

  void printFinalInstructions() {
    printColor(
      'Crashlytics was successfully added to your project.',
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
}

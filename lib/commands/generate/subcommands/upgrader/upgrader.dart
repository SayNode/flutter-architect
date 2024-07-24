import 'dart:io';

import 'package:args/command_runner.dart';

import '../../../../util/util.dart';
import 'file_manipulators/upgrader_service_manipulator.dart';

class GenerateUpgraderService extends Command<dynamic> {
  GenerateUpgraderService() {
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
  String get description =>
      'Create Upgrader Service related files and boilerplate code;';

  @override
  String get name => 'upgrader';

  @override
  Future<void> run() async {
    await _run();
  }

  Future<void> _run() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('upgrader');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        printColor('------- Creating Upgrader -------\n', ColorText.cyan);
        await addAlreadyRun('upgrader');
        addDependenciesToPubspecSync(
          <String>['package_info_plus', 'html', 'upgrader'],
          null,
        );
        await UpgraderServiceManipulator().create();
      },
      remove: () async {
        printColor('------- Removing Upgrader -------\n', ColorText.cyan);
        await removeAlreadyRun('upgrader');
        removeDependenciesFromPubspecSync(
          <String>['package_info_plus', 'html', 'upgrader'],
          null,
        );
        await UpgraderServiceManipulator().remove();
      },
      rejectAdd: () async {
        printColor(
          "Can't add Upgrader Service as it's already configured.",
          ColorText.red,
        );
      },
      rejectRemove: () async {
        printColor(
          "Can't remove Upgrader Service as it's not yet configured.",
          ColorText.red,
        );
      },
    );
  }
}

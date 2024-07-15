import 'dart:io';

import 'package:args/command_runner.dart';

import '../../../../util/util.dart';
import 'upgrader_service_manipulator.dart';

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
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('upgrader');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    final UpgraderServiceManipulator upgraderServiceManipulator =
        UpgraderServiceManipulator();
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        stderr.writeln('Creating Connectivity Service...');
        await addAlreadyRun('upgrader');
        await upgraderServiceManipulator.create(initialize: true);
        formatCode();
        dartFixCode();
      },
      remove: () async {
        stderr.writeln('Removing Connectivity Service...');
        await removeAlreadyRun('upgrader');
        await upgraderServiceManipulator.remove();
        formatCode();
        dartFixCode();
      },
      rejectAdd: () async {
        stderr
            .writeln("Can't add Upgrader Service as it's already configured.");
      },
      rejectRemove: () async {
        stderr.writeln(
          "Can't remove Upgrader Service as it's not yet configured.",
        );
      },
    );
  }
}

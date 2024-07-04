import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../../util/util.dart';
import '../../../new/file_manipulators/constant_manipulator.dart';
import '../storage/storage.dart';
import 'code/auth_service.dart' as auth_service;
import 'file_manipulators/api_service_interface_manipulator.dart';
import 'file_manipulators/api_service_manipulator.dart';

class GenerateAPIService extends Command<dynamic> {
  GenerateAPIService() {
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
      'Create API and Auth Service related files and boilerplate code;';

  @override
  String get name => 'api';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    // Check if Shared Storage has already been set up. Theme requires Shared Storage.
    // If not, run GenerateStorageService.runShared().
    final bool value = await checkIfAlreadyRunWithReturn('storage');
    if (!value) {
      final GenerateStorageService storageService = GenerateStorageService();
      await storageService.run();
    }

    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('api');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        stderr.writeln('Creating API Service...');
        await addAlreadyRun('api');
        addDependenciesToPubspecSync(<String>['http'], null);

        await ApiServiceInterfaceManipulator().create();
        await ApiServiceManipulator().create();

        await ConstantManipulator().create();
        await _addAuthService();
      },
      remove: () async {
        stderr.writeln('Removing API Service...');
        await removeAlreadyRun('api');
        removeDependenciesFromPubspecSync(<String>['http'], null);
        await _removeAuthService();
        await ApiServiceInterfaceManipulator().remove();
        await ApiServiceManipulator().remove();
        await ConstantManipulator().remove();
      },
      rejectAdd: () async {
        stderr.writeln("Can't add API Service as it's already configured.");
      },
      rejectRemove: () async {
        stderr.writeln("Can't remove API Service as it's not yet configured.");
      },
    );
    formatCode();
    dartFixCode();
  }

  Future<void> _removeAuthService() async {
    await File(path.join('lib', 'service', 'auth_service.dart')).delete();
  }

  Future<void> _addAuthService() async {
    await writeFileWithPrefix(
      path.join('lib', 'service', 'auth_service.dart'),
      auth_service.content(),
    );
  }
}

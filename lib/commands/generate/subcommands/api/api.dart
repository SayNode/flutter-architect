import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../../util/util.dart';
import '../storage/storage.dart';
import 'code/auth_service.dart' as auth_service;
import 'code/constants.dart' as constants;
import 'code/user_model.dart' as user_model;
import 'code/user_state_service.dart' as user_state_service;
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
        await ApiServiceManipulator().create();
        await _addUserModel();
        await _addUserStateService();
        await _addConstants();
        await _addAuthService();
      },
      remove: () async {
        stderr.writeln('Removing API Service...');
        await removeAlreadyRun('api');
        removeDependenciesFromPubspecSync(<String>['http'], null);
        await _removeAuthService();
        await ApiServiceManipulator().remove();
        await _removeConstants();
        await _removeUserStateService();
        await _removeUserModel();
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

  Future<void> _removeConstants() async {
    await File(path.join('lib', 'util', 'constants.dart')).delete();
  }

  Future<void> _removeAuthService() async {
    await File(path.join('lib', 'service', 'auth_service.dart')).delete();
  }

  Future<void> _removeUserModel() async {
    await File(path.join('lib', 'model', 'user.dart')).delete();
  }

  Future<void> _removeUserStateService() async {
    await File(path.join('lib', 'service', 'user_state_service.dart')).delete();
  }

  Future<void> _addConstants() async {
    await writeFileWithPrefix(
      path.join('lib', 'util', 'constants.dart'),
      constants.content(),
    );
  }

  Future<void> _addAuthService() async {
    await writeFileWithPrefix(
      path.join('lib', 'service', 'auth_service.dart'),
      auth_service.content(),
    );
  }

  Future<void> _addUserModel() async {
    await writeFileWithPrefix(
      path.join('lib', 'model', 'user.dart'),
      user_model.content(),
    );
  }

  Future<void> _addUserStateService() async {
    await writeFileWithPrefix(
      path.join('lib', 'service', 'user_state_service.dart'),
      user_state_service.content(),
    );
  }
}

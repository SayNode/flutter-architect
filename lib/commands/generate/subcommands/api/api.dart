import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/generate/subcommands/api/code/constants.dart'
    as constants;
import 'package:project_initialization_tool/commands/generate/subcommands/api/code/api_service.dart'
    as api_service;
import 'package:project_initialization_tool/commands/generate/subcommands/api/code/auth_service.dart'
    as auth_service;
import 'package:project_initialization_tool/commands/generate/subcommands/api/code/user_model.dart'
    as user_model;
import 'package:project_initialization_tool/commands/generate/subcommands/api/code/user_state_service.dart'
    as user_state_service;
import 'package:project_initialization_tool/commands/generate/subcommands/storage/storage.dart';
import 'package:project_initialization_tool/commands/util.dart';

class GenerateAPIService extends Command {
  @override
  String get description =>
      'Create API and Auth Service related files and boilerplate code;';

  @override
  String get name => 'api';

  GenerateAPIService() {
    // Add parser options or flag here
    argParser.addFlag('force',
        defaultsTo: false, help: 'Force replace in case it already exists.');
    argParser.addFlag('remove',
        defaultsTo: false, help: 'Remove in case it already exists.');
  }

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    // Check if Shared Storage has already been set up. Theme requires Shared Storage.
    // If not, run GenerateStorageService.runShared().
    bool value = await checkIfAlreadyRunWithReturn("shared_storage");
    if (!value) {
      var storageService = GenerateStorageService();
      await storageService.runShared();
    }

    bool alreadyBuilt = await checkIfAlreadyRunWithReturn("api");
    bool force = argResults?['force'] ?? false;
    bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating API Service...');
        await addAlreadyRun("api");
        addDependenciesToPubspecSync(['http'], null);
        String projectName = await getProjectName();
        await _addUserModel();
        await _addUserStateService();
        await _addConstants(projectName);
        await _addAPIService(projectName);
        await _addAuthService(projectName);
      },
      remove: () async {
        print('Removing API Service...');
        await removeAlreadyRun("api");
        removeDependenciesFromPubspecSync(['http'], null);
        await _removeAuthService();
        await _removeAPIService();
        await _removeConstants();
        await _removeUserStateService();
        await _removeUserModel();
      },
      rejectAdd: () async {
        print("Can't add API Service as it's already configured.");
      },
      rejectRemove: () async {
        print("Can't remove API Service as it's not yet configured.");
      },
    );
    formatCode();
    dartFixCode();
  }

  Future<void> _removeConstants() async {
    await File(path.join('lib', 'util', 'constants.dart')).delete();
  }

  Future<void> _removeAPIService() async {
    await File(path.join('lib', 'service', 'api_service.dart')).delete();
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

  Future<void> _addConstants(String projectName) async {
    await writeFileWithPrefix(path.join('lib', 'util', 'constants.dart'),
        constants.content(projectName));
  }

  Future<void> _addAPIService(String projectName) async {
    await writeFileWithPrefix(path.join('lib', 'service', 'api_service.dart'),
        api_service.content(projectName));
  }

  Future<void> _addAuthService(String projectName) async {
    await writeFileWithPrefix(path.join('lib', 'service', 'auth_service.dart'),
        auth_service.content(projectName));
  }

  Future<void> _addUserModel() async {
    await writeFileWithPrefix(
        path.join('lib', 'model', 'user.dart'), user_model.content());
  }

  Future<void> _addUserStateService() async {
    await writeFileWithPrefix(
        path.join('lib', 'service', 'user_state_service.dart'),
        user_state_service.content());
  }
}

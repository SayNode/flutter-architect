import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../../util/util.dart';
import '../storage/storage.dart';
import 'code/api_service.dart' as api_service;
import 'code/auth_service.dart' as auth_service;
import 'code/constants.dart' as constants;
import 'code/user_model.dart' as user_model;
import 'code/user_state_service.dart' as user_state_service;

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
    final bool value = await checkIfAlreadyRunWithReturn('shared_storage');
    if (!value) {
      final GenerateStorageService storageService = GenerateStorageService();
      await storageService.runShared();
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
        final String projectName = await getProjectName();
        await _addUserModel();
        await _addUserStateService();
        await _addConstants(projectName);
        await _addAPIService(projectName);
        await _addAuthService();
        await _addMainChanges(projectName);
      },
      remove: () async {
        stderr.writeln('Removing API Service...');
        await removeAlreadyRun('api');
        removeDependenciesFromPubspecSync(<String>['http'], null);
        await _removeAuthService();
        await _removeAPIService();
        await _removeConstants();
        await _removeUserStateService();
        await _removeUserModel();
        await _removeMainChanges();
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

  Future<void> _removeMainChanges() async {
    await removeLinesFromFile(
      path.join('lib', 'main.dart'),
      <String>['.devMode'],
    );
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

  Future<void> _addMainChanges(String projectName) async {
    await addLinesAfterLineInFile(
        path.join('lib', 'main.dart'), <String, List<String>>{
      'return GetMaterialApp(': <String>[
        'debugShowCheckedModeBanner: ${projectName.capitalize()}Constants.devMode,',
      ],
      '// https://saynode.ch': <String>[
        "import './util/constants.dart';",
      ],
    });
  }

  Future<void> _addConstants(String projectName) async {
    await writeFileWithPrefix(
      path.join('lib', 'util', 'constants.dart'),
      constants.content(projectName),
    );
  }

  Future<void> _addAPIService(String projectName) async {
    await writeFileWithPrefix(
      path.join('lib', 'service', 'api_service.dart'),
      api_service.content(projectName),
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

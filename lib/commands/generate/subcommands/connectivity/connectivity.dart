import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../../util/util.dart';
import '../storage/storage.dart';

class GenerateConnectivityService extends Command<dynamic> {
  GenerateConnectivityService() {
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
      'Create Connectivity Service related files and boilerplate code;';

  @override
  String get name => 'connectivity';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    // Check if Shared Storage has already been set up. Theme requires Shared Storage.
    // If not, run GenerateStorageService.runShared().
    final bool value = await checkIfAlreadyRunWithReturn('connectivity');
    if (!value) {
      final GenerateStorageService storageService = GenerateStorageService();
      await storageService.run();
    }

    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('connectivity');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        stderr.writeln('Creating Connectivity Service...');
        await addAlreadyRun('connectivity');
        addDependenciesToPubspecSync(<String>['connectivity_plus'], null);
        await _createConnectivityService();
      },
      remove: () async {
        stderr.writeln('Removing Connectivity Service...');
        await removeAlreadyRun('connectivity');
        removeDependenciesFromPubspecSync(<String>['connectivity_plus'], null);
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

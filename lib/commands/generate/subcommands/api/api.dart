import 'package:args/command_runner.dart';
import '../../../../util/util.dart';
import '../../../new/file_manipulators/constant_manipulator.dart';
import '../storage/storage.dart';
import 'file_manipulators/api_base_service_manipulator.dart';
import 'file_manipulators/api_service_manipulator.dart';
import 'file_manipulators/api_response_manipulator.dart';
import 'file_manipulators/auth_base_service_manipulator.dart';
import 'file_manipulators/auth_service_manipulator.dart';
import 'file_manipulators/user_base_service_manipulator.dart';
import 'file_manipulators/user_manipulator.dart';
import 'file_manipulators/user_service_manipulator.dart';

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
    await _run();
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
        printColor('-------- Creating API service --------\n', ColorText.cyan);
        await addAlreadyRun('api');
        addDependenciesToPubspecSync(<String>['http'], null);
        await UserManipulator().create();
        await UserBaseServiceManipulator().create();
        await UserServiceManipulator().create();
        await ApiBaseServiceManipulator().create();
        await ApiServiceManipulator().create();
        await AuthBaseServiceManipulator().create();
        await AuthServiceManipulator().create();
        await AuthResponseManipulator().create();
        printColor('Adding constants...', ColorText.white);
        await _addConstants();
        printColor('Constants added ✔', ColorText.green);
      },
      remove: () async {
        printColor('-------- Removing API service --------\n', ColorText.cyan);
        await removeAlreadyRun('api');
        removeDependenciesFromPubspecSync(<String>['http'], null);
        await UserManipulator().remove();
        await UserBaseServiceManipulator().remove();
        await UserServiceManipulator().remove();
        await ApiBaseServiceManipulator().remove();
        await ApiServiceManipulator().remove();
        await AuthBaseServiceManipulator().remove();
        await AuthServiceManipulator().remove();
        await AuthResponseManipulator().remove();
        printColor('Removing constants...', ColorText.white);
        await _removeConstants();
        printColor('Constants removed ✔', ColorText.green);
      },
      rejectAdd: () async {
        printColor(
          "Can't add API/Auth Service as it's already configured.\n",
          ColorText.red,
        );
      },
      rejectRemove: () async {
        printColor(
          "Can't remove API/Auth Service as it's not yet configured.\n",
          ColorText.red,
        );
      },
    );
  }

  Future<void> _addConstants() async {
    await ConstantManipulator().addConstant(
      "static const String apiDomain = const String.fromEnvironment('DATABASE_URL');",
    );
    await ConstantManipulator().addConstant(
      "static const String apiKey = const String.fromEnvironment('DATABASE_API_KEY');",
    );
    await ConstantManipulator().removeConstant(
      'devMode',
    );
    await ConstantManipulator().addConstant(
      "static bool get devMode => apiDomain.contains('dev-');",
    );
  }

  Future<void> _removeConstants() async {
    await ConstantManipulator().removeConstant(
      'apiDomain',
    );
    await ConstantManipulator().removeConstant(
      'apiKey',
    );
    await ConstantManipulator().removeConstant(
      'devMode',
    );
    await ConstantManipulator().addConstant(
      'static const bool devMode = true;',
    );
  }
}

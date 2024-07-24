import 'package:args/command_runner.dart';

import '../../../../util/util.dart';
import '../../../new/file_manipulators/main_file_manipulator.dart';
import 'file_manipulators/secure_storage/secure_storage_base_service_manipulator.dart';
import 'file_manipulators/secure_storage/secure_storage_service_manipulator.dart';
import 'file_manipulators/shared_storage/shared_storage_base_service_manipulator.dart';
import 'file_manipulators/shared_storage/shared_storage_service_manipulator.dart';
import 'file_manipulators/storage_base_service_manipulator.dart';
import 'file_manipulators/storage_exception_manipulator.dart';
import 'file_manipulators/storage_service_interface_manipulator.dart';
import 'file_manipulators/storage_service_manipulator.dart';

class GenerateStorageService extends Command<dynamic> {
  //-- Singleton
  GenerateStorageService() {
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
      'Create storage services for the project. Adds a StorageService with functions for a secure or shared option.;';

  @override
  String get name => 'storage';

  @override
  Future<void> run() async {
    await _run();
  }

  Future<void> _run() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('storage');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        printColor('------ Creating Storage service ------\n', ColorText.cyan);
        await addAlreadyRun('storage');
        addDependenciesToPubspecSync(
          <String>[
            'flutter_secure_storage',
            'shared_preferences',
          ],
          null,
        );
        await SecureStorageBaseServiceManipulator().create();
        await SharedStorageBaseServiceManipulator().create();
        await SecureStorageServiceManipulator().create();
        await SharedStorageServiceManipulator().create();
        await StorageBaseServiceManipulator().create();
        await StorageExceptionManipulator().create();
        await StorageServiceInterfaceManipulator().create();
        await StorageServiceManipulator().create();
        await MainFileManipulator().addStorageInitialization();
      },
      remove: () async {
        printColor('------ Removing Storage service ------\n', ColorText.cyan);
        await removeAlreadyRun('storage');
        removeDependenciesFromPubspecSync(
          <String>[
            'flutter_secure_storage',
            'shared_preferences',
          ],
          null,
        );
        await SecureStorageServiceManipulator().remove();
        await SharedStorageServiceManipulator().remove();
        await SecureStorageBaseServiceManipulator().remove();
        await SharedStorageBaseServiceManipulator().remove();
        await StorageBaseServiceManipulator().remove();
        await StorageExceptionManipulator().remove();
        await StorageServiceInterfaceManipulator().remove();
        await StorageServiceManipulator().remove();
        await MainFileManipulator().removeStorageInitialization();
      },
      rejectAdd: () async {
        printColor(
          "Can't add Storage as it's already configured.\n",
          ColorText.red,
        );
      },
      rejectRemove: () async {
        printColor(
          "Can't remove Storage as it's not yet configured.\n",
          ColorText.red,
        );
      },
    );
  }
}

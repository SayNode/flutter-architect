import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'code/secure_storage_service.dart'
    as secure_storage;
import 'code/storage_service.dart'
    as shared_storage;
import '../../../util.dart';

class GenerateStorageService extends Command {
  //-- Singleton
  GenerateStorageService() {
    // Add parser options or flag here
    argParser.addFlag('secure', help: 'Create secure storage service.');
    argParser.addFlag('shared', help: 'Create shared storage service.');
    argParser.addFlag('force', help: 'Force replace in case it already exists.',);
    argParser.addFlag('remove', help: 'Remove in case it already exists.',);
  }

  @override
  String get description =>
      'Create storage services for the project. --secure flag will create secure storage service. --shared flag will create shared storage service;';

  @override
  String get name => 'storage';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    if (argResults?['secure'] || argResults?['shared']) {
      if (argResults?['secure'] == true) {
        await runSecure();
      }
      if (argResults?['shared'] == true) {
        await runShared();
      }
    } else {
      print(
          'Please specify which storage service you want to create. Use --help for more info.',);
    }
  }

  Future<void> runSecure() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('secure_storage');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Secure Storage service...');
        await addAlreadyRun('secure_storage');
        addDependenciesToPubspecSync(<String>['flutter_secure_storage'], null);
        await _addSecureStorageService();
      },
      remove: () async {
        print('Removing Secure Storage service...');
        await removeAlreadyRun('secure_storage');
        removeDependenciesFromPubspecSync(<String>['flutter_secure_storage'], null);
        await _removeSecureStorageService();
      },
      rejectAdd: () async {
        print("Can't add Secure Storage as it's already configured.");
      },
      rejectRemove: () async {
        print("Can't remove Secure Storage as it's not yet configured.");
      },
    );
    formatCode();
    dartFixCode();
  }

  Future<void> runShared() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('shared_storage');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Shared Storage service...');
        addDependenciesToPubspecSync(<String>['shared_preferences'], null);
        await addAlreadyRun('shared_storage');
        await _addSharedStorageService();
        await _addMainChanges();
      },
      remove: () async {
        print('Removing Shared Storage service...');
        removeDependenciesFromPubspecSync(<String>['shared_preferences'], null);
        await removeAlreadyRun('shared_storage');
        await _removeSharedStorageService();
        await _removeMainChanges();
      },
      rejectAdd: () async {
        print("Can't add Shared Storage as it's already configured.");
      },
      rejectRemove: () async {
        print("Can't remove Shared Storage as it's not yet configured.");
      },
    );
    formatCode();
    dartFixCode();
  }

  // Remove the Storage-related lines from main.
  Future<void> _removeMainChanges() async {
    final String mainPath = path.join('lib', 'main.dart');
    await removeLinesFromFile(mainPath, <String>[
      "import 'service/storage_service.dart';",
      'final StorageService storage = Get.put<StorageService>(StorageService());',
      'await storage.init();',
    ]);
  }

  Future<void> _addMainChanges() async {
    final String mainPath = path.join('lib', 'main.dart');
    await addLinesAfterLineInFile(
      mainPath,
      <String, List<String>>{
        'WidgetsFlutterBinding.ensureInitialized();': <String>[
          'final StorageService storage = Get.put<StorageService>(StorageService());',
          'await storage.init();',
        ],
        '// https://saynode.ch': <String>["import 'service/storage_service.dart';"],
      },
    );
  }

  Future<void> _removeSharedStorageService() async {
    await File(path.join('lib', 'service', 'storage_service.dart')).delete();
  }

  Future<void> _removeSecureStorageService() async {
    await File(path.join('lib', 'service', 'secure_storage_service.dart'))
        .delete();
  }

  Future<void> _addSharedStorageService() async {
    await writeFileWithPrefix(
        path.join('lib', 'service', 'storage_service.dart'),
        shared_storage.content(),);
  }

  Future<void> _addSecureStorageService() async {
    await writeFileWithPrefix(
        path.join('lib', 'service', 'secure_storage_service.dart'),
        secure_storage.content(),);
  }
}

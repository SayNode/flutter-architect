import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../../util/util.dart';
import 'code/storage_exception.dart' as storage_exception;
import 'code/storage_service_interface.dart' as storage_service_interface;
import 'code/secure_storage_service.dart' as secure_storage_service;
import 'code/shared_storage_service.dart' as shared_storage_service;
import 'code/storage_service.dart' as storage_service;

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
      'Create storage services for the project. Adds a StorageService with the option to use Secure or Shared device storage.;';

  @override
  String get name => 'storage';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
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
        stderr.writeln('Creating Storage service...');
        await addAlreadyRun('storage');
        addDependenciesToPubspecSync(<String>['flutter_secure_storage'], null);
        addDependenciesToPubspecSync(<String>['shared_preferences'], null);
        await _addStorageService();
        await _addMainChanges();
      },
      remove: () async {
        stderr.writeln('Removing Storage service...');
        await removeAlreadyRun('storage');
        removeDependenciesFromPubspecSync(
          <String>['flutter_secure_storage'],
          null,
        );
        removeDependenciesFromPubspecSync(
          <String>['shared_preferences'],
          null,
        );
        await _removeStorageService();
        await _removeMainChanges();
      },
      rejectAdd: () async {
        stderr.writeln("Can't add Storage as it's already configured.");
      },
      rejectRemove: () async {
        stderr.writeln("Can't remove Storage as it's not yet configured.");
      },
    );
    formatCode();
    dartFixCode();
  }

  // Remove the Storage-related lines from main.
  Future<void> _removeMainChanges() async {
    final String mainPath = path.join('lib', 'main.dart');
    await removeLinesFromFile(mainPath, <String>[
      "import 'service/storage/storage_service.dart';",
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
        '// https://saynode.ch': <String>[
          "import 'service/storage/storage_service.dart';",
        ],
      },
    );
  }

  Future<void> _removeStorageService() async {
    await File(path.join('lib', 'service', 'storage', 'storage_exception.dart'))
        .delete();
    await File(
      path.join(
        'lib',
        'service',
        'storage',
        'storage_service_interface.dart',
      ),
    ).delete();
    await File(
      path.join(
        'lib',
        'service',
        'storage',
        'shared_storage_service.dart',
      ),
    ).delete();
    await File(
      path.join(
        'lib',
        'service',
        'storage',
        'secure_storage_service.dart',
      ),
    ).delete();
    await File(path.join('lib', 'service', 'storage', 'storage_service.dart'))
        .delete();
    await Directory(path.join('lib', 'service', 'storage')).delete();
  }

  Future<void> _addStorageService() async {
    await Directory(path.join('lib', 'service', 'storage')).create();
    await writeFileWithPrefix(
      path.join('lib', 'service', 'storage', 'storage_exception.dart'),
      storage_exception.content(),
    );

    await writeFileWithPrefix(
      path.join('lib', 'service', 'storage', 'storage_service_interface.dart'),
      storage_service_interface.content(),
    );

    await writeFileWithPrefix(
      path.join('lib', 'service', 'storage', 'shared_storage_service.dart'),
      shared_storage_service.content(),
    );

    await writeFileWithPrefix(
      path.join('lib', 'service', 'storage', 'secure_storage_service.dart'),
      secure_storage_service.content(),
    );

    await writeFileWithPrefix(
      path.join('lib', 'service', 'storage', 'storage_service.dart'),
      storage_service.content(),
    );
  }

  Future<void> _injectServices() async {
    await addLinesAfterLineInFile(
      path.join('lib', 'service', 'service.dart'),
      <String, List<String>>{
        '//Services injection': <String>[
          'Get.lazyPut(StorageService.new);',
          'Get.lazyPut(SharedStorageService.new);',
          'Get.lazyPut(SecureStorageService.new);',
        ],
        "import 'package:get/get.dart';": <String>[
          "import 'storage/secure_storage_service.dart';",
          "import 'storage/shared_storage_service.dart';",
          "import 'storage/storage_service.dart';",
        ],
      },
    );
  }
}

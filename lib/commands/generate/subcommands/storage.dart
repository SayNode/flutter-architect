import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/generate/subcommands/files/storage_service.dart'
    as shared_storage;
import 'package:project_initialization_tool/commands/util.dart';

import 'files/secure_storage_service.dart' as secure_storage;

class GenerateStorageService extends Command {
  //-- Singleton
  GenerateStorageService() {
    // Add parser options or flag here
    argParser.addFlag('secure', help: 'Create secure storage service.');
    argParser.addFlag('shared', help: 'Create shared storage service.');
    argParser.addFlag('force',
        defaultsTo: false, help: 'Force replace in case it already exists.');
  }

  @override
  String get description =>
      'Create storage services for the project. --secure flag will create secure storage service. --shared flag will create shared storage service.';

  @override
  String get name => 'storage';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    if (argResults?['secure'] == true) {
      await runSecure();
    }
    if (argResults?['shared'] == true) {
      await runShared();
    }
  }

  Future<void> runSecure() async {
    bool value = await checkIfAlreadyRunWithReturn("secure_storage");
    bool force = argResults?['force'] ?? false;
    if (value && force) {
      print('Replacing secure storage service...');
      removeDependencyFromPubspecSync('flutter_secure_storage', null);
      addDependencyToPubspecSync('flutter_secure_storage', null);
      await _removeSecureStorageService();
      await _addSecureStorageService();
    } else if (!value) {
      print('Creating secure storage service...');
      await addDependencyToPubspec('flutter_secure_storage', null);
      await addAlreadyRun('secure_storage');
      await _addSecureStorageService();
    } else {
      print('Secure storage service already exists.');
      exit(0);
    }
  }

  Future<void> runShared() async {
    bool value = await checkIfAlreadyRunWithReturn("shared_storage");
    bool force = argResults?['force'] ?? false;
    if (value && force) {
      print('Replacing shared storage service...');
      removeDependencyFromPubspecSync('shared_preferences', null);
      addDependencyToPubspecSync('shared_preferences', null);
      await _removeSharedStorageService();
      await _removeMainLines();
      await _addSharedStorageService();
      await _modifyMain();
    } else if (!value) {
      print('Creating shared storage service...');
      await addDependencyToPubspec('shared_preferences', null);
      await addAlreadyRun('shared_storage');
      await _addSharedStorageService();
      await _modifyMain();
    } else {
      print('Shared storage service already exists.');
      exit(0);
    }
    await formatCode();
    await dartFixCode();
  }

  // Remove the Storage-related lines from main.
  Future<void> _removeMainLines() async {
    String mainPath = path.join('lib', 'main.dart');
    List<String> lines = await File(mainPath).readAsLines();
    String mainContent = '';

    for (String line in lines) {
      if (!line.contains("import 'service/storage_service.dart';") &&
          !line.contains(
              'final StorageService storage = Get.put<StorageService>(StorageService());') &&
          !line.contains("await storage.init();")) {
        mainContent += '$line\n';
      }
    }
    await File(mainPath).writeAsString(mainContent).then((file) {
      print('- Remove StorageService from main ✔');
    });
  }

  Future<void> _modifyMain() async {
    String mainPath = path.join('lib', 'main.dart');
    List<String> lines = await File(mainPath).readAsLines();
    String mainContent = '';
    mainContent += "import 'service/storage_service.dart';\n";
    for (String line in lines) {
      mainContent += '$line\n';
      if (line.contains('WidgetsFlutterBinding.ensureInitialized();')) {
        mainContent +=
            "final StorageService storage = Get.put<StorageService>(StorageService());\nawait storage.init();\n";
      }
    }
    await File(mainPath).writeAsString(mainContent).then((file) {
      print('- inject StorageService in memory and initialize it ✔');
    });
  }

  Future<void> _removeSharedStorageService() async {
    await File(path.join('lib', 'service', 'storage_service.dart')).delete();
  }

  Future<void> _removeSecureStorageService() async {
    await File(path.join('lib', 'service', 'secure_storage_service.dart'))
        .delete();
  }

  Future<void> _addSharedStorageService() async {
    File(path.join('lib', 'service', 'storage_service.dart'))
        .writeAsString(shared_storage.content());
  }

  Future<void> _addSecureStorageService() async {
    File(path.join('lib', 'service', 'secure_storage_service.dart'))
        .writeAsString(secure_storage.content());
  }
}

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
  }

  @override
  String get description =>
      'Create storage services for the project. --secure flag will create secure storage service. --shared flag will create shared storage service.';

  @override
  String get name => 'storage';

  @override
  void run() async {
    spinnerLoading(_run);
  }

  _run() async {
    if (argResults?['secure'] == true) {
      await runSecure();
    }
    if (argResults?['shared'] == true) {
      await runShared();
    }
  }

  runSecure() async {
    checkIfAllreadyRun("secure_storage").then((value) async {
      print('Creating secure storage service...');
      addDependencyToPubspec('flutter_secure_storage', null);
      await addAllreadyRun('secure_storage');
      await _addSecureStorageService();
    });
  }

  runShared() async {
    checkIfAllreadyRun("shared_storage").then((value) async {
      print('Creating shared storage service...');
      addDependencyToPubspec('shared_preferences', null);
      await addAllreadyRun('shared_storage');
      await _addStorageService();
      await _modifyMain();
    });
  }

  _modifyMain() async {
    String mainPath = path.join('lib', 'main.dart');
    File(mainPath).readAsLines().then((List<String> lines) {
      String mainContent = '';
      mainContent += "import 'service/storage_service.dart';\n";
      for (String line in lines) {
        mainContent += '$line\n';
        if (line.contains('void main() async {')) {
          mainContent +=
              "final StorageService storage = Get.put<StorageService>(StorageService());\nawait storage.init();\n";
        }
      }

      File(mainPath).writeAsString(mainContent).then((file) {
        print('- inject StorageService in memory and initialize it ✔');
      });
    });
  }

  _addStorageService() async {
    File(path.join('lib', 'service', 'storage_service.dart'))
        .writeAsString(shared_storage.content());
  }

  _addSecureStorageService() async {
    File(path.join('lib', 'service', 'secure_storage_service.dart'))
        .writeAsString(secure_storage.content());
  }
}

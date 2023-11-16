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
    if (argResults?['secure'] == true) {
      checkIfAllreadyRun("secure_storage").then((value) async {
        print('Creating secure storage service...');
        addDependencyToPubspec('flutter_secure_storage', null);
        await addAllreadyRun('secure_storage');
        await _addSecureStorageService();
      });
    }
    if (argResults?['shared'] == true) {
      checkIfAllreadyRun("shared_storage").then((value) async {
        print('Creating shared storage service...');
        addDependencyToPubspec('shared_preferences', null);
        await addAllreadyRun('shared_storage');
        await _addStorageService();
      });
    }
  }

  _addStorageService() async {
    File(path.join('lib', 'service', 'storage_service.dart'))
        .writeAsString(shared_storage.content());
  }

  _addSecureStorageService() async {
    File(path.join('lib', 'service', 'secure_storage_service.dart'))
        .writeAsString(secure_storage.content());
  }

  Future<void> addAllreadyRun(String service) async {
    await File('added_boilerplate.txt')
        .writeAsString('$service\n', mode: FileMode.append);
  }

  Future<void> checkIfAllreadyRun(String service) async {
    await File('added_boilerplate.txt')
        .readAsLines()
        .then((List<String> lines) {
      for (var line in lines) {
        if (line.contains(service)) {
          print('$service already added');
          exit(0);
        }
      }
    });
  }
}

import 'package:args/command_runner.dart';
import 'package:project_initialization_tool/commands/util.dart';

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
      print('Creating secure storage service...');
      addDependencyToPubspec('flutter_secure_storage', null);
    }
    if (argResults?['shared'] == true) {
      print('Creating shared storage service...');
      addDependencyToPubspec('shared_preferences', null);
    }
  }
}

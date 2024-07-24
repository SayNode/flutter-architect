import 'package:args/command_runner.dart';
import '../../../../util/util.dart';
import 'file_manipulators/connectivity_base_service_manipulator.dart';
import 'file_manipulators/connectivity_service_manipulator.dart';
import 'file_manipulators/lost_connection_page_manipulator.dart';

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
    await _run();
  }

  Future<void> _run() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('connectivity');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        printColor('---- Creating Connectivity Service ----\n', ColorText.cyan);
        await addAlreadyRun('connectivity');
        addDependenciesToPubspecSync(<String>['connectivity_plus'], null);
        await ConnectivityBaseServiceManipulator().create();
        await ConnectivityServiceManipulator().create();
        await LostConnectionPageManipulator().create();
      },
      remove: () async {
        printColor('---- Removing Connectivity Service ----\n', ColorText.cyan);
        await removeAlreadyRun('connectivity');
        removeDependenciesFromPubspecSync(<String>['connectivity_plus'], null);
        await LostConnectionPageManipulator().remove();
        await ConnectivityBaseServiceManipulator().remove();
        await ConnectivityServiceManipulator().remove();
      },
      rejectAdd: () async {
        printColor(
          "Can't add Connectivity Service as it's already configured.\n",
          ColorText.red,
        );
      },
      rejectRemove: () async {
        printColor(
          "Can't remove Connectivity Service as it's not yet configured.\n",
          ColorText.red,
        );
      },
    );
  }
}

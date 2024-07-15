import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../../util/util.dart';
import 'code/lost_connection.dart' as lost_connection;
import 'connectivity_service_manipulator.dart';

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
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('connectivity');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    final ConnectivityServiceManipulator connectivityServiceFileManipulator =
        ConnectivityServiceManipulator();
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        stderr.writeln('Creating Connectivity Service...');
        await addAlreadyRun('connectivity');
        await connectivityServiceFileManipulator.create(initialize: true);
        await _createLostConnectionPage();
      },
      remove: () async {
        stderr.writeln('Removing Connectivity Service...');
        await removeAlreadyRun('connectivity');

        await _removeLostConnectionPage();
        await connectivityServiceFileManipulator.remove();
      },
      rejectAdd: () async {
        stderr.writeln("Can't add API Service as it's already configured.");
      },
      rejectRemove: () async {
        stderr.writeln("Can't remove API Service as it's not yet configured.");
      },
    );
    dartFormatCode();
    dartFixCode();
  }

  Future<void> _createLostConnectionPage() async {
    Directory(path.join('lib', 'page', 'lost_connection')).createSync();
    await File(
      path.join(
        'lib',
        'page',
        'lost_connection',
        'lost_connection_page.dart',
      ),
    ).writeAsString(lost_connection.content());
  }

  Future<void> _removeLostConnectionPage() async {
    Directory(path.join('lib', 'page', 'lost_connection'))
        .deleteSync(recursive: true);
  }
}

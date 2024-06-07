import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../../util/util.dart';
import '../storage/storage.dart';
import 'code/splash.dart' as splash;
import 'code/connectivity_service.dart' as connectivity_service;

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
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        stderr.writeln('Creating Connectivity Service...');
        await addAlreadyRun('connectivity');
        addDependenciesToPubspecSync(<String>['connectivity_plus'], null);
        await _createConnectivityService();
        await _addSplashChanges();
      },
      remove: () async {
        stderr.writeln('Removing Connectivity Service...');
        await removeAlreadyRun('connectivity');
        removeDependenciesFromPubspecSync(<String>['connectivity_plus'], null);
        await _removeSplashChanges();
        await _removeConnectivityService();
      },
      rejectAdd: () async {
        stderr.writeln("Can't add API Service as it's already configured.");
      },
      rejectRemove: () async {
        stderr.writeln("Can't remove API Service as it's not yet configured.");
      },
    );
    formatCode();
    dartFixCode();
  }

  Future<void> _removeSplashChanges() async {
    await removeTextFromFile(
      path.join('lib', 'page', 'splash_page.dart'),
      splash.import(),
    );
    await removeTextFromFile(
      path.join('lib', 'page', 'splash_page.dart'),
      splash.content(),
    );
    await addLinesAfterLineInFile(
      path.join('lib', 'page', 'splash_page.dart'),
      <String, List<String>>{
        'Widget build(BuildContext context) {': <String>[
          'return CustomScaffold(body:Container());',
        ],
      },
    );
  }

  Future<void> _addSplashChanges() async {
    await removeLinesFromFile(
      path.join('lib', 'page', 'splash_page.dart'),
      <String>[
        'return CustomScaffold(body:Container());',
      ],
    );
    await addLinesAfterLineInFile(
      path.join('lib', 'page', 'splash_page.dart'),
      <String, List<String>>{
        'Widget build(BuildContext context) {': <String>[
          splash.content(),
        ],
        '// https://saynode.ch': <String>[
          splash.import(),
        ],
      },
    );
  }

  Future<void> _createConnectivityService() async {
    await writeFileWithPrefix(
      path.join('lib', 'service', 'connectivity_service.dart'),
      connectivity_service.content(),
    );
  }

  Future<void> _removeConnectivityService() async {
    await File(
      path.join('lib', 'service', 'connectivity_service.dart'),
    ).delete();
  }

  Future<void> _injectServices() async {
    await addLinesAfterLineInFile(
      path.join('lib', 'service', 'main_bindings.dart'),
      <String, List<String>>{
        '//Services injection': <String>[
          'Get.lazyPut(ConnectivityService.new);',
        ],
        "import 'package:get/get.dart';": <String>[
          "import 'connectivity_service.dart';",
        ],
      },
    );
  }

  Future<void> _uninjectServices() async {
    await removeLinesFromFile(
      path.join('lib', 'service', 'main_bindings.dart'),
      <String>[
        'Get.lazyPut(ConnectivityService.new);',
        "import 'connectivity_service.dart';",
      ],
    );
  }
}

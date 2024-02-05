import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'code/error_controller.dart'
    as error_controller;
import 'code/error_page.dart'
    as error_page;
import 'code/firebase_configuration.dart'
    as firebase_configuration;
import 'code/lost_connection_page.dart'
    as lost_connection_page;
import 'code/main/handle_error.dart'
    as handle_error;
import 'code/main/imports.dart'
    as imports;
import 'code/main/material_app_flag.dart'
    as material_app_flag;
import 'code/main/restart_widget.dart'
    as restart_widget;
import 'code/main/wrapper.dart'
    as wrapper;
import 'code/network_service.dart'
    as network_service;
import 'code/util.dart'
    as util;
import '../../../util.dart';

class GenerateCrashalyticsService extends Command {

  GenerateCrashalyticsService() {
    // Add parser options or flag here
    argParser.addFlag('force', help: 'Force replace in case it already exists.',);
    argParser.addFlag('remove', help: 'Remove in case it already exists.',);
  }
  @override
  String get description => 'Create crashalytics files and boilerplate code;';

  @override
  String get name => 'crashalytics';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('crashalytics');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    final String projectName = await getProjectName();
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Crashalytics...');
        await addAlreadyRun('crashalytics');
        _printInitialInstructions();
        _addDependencies();
        _createDirectories();
        await _addErrorPage(projectName);
        await _addErrorController();
        await _addUtil();
        await _addNetworkService(projectName);
        await _addLostConnectionPage();
        await _addFirebaseConfigurationScript();
        await _addMainChanges();
        formatCode();
        dartFixCode();
        _printFinalInstructions();
      },
      remove: () async {
        print('Removing Crashalytics...');
        await removeAlreadyRun('crashalytics');
        _removeDependencies();
        await _removeErrorPage();
        await _removeErrorController();
        await _removeUtil();
        await _removeNetworkService();
        await _removeLostConnectionPage();
        await _removeFirebaseConfigurationScript();
        await _removeMainChanges();
        formatCode();
        dartFixCode();
      },
      rejectAdd: () async {
        print("Can't add Crashalytics as it's already configured.");
      },
      rejectRemove: () async {
        print("Can't remove Crashalytics as it's not yet configured.");
      },
    );
  }

  void _addDependencies() {
    addDependenciesToPubspecSync(<String>[
      'firebase_core',
      'firebase_crashlytics',
      'connectivity_plus',
      'package_info_plus',
      'flutter_svg',
      'is_first_run',
      'url_launcher',
      'flutter_network_connectivity',
    ], null,);
  }

  void _removeDependencies() {
    removeDependenciesFromPubspecSync(<String>[
      'firebase_core',
      'firebase_crashlytics',
      'connectivity_plus',
      'package_info_plus',
      'flutter_svg',
      'is_first_run',
      'url_launcher',
      'flutter_network_connectivity',
    ], null,);
  }

  void _printInitialInstructions() {
    printColor(
      'This script will add the code required to catch errors and send them to crashalytics.',
      ColorText.yellow,
    );
    printColor(
      'However, to use this feature, you need to first configure firebase and crashalytics for this project.',
      ColorText.yellow,
    );
    printColor(
      'You can do this with the following commands:',
      ColorText.yellow,
    );
    printColor(
      'chmod +x ./firebase_configuration.sh',
      ColorText.magenta,
    );
    printColor(
      './firebase_configuration.sh',
      ColorText.magenta,
    );
    printColor(
      'You can follow the official guide for flutter at https://firebase.google.com/docs/crashlytics/get-started?platform=flutter',
      ColorText.yellow,
    );
  }

  void _printFinalInstructions() {
    printColor(
        'Added following dependencies: firebase_core, firebase_crashalitics, connectivity_plus, package_info_plus, flutter_svg, is_first_run',
        ColorText.green,);
    printColor('REMEMBER TO RUN', ColorText.green);
    printColor('chmod +x ./firebase_configuration.sh', ColorText.magenta);
    printColor('./firebase_configuration.sh', ColorText.magenta);
  }

  /// Create required directories, if they don't exist.
  void _createDirectories() {
    Directory(path.join('lib', 'util')).createSync();
    Directory(path.join('lib', 'page', 'error')).createSync();
    Directory(path.join('lib', 'page', 'lost_connection')).createSync();
    Directory(path.join('lib', 'page', 'error', 'controller')).createSync();
  }

  Future<void> _addMainChanges() async {
    final String mainPath = path.join('lib', 'main.dart');

    await addLinesAfterLineInFile(
      mainPath,
      <String, List<String>>{
        'void main() async {': <String>[
          wrapper.contentBefore(),
        ],
        'runApp(const MyApp());': <String>[
          wrapper.contentAfter(),
        ],
        'Widget build(BuildContext context) {': <String>[
          material_app_flag.content(),
        ],
        'bool isFirstRun = false;': <String>[
          restart_widget.content(),
          handle_error.content(),
        ],
        '// https://saynode.ch': <String>[
          imports.content(),
        ],
      },
    );
  }

  Future<void> _removeMainChanges() async {
    final String mainPath = path.join('lib', 'main.dart');
    await removeTextFromFile(mainPath, imports.content());
    await removeTextFromFile(mainPath, wrapper.contentBefore());
    await removeTextFromFile(mainPath, wrapper.contentAfter());
    await removeTextFromFile(mainPath, material_app_flag.content());
    await removeTextFromFile(mainPath, restart_widget.content());
    await removeTextFromFile(mainPath, handle_error.content());
  }

  Future<void> _addErrorPage(String projectName) async {
    await writeFileWithPrefix(
        path.join('lib', 'page', 'error', 'error_page.dart'),
        error_page.content(projectName),);
  }

  Future<void> _addErrorController() async {
    await writeFileWithPrefix(
        path.join(
            'lib', 'page', 'error', 'controller', 'error_controller.dart',),
        error_controller.content(),);
  }

  Future<void> _addUtil() async {
    await writeFileWithPrefix(
        path.join('lib', 'util', 'util.dart'), util.content(),);
  }

  Future<void> _addNetworkService(String projectName) async {
    await writeFileWithPrefix(
        path.join('lib', 'service', 'network_service.dart'),
        network_service.content(projectName),);
  }

  Future<void> _addLostConnectionPage() async {
    await writeFileWithPrefix(
        path.join(
            'lib', 'page', 'lost_connection', 'lost_connection_page.dart',),
        lost_connection_page.content(),);
  }

  Future<void> _addFirebaseConfigurationScript() async {
    await File(path.join('firebase_configuration.sh'))
        .writeAsString(firebase_configuration.content());
  }

  Future<void> _removeErrorPage() async {
    await File(path.join('lib', 'page', 'error', 'error_page.dart')).delete();
  }

  Future<void> _removeErrorController() async {
    await File(path.join(
            'lib', 'page', 'error', 'controller', 'error_controller.dart',),)
        .delete();
  }

  Future<void> _removeUtil() async {
    await File(path.join('lib', 'util', 'util.dart')).delete();
  }

  Future<void> _removeNetworkService() async {
    await File(path.join('lib', 'service', 'network_service.dart')).delete();
  }

  Future<void> _removeLostConnectionPage() async {
    await File(path.join(
            'lib', 'page', 'lost_connection', 'lost_connection_page.dart',),)
        .delete();
  }

  Future<void> _removeFirebaseConfigurationScript() async {
    await File(path.join('firebase_configuration.sh')).delete();
  }
}

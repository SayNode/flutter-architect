import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics/code/error_controller.dart'
    as error_controller;
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics/code/error_page.dart'
    as error_page;
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics/code/firebase_configuration.dart'
    as firebase_configuration;
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics/code/lost_connection_page.dart'
    as lost_connection_page;
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics/code/network_service.dart'
    as network_service;
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics/code/util.dart'
    as util;
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics/code/main/handle_error.dart'
    as handle_error;
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics/code/main/wrapper.dart'
    as wrapper;
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics/code/main/imports.dart'
    as imports;
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics/code/main/restart_widget.dart'
    as restart_widget;
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics/code/main/material_app_flag.dart'
    as material_app_flag;
import 'package:project_initialization_tool/commands/util.dart';

class GenerateCrashalyticsService extends Command {
  @override
  String get description => 'Create crashalytics files and boilerplate code;';

  @override
  String get name => 'crashalytics';

  GenerateCrashalyticsService() {
    // Add parser options or flag here
    argParser.addFlag('force',
        defaultsTo: false, help: 'Force replace in case it already exists.');
    argParser.addFlag('remove',
        defaultsTo: false, help: 'Remove in case it already exists.');
  }

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    bool alreadyBuilt = await checkIfAlreadyRunWithReturn("crashalytics");
    bool force = argResults?['force'] ?? false;
    bool remove = argResults?['remove'] ?? false;
    String projectName = await getProjectName();
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Crashalytics...');
        addAlreadyRun('crashalytics');
        _printInitialInstructions();
        _addDependencies();
        _createDirectories();
        _addErrorPage(projectName);
        _addErrorController();
        _addUtil();
        _addNetworkService(projectName);
        _addLostConnectionPage();
        _addFirebaseConfigurationScript();
        _addMainChanges();
        formatCode();
        dartFixCode();
        _printFinalInstructions();
      },
      remove: () async {
        print('Removing Crashalytics...');
        removeAlreadyRun('crashalytics');
        _removeDependencies();
        _removeErrorPage();
        _removeErrorController();
        _removeUtil();
        _removeNetworkService();
        _removeLostConnectionPage();
        _removeFirebaseConfigurationScript();
        _removeMainChanges();
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
    addDependenciesToPubspecSync([
      'firebase_core',
      'firebase_crashlytics',
      'connectivity_plus',
      'package_info_plus',
      'flutter_svg',
      'is_first_run',
      'url_launcher',
      'flutter_network_connectivity',
    ], null);
  }

  void _removeDependencies() {
    removeDependenciesFromPubspecSync([
      'firebase_core',
      'firebase_crashlytics',
      'connectivity_plus',
      'package_info_plus',
      'flutter_svg',
      'is_first_run',
      'url_launcher',
      'flutter_network_connectivity',
    ], null);
  }

  void _printInitialInstructions() {
    printColor(
      "This script will add the code required to catch errors and send them to crashalytics.",
      ColorText.yellow,
    );
    printColor(
      "However, to use this feature, you need to first configure firebase and crashalytics for this project.",
      ColorText.yellow,
    );
    printColor(
      "You can do this with the following commands:",
      ColorText.yellow,
    );
    printColor(
      "chmod +x ./firebase_configuration.sh",
      ColorText.magenta,
    );
    printColor(
      "./firebase_configuration.sh",
      ColorText.magenta,
    );
    printColor(
      "You can follow the official guide for flutter at https://firebase.google.com/docs/crashlytics/get-started?platform=flutter",
      ColorText.yellow,
    );
  }

  void _printFinalInstructions() {
    printColor(
        "Added following dependencies: firebase_core, firebase_crashalitics, connectivity_plus, package_info_plus, flutter_svg, is_first_run",
        ColorText.green);
    printColor("REMEMBER TO RUN", ColorText.green);
    printColor("chmod +x ./firebase_configuration.sh", ColorText.magenta);
    printColor("./firebase_configuration.sh", ColorText.magenta);
  }

  /// Create required directories, if they don't exist.
  void _createDirectories() {
    Directory(path.join('lib', 'util')).createSync();
    Directory(path.join('lib', 'page', 'error')).createSync();
    Directory(path.join('lib', 'page', 'lost_connection')).createSync();
    Directory(path.join('lib', 'page', 'error', 'controller')).createSync();
  }

  Future<void> _addMainChanges() async {
    String mainPath = path.join('lib', 'main.dart');

    await addLinesAfterLineInFile(
      mainPath,
      {
        'void main() async {': [
          wrapper.contentBefore(),
        ],
        'runApp(const MyApp());': [
          wrapper.contentAfter(),
        ],
        'Widget build(BuildContext context) {': [
          material_app_flag.content(),
        ],
        'bool isFirstRun = false;': [
          restart_widget.content(),
          handle_error.content(),
        ]
      },
      leading: [
        imports.content(),
      ],
    );
  }

  Future<void> _removeMainChanges() async {
    String mainPath = path.join('lib', 'main.dart');
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
        error_page.content(projectName));
  }

  Future<void> _addErrorController() async {
    await writeFileWithPrefix(
        path.join(
            'lib', 'page', 'error', 'controller', 'error_controller.dart'),
        error_controller.content());
  }

  Future<void> _addUtil() async {
    await writeFileWithPrefix(
        path.join('lib', 'util', 'util.dart'), util.content());
  }

  Future<void> _addNetworkService(String projectName) async {
    await writeFileWithPrefix(
        path.join('lib', 'service', 'network_service.dart'),
        network_service.content(projectName));
  }

  Future<void> _addLostConnectionPage() async {
    await writeFileWithPrefix(
        path.join(
            'lib', 'page', 'lost_connection', 'lost_connection_page.dart'),
        lost_connection_page.content());
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
            'lib', 'page', 'error', 'controller', 'error_controller.dart'))
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
            'lib', 'page', 'lost_connection', 'lost_connection_page.dart'))
        .delete();
  }

  Future<void> _removeFirebaseConfigurationScript() async {
    await File(path.join('firebase_configuration.sh')).delete();
  }
}

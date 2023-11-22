import 'package:args/command_runner.dart';
import 'package:project_initialization_tool/commands/util.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/files/error_page.dart'
    as error_page;
import 'package:project_initialization_tool/commands/generate/subcommands/files/error_controller.dart'
    as error_controller;
import 'package:project_initialization_tool/commands/generate/subcommands/files/util.dart'
    as util;
import 'package:project_initialization_tool/commands/generate/subcommands/files/network_service.dart'
    as network_service;
import 'package:project_initialization_tool/commands/generate/subcommands/files/lost_connection_page.dart'
    as lost_connection_page;
import 'package:project_initialization_tool/commands/generate/subcommands/files/firebase_configuration.dart'
    as firebase_configuration;
import 'dart:io';
import 'package:path/path.dart' as path;

class CrashalyticsGenerator extends Command {
  @override
  String get description => 'Create crashalytics files and boilerplate code;';

  @override
  String get name => 'crashalytics';

  @override
  void run() async {
    checkIfAllreadyRun('localization').then((value) async {
      await spinnerLoading(addCrashalyticsTasks);
    });
  }

  addCrashalyticsTasks() async {
    printColor(
        "This script will add the code required to catch errors and send them to crashalytics",
        ColorText.yellow);
    printColor(
        "However, to use this feature, you need to first configure firebase and crashalytics for this project",
        ColorText.yellow);
    printColor(
        "You can do this with the following commands:", ColorText.yellow);
    printColor("chmod +x ./firebase_configuration.sh", ColorText.magenta);
    printColor("./firebase_configuration.sh", ColorText.magenta);
    printColor(
        "if that does work you can follow the official guide for flutter at https://firebase.google.com/docs/crashlytics/get-started?platform=flutter",
        ColorText.yellow);

    String projectName = await getProjectName();
    print("current project name $projectName");

    checkIfAllreadyRun("crashalytics").then((value) async {
      print('Creating crashalitics configuration in main.dart...');
      await addDependencyToPubspecSync('firebase_core', null);
      await addDependencyToPubspecSync('firebase_crashlytics', null);
      await addDependencyToPubspecSync('connectivity_plus', null);
      await addDependencyToPubspecSync('package_info_plus', null);
      await addDependencyToPubspecSync('flutter_svg', null);
      await addDependencyToPubspecSync('is_first_run', null);
      await addDependencyToPubspecSync('url_launcher', null);
      await addDependencyToPubspecSync('flutter_network_connectivity', null);
      Directory(path.join('lib', 'util')).createSync();
      Directory(path.join('lib', 'page', 'error')).createSync();
      Directory(path.join('lib', 'page', 'lost_connection')).createSync();
      Directory(path.join('lib', 'page', 'error', 'controller')).createSync();
      _addErrorPage(projectName);
      _addErrorController();
      _addUtil();
      _addNetworkService(projectName);
      _addLostConnectionPage();
      _addFirebaseConfigurationScript();
      _modifyMain();
      await addAllreadyRun('crashalytics');
      printColor("Finished Adding crashalytics", ColorText.green);
      printColor(
          "Added following dependencies: firebase_core, firebase_crashalitics, connectivity_plus, package_info_plus, flutter_svg, is_first_run",
          ColorText.green);
      printColor("REMEMBER TO RUN", ColorText.green);
      printColor("chmod +x ./firebase_configuration.sh", ColorText.magenta);
      printColor("./firebase_configuration.sh", ColorText.magenta);
    });
  }

  _modifyMain() async {
    String mainPath = path.join('lib', 'main.dart');
    int counter = 0;
    File(mainPath).readAsLines().then((List<String> lines) {
      String mainContent = '';
      mainContent += "import 'dart:async';\n";
      mainContent += "import 'dart:io';\n";
      mainContent +=
          "import 'page/lost_connection/lost_connection_page.dart';\n";
      mainContent += "import 'firebase_options.dart';\n";
      mainContent += "import 'service/network_service.dart';\n";
      mainContent += "import 'package:is_first_run/is_first_run.dart';\n";
      mainContent += "import 'package:firebase_core/firebase_core.dart';\n";
      mainContent += "import 'page/error/error_page.dart';\n";
      mainContent += "import 'package:flutter/services.dart';\n";
      mainContent += "import 'package:testc/util/util.dart';\n";
      mainContent +=
          "import 'package:firebase_crashlytics/firebase_crashlytics.dart';\n";

      bool removedOldMyApp = false;

      for (String line in lines) {
        counter++;
        mainContent += '$line\n';

        if (line.contains('void main() async {')) {
          mainContent += crashaliticsCodeForMain();
        }
        if (line.contains('runApp(const MyApp());') && !removedOldMyApp) {
          line = "";
          removedOldMyApp = true;
        }
        if (line.contains('Widget build(BuildContext context) {')) {
          mainContent += "getMaterialAppCalled = true;";
        }
        if (line.contains('bool isFirstRun = false;')) {
          mainContent += restartWidget();
          mainContent += handleError();
        }
      }

      File(mainPath).writeAsString(mainContent).then((file) {
        print('- inject StorageService in memory and initialize it ✔');
      });
    });
  }

  _addErrorPage(String projectName) async {
    File(path.join('lib', 'page', 'error', 'error_page.dart'))
        .writeAsString(error_page.content(projectName));
  }

  _addErrorController() async {
    File(path.join(
            'lib', 'page', 'error', 'controller', 'error_controller.dart'))
        .writeAsString(error_controller.content());
  }

  _addUtil() async {
    File(path.join('lib', 'util', 'util.dart')).writeAsString(util.content());
  }

  _addNetworkService(String projectName) async {
    File(path.join('lib', 'service', 'network_service.dart'))
        .writeAsString(network_service.content(projectName));
  }

  _addLostConnectionPage() async {
    File(path.join(
            'lib', 'page', 'lost_connection', 'lost_connection_page.dart'))
        .writeAsString(lost_connection_page.content());
  }

  _addFirebaseConfigurationScript() async {
    File(path.join('firebase_configuration.sh'))
        .writeAsString(firebase_configuration.content());
  }

  crashaliticsCodeForMain() {
    return """
  FlutterError.onError = (FlutterErrorDetails details) async {
    handleError(details.exception, details.stack, fatal: true);
  };

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }

    // ignore: unused_local_variable
    // await GetStorage.init('theme');
    //await networkService.init();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    isFirstRun = await IsFirstRun.isFirstRun();
    runApp(const MyApp());
  }, (error, stack) async {
    debugPrint('Error caught by main zone');
    debugPrint(error.toString());
    debugPrint(stack.toString());

    await handleError(error, stack, fatal: true);
  });
    """;
  }

  handleError() {
    return """
Future<void> handleError(error, StackTrace? stack,
    {bool fatal = false,
    Iterable<Object> information = const [],
    bool async = false}) async {
  // Failed host lookup
  if (error.toString().contains("Failed host lookup")) {
    Get.put(NetworkService()).onInternetLostPage.value = true;
    Get.to(() => const LostConnectionPage());
    if (error.toString().contains("No host specified in URI file:///")) {
      return;
    }

    // Check if the application is running on dev mode
    bool devMode = bool.tryParse(const String.fromEnvironment(
          'DEV_MODE',
        )) ??
        false;

    var currentController = Get.rootController;

    String previousRoute = currentController.routing.previous;

    // if (Get.put(UserStateService()).user.value.id != -1) {
    //   FirebaseCrashlytics.instance.setUserIdentifier(
    //       Get.put(UserStateService()).user.value.id.toString());
    // }

    if (!devMode) {
      if (fatal) {
        // If you see fatal on the crashlytics, it was registered here
        await FirebaseCrashlytics.instance
            .recordError(error, stack, fatal: true, information: [
          "Current Route: \${Get.currentRoute}",
          "Previous Route:  \$previousRoute",
          "Asynchronous: \$async",
          // "User Id: \${Get.put(UserStateService()).user.value.id.toString()}",
          ...information
        ]);

        if (getMaterialAppCalled) {
          Get.to(() => const ErrorPage());
        } else {
          // Try to exit app:
          // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      } else {
        // If you see non fatal on the crashlytics, it was registered here
        await FirebaseCrashlytics.instance.recordError(error, stack,
            reason: 'a non-fatal error, this will be ignored',
            information: [
              "Current Route: \${Get.currentRoute}",
              "Previous Route:  \$previousRoute",
              "Asynchronous: \$async",
              // "User Id: \${Get.put(UserStateService()).user.value.id.toString()}",
              ...information
            ]);
      }
    }
  }
}
    """;
  }

  restartWidget() {
    return """
class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  static Future<void> restartApp(BuildContext context) async {
    await context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp();
  }

  @override
  // ignore: library_private_types_in_public_api
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  Future<void> restartApp() async {
    await Get.deleteAll(force: false); //deleting all controllers
    setState(() {
      key = UniqueKey();
    });
    Get.reset();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
    """;
  }
}

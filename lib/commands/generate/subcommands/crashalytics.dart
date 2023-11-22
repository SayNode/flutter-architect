import 'package:args/command_runner.dart';
import 'package:project_initialization_tool/commands/util.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/files/error_page.dart'
    as error_page;
import 'package:project_initialization_tool/commands/generate/subcommands/files/network_controller.dart'
    as network_controller;
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
    print(
        "This script will add the code required to catch errors and send them to crashalytics");
    print(
        "However, to use this feature, you need to first configure firebase and crashalytics for this project");
    print("You can do this with the following commands:");
    print("`chmod +x ./firebase_configuration.sh`");
    print("`./firebase_configuration.sh`");
    print(
        "if that does work you can follow the official guide for flutter at https://firebase.google.com/docs/crashlytics/get-started?platform=flutter");

    String projectName = await getProjectName();
    print("current project name $projectName");

    checkIfAllreadyRun("crashalytics").then((value) async {
      print('Creating crashalitics configuration in main.dart...');
      addDependencyToPubspec('firebase_core', null);
      addDependencyToPubspec('firebase_crashalitics', null);
      addDependencyToPubspec('connectivity_plus', null);
      addDependencyToPubspec('package_info_plus', null);
      _addErrorPage(projectName);
      _addNetworkController();
      _modifyMain();
      await addAllreadyRun('crashalytics');
      print("Finished Addng crashalytics");
      print(
          "Added following dependencies: firebase_core, firebase_crashalitics, connectivity_plus, package_info_plus");
      print(
          "remember to run `chmod +x ./firebase_configuration.sh` and `./firebase_configuration.sh` to configure firebase and crashalytics for this project");
    });
  }

  _modifyMain() async {
    String mainPath = path.join('lib', 'main.dart');
    File(mainPath).readAsLines().then((List<String> lines) {
      String mainContent = '';
      mainContent += "import 'package:firebase_core/firebase_core.dart'\n";
      mainContent +=
          "import 'package:firebase_core/firebase_crashlytics.dart'\n";
      for (String line in lines) {
        mainContent += '$line\n';
        if (line.contains('void main() async {')) {
          mainContent += crashaliticsCodeForMain();
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

  _addNetworkController() async {
    File(path.join(
            'lib', 'page', 'error', 'controller', 'network_controller.dart'))
        .writeAsString(network_controller.content());
  }

  crashaliticsCodeForMain() {
    return """"
            runZonedGuarded<Future<void>>(
              () async {
                WidgetsFlutterBinding.ensureInitialized();
                if (Firebase.apps.isEmpty) {
                  await Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  );
                }
                FlutterError.onError = (FlutterErrorDetails errorDetails) {
                  debugPrint('Error catched by main zone');
                  debugPrint(errorDetails.exception.toString());
                  debugPrint('-----');
                  debugPrint(errorDetails.stack.toString());
                  FirebaseCrashlytics.instance.recordError(
                      errorDetails.exception, errorDetails.stack,
                      fatal: true);
                  if (errorDetails.exception is HttpException &&
                      errorDetails.stack.toString().contains("Connection closed")) {
                    return;
                  }
                  Get.to(() => ErrorPage(errorMessage: errorDetails.exception.toString()));
                };
                (error, stack) async {
                debugPrint('Error catched by main zone');

                // Ignore these errors
                if (error is HttpException && error.toString().contains("Connection")) {
                  await handleError(error, stack, information: ["Connection error"]);
                  return;
                } else {
                  await handleError(error, stack, fatal: true);
                }
              },
            );
    """;
  }

  handleError() {
    return """
    Future<void> handleError(error, StackTrace? stack,
    {bool fatal = false, Iterable<Object> information = const []}) async {
        var currentController = Get.rootController;

        String previousRoute = currentController.routing.previous;
        String userId = "";

        // if (!constants.devMode) { // TODO activate when the proper constants are in place
        if (true) {
          if (fatal) {
            // If you see fatal on the crashlytics, it was registered here
            await FirebaseCrashlytics.instance.recordError(error, stack,
                fatal: true,
                information: [
                  "Current Route: \${Get.currentRoute}",
                  "Previous Route:  \${previousRoute}",
                  "User Id: \${Get.put(UserStateService()).user.value.id.toString()}"
                ]..addAll(information));

            if (getMaterialAppCalled) {
              Get.to(() => ErrorPage(errorMessage: error.toString()));
            } else {
              // Try to exit app:
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            }
          } else {
            // If you see non fatal on the crashlytics, it was registered here
            await FirebaseCrashlytics.instance.recordError(error, stack,
                reason: 'a non-fatal error, this will be ignored',
                information: [
                  "Current Route: \${Get.currentRoute}",
                  "Previous Route:  \${previousRoute}"
                      // "User Id: "
                ]..addAll(information));
          }
        }
      }
    """;
  }
}

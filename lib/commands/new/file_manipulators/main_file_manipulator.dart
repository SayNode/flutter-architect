import '../../../interfaces/file_manipulator.dart';
import '../../../util/util.dart';

class MainFileManipulator extends FileManipulator {
  @override
  String content() {
    return """
import 'base/main_base.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

void main() {
  Main().main();
}

class Main extends MainBase {
  @override
  Future<void> initializeServices() async {
    Get.log('Initializing services...');
    // Initialize services:
    await super.initializeServices();
  }

  @override
  Future<void> beforeRunApp() async {
    // Before Run App:
    super.beforeRunApp();
  }

  @override
  Future<void> onRunZonedGuarded(WidgetsBinding widgetsBinding) async {
    // On Run Zoned Guarded:
    super.onRunZonedGuarded(widgetsBinding);
  }

  @override
  Future<void> handleError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    Iterable<Object> information = const <Object>[],
    bool async = false,
  }) async {
    // Handle Error:
    super.handleError(
      error,
      stack,
      fatal: fatal,
      information: information,
      async: async,
    );
  }
}""";
  }

  @override
  String get name => 'Main';

  @override
  String get path => 'lib/main.dart';

  Future<void> addStorageInitialization() async {
    printColor(
      'Adding StorageService initialization to main...',
      ColorText.white,
    );
    await addLinesAfterLineInFile(
      path,
      <String, List<String>>{
        '// Initialize services:': <String>[
          'await Get.find<StorageService>().init();',
        ],
        '// https://saynode.ch': <String>[
          "import '../service/storage/storage_service.dart';",
        ],
      },
    );
    printColor(
      'StorageService initialization added to main ✔\n',
      ColorText.green,
    );
  }

  Future<void> removeStorageInitialization() async {
    printColor(
      'Removing StorageService initialization from main...',
      ColorText.white,
    );
    await removeLinesFromFile(path, <String>[
      "import '../service/storage/storage_service.dart';",
      'await Get.find<StorageService>().init();',
    ]);
    printColor(
      'StorageService initialization removed from main ✔\n',
      ColorText.green,
    );
  }

  Future<void> addCrashlytics() async {
    printColor(
      'Adding Crashlytics error handling to main...',
      ColorText.white,
    );
    await addLinesAfterLineInFile(
      path,
      <String, List<String>>{
        '// https://saynode.ch': <String>[
          crashlyticsImports(),
        ],
        '// Handle Error:': <String>[
          crashlyticsRecord(),
        ],
        '// Before Run App:': <String>[
          firebaseInitialization(),
        ],
      },
    );
  }

  Future<void> removeCrashlytics() async {
    printColor(
      'Removing Crashlytics error handling from main...',
      ColorText.white,
    );
    await removeTextFromFile(path, crashlyticsImports());
    await removeTextFromFile(path, crashlyticsRecord());
    await removeTextFromFile(path, firebaseInitialization());
  }

  Future<void> addSplashScreen() async {
    printColor(
      'Adding splash screen preservation to main...',
      ColorText.white,
    );
    await addLinesAfterLineInFile(
      path,
      <String, List<String>>{
        '// On Run Zoned Guarded:': <String>[
          'FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);',
        ],
        '// Before Run App:': <String>[
          'FlutterNativeSplash.remove();',
        ],
        '// https://saynode.ch': <String>[
          "import 'package:flutter_native_splash/flutter_native_splash.dart';",
        ],
      },
    );
  }

  Future<void> removeSplashScreen() async {
    printColor(
      'Removing splash screen preservation from main...',
      ColorText.white,
    );
    await removeLinesFromFile(path, <String>[
      'FlutterNativeSplash.remove();',
      'FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);',
      "import 'package:flutter_native_splash/flutter_native_splash.dart';",
    ]);
  }

  String crashlyticsImports() => """
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'util/constants.dart';
import 'util/util.dart';""";

  String crashlyticsRecord() => r"""
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason:
          'This is a ${fatal ? "fatal" : "non-fatal"} error in ${Constants.devMode ? "Development" : "Production"}.',
      fatal: fatal,
      information: <Object>[
        'Current Route: ${Get.currentRoute}',
        'Previous Route: ${Get.previousRoute}',
        'Asynchronous: $async',
        'Production: ${!Constants.devMode}',
        'GetMaterialApp Called: $getMaterialAppCalled',
        ...information,
      ],
    );""";

  String firebaseInitialization() => '''
    // Initalize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }''';
}

import '../../../interfaces/file_manipulator.dart';
import '../../../util/util.dart';

class MainBaseFileManipulator extends FileManipulator {
  @override
  String get name => 'MainInterface';

  @override
  String get path => 'lib/base/main_base.dart';

  @override
  String content() {
    return r"""
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:is_first_run/is_first_run.dart';
import '../page/error/error_page.dart';
import '../service/logger_service.dart';
import '../service/main_bindings.dart';
import '../util/constants.dart';
import '../util/util.dart';
import 'package:get/get.dart';


abstract class MainBase {
  bool isFirstRun = false;
  Future<void> main() async {
    final MainBindings mainBinding = MainBindings();
    await mainBinding.dependencies();
    await unguarded();
    await guarded();
  }

  /// Initialize services that need initialization before the app starts.
  Future<void> initializeServices() async {
    // Initialize services:
  }

  Future<void> unguarded() async {}

  Future<void> guarded() async {
    await runZonedGuarded<Future<void>>(() async {
      final WidgetsBinding widgetsBinding =
          WidgetsFlutterBinding.ensureInitialized();

      await onRunZonedGuarded(widgetsBinding);

      // Handle framework errors:
      FlutterError.onError = (FlutterErrorDetails details) async {
        await handleError(
          details.exception,
          details.stack,
          fatal: true,
        );
      };

      // Initialize all services:
      await initializeServices();

      // Set preferred orientations:
      await SystemChrome.setPreferredOrientations(
        <DeviceOrientation>[DeviceOrientation.portraitUp],
      );

      // Check if it's the first run:
      isFirstRun = await IsFirstRun.isFirstRun();

      await beforeRunApp();

      // Run the app:
      runApp(const MyApp());
    }, (Object error, StackTrace stack) async {
      // Handle uncaught errors:
      await handleError(error, stack, fatal: true);
    });
  }

  /// This is called before runApp()
  Future<void> beforeRunApp() async {}

  /// This is called first thing inside runZonedGuarded()
  Future<void> onRunZonedGuarded(WidgetsBinding widgetsBinding) async {}

  /// Handle uncaught erros
  Future<void> handleError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    Iterable<Object> information = const <Object>[],
    bool async = false,
  }) async {
    if (Constants.devMode) {
      // Error in Development:
      Get.find<LoggerService>().log(
        'An error occurred in DEV: $error',
      );
    } else {
      if (fatal) {
        // Fatal error in Production:
        if (getMaterialAppCalled) {
          Get.find<LoggerService>().log(
            'A fatal error occurred: $error',
          );
          await Get.to(() => ErrorPage(error: error));
        } else {
          Get.find<LoggerService>().log(
            'A fatal error occurred before GetMaterialApp was called: $error',
          );
        }
      } else {
        // Non-Fatal error in Production:
        Get.find<LoggerService>().log(
          'An non-fatal error occurred: $error',
        );
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    getMaterialAppCalled = true;
    // Start MaterialApp
    return GetMaterialApp(
    debugShowCheckedModeBanner: Constants.devMode,
      title: 'testing',
      initialRoute: '/',
      getPages: <GetPage<void>>[
        GetPage<void>(
          name: '/',
          page: Container.new,
        ),
      ],
      theme: ThemeData(),
    );
    // End MaterialApp
  }
}

""";
  }

  Future<void> addLocalization() async {
    printColor(
      'Adding Localization to main...\n',
      ColorText.white,
    );
    await addLinesAfterLineInFile(
      path,
      <String, List<String>>{
        '// End MaterialApp': <String>[
          '},);',
        ],
        'return GetMaterialApp(': <String>[
          'locale: localizationController.locale,',
          'translations:',
          'Messages(languages: localizationController.translations),',
        ],
        '// https://saynode.ch': <String>[
          "import '../service/localization_controller.dart';",
          "import '../model/message.dart';",
        ],
      },
    );

    await addLinesBeforeLineInFile(
      path,
      <String, List<String>>{
        '// Start MaterialApp': <String>[
          'return GetBuilder<LocalizationController>(',
          'builder: (LocalizationController localizationController) {',
        ],
        'runApp(const MyApp());': <String>[
          'final LocalizationController localizationController = Get.find<LocalizationController>();',
          'await localizationController.init();',
        ],
      },
    );
    printColor(
      'Localization added to main ✔\n',
      ColorText.green,
    );
  }

  // Remove the Storage-related lines from main.
  Future<void> removeLocalization() async {
    printColor(
      'Removing Localization from main...\n',
      ColorText.white,
    );
    await removeLinesFromFile(
      path,
      <String>[
        "import '../service/localization_controller.dart';",
        "import '../model/message.dart';",
        'return GetBuilder<LocalizationController>(',
        'builder: (LocalizationController localizationController) {',
        'locale: localizationController.locale,',
        'translations:',
        'Messages(languages: localizationController.translations),',
        'final LocalizationController localizationController =',
        'await localizationController.init();',
      ],
    );

    await removeLinesAfterFromFile(
      path,
      '// End MaterialApp',
      2,
    );
    printColor(
      'Localization removed from main ✔\n',
      ColorText.green,
    );
  }

  Future<void> addTheme() async {
    await replaceLineInFile(
      path,
      'theme: ThemeData(),',
      'theme: Get.find<ThemeService>().themeData,',
    );

    await addLinesAfterLineInFile(
      path,
      <String, List<String>>{
        '// https://saynode.ch': <String>[
          "import '../service/theme_service.dart';",
        ],
      },
    );
  }

  Future<void> removeTheme() async {
    await replaceLineInFile(
      path,
      'theme: Get.find<ThemeService>().themeData,',
      'theme: ThemeData(),',
    );

    await removeLinesFromFile(
      path,
      <String>[
        "import '../service/theme_service.dart';",
      ],
    );
  }
}

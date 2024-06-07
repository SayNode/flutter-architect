// ignore_for_file: prefer_interpolation_to_compose_strings, unnecessary_string_escapes

String content(String projectName) {
  return r"""
import 'dart:async';
import 'service/logger_service.dart';
import 'package:is_first_run/is_first_run.dart';
import 'page/error/error_page.dart';
import 'package:flutter/services.dart';
import 'util/constants.dart';
import 'util/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'page/splash_page.dart';

bool isFirstRun = false;

// Handle uncaught erros
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

Future<void> initializeServices() async {
  // Initialize services:
}

void main() async {
  await runZonedGuarded<Future<void>>(() async {
    // Handle framework errors:
    FlutterError.onError = (FlutterErrorDetails details) async {
      await handleError(
        details.exception,
        details.stack,
        fatal: true,
      );
    };

    // Bind services:
    final MainBindings mainBinding = MainBindings();
    await mainBinding.dependencies();
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize services:
    await initializeServices();

    // Set preferred orientations:
    await SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[DeviceOrientation.portraitUp],
    );

    // Check if it's the first run:
    isFirstRun = await IsFirstRun.isFirstRun();

    // Run the app:
    runApp(const MyApp());
  }, (Object error, StackTrace stack) async {
    // Handle uncaught errors:
    await handleError(error, stack, fatal: true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    getMaterialAppCalled = true;
    // Start MaterialApp
    return GetMaterialApp(
      title: 'testing',
      initialRoute: '/',
      getPages: <GetPage<void>>[
        GetPage<void>(
          name: '/',
          page: () => const SplashPage(),
        ),
      ],
      theme: ThemeData(),
    );
    // End MaterialApp
  }
}""";
}

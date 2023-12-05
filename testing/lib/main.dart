import 'service/storage_service.dart';
import 'service/localization_controller.dart';
import 'model/message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'page/splash_page.dart';

bool isFirstRun = false;

void main() async {
  final StorageService storage = Get.put<StorageService>(StorageService());
  await storage.init();
  final LocalizationController localizationController =
      Get.put(LocalizationController());
  await localizationController.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (LocalizationController localizationController) {
        //Start MaterialApp
        return GetMaterialApp(
          locale: localizationController.locale,
          translations:
              Messages(languages: localizationController.translations),
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
        //End MaterialApp
      },
    );
  }
}

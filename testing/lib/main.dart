import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'page/splash_page.dart';

bool isFirstRun = false;

void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //Start MaterialApp
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
    //End MaterialApp
  }
}

// ignore_for_file: prefer_interpolation_to_compose_strings, unnecessary_string_escapes

String content(String projectName) {
  return """
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'page/splash_page.dart';

bool isFirstRun = false;

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //Start MaterialApp
    return GetMaterialApp(
      title: '$projectName',
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
""";

  // 'import \'package:flutter\/material.dart\';\n'
  //         'import \'package:get\/get.dart\';\n'
  //         'import \'page\/splash_page.dart\';\n'
  //         '\n'
  //         'void main() async {\n'
  //         'runApp(const MyApp());}'
  //         '\n'
  //         '\n'
  //         '\n'
  //         '\n'
  //         'class MyApp extends StatelessWidget {\n'
  //         '  const MyApp({super.key});\n'
  //         '  \/\/ This widget is the root of your application.\n'
  //         '  @override\n'
  //         '  Widget build(BuildContext context) {\n'
  //         '    //Start MaterialApp\n'
  //         '    return GetMaterialApp(\n'
  //         '      title: \'' +
  //     projectName +
  //     '\',\n' +
  //     '      initialRoute: \'\/\',\n' +
  //     'getPages: [' +
  //     'GetPage(' +
  //     "name: '/'," +
  //     "page: () => const SplashPage()," +
  //     ")," +
  //     "]," +
  //     '      theme: ThemeData(),\n' +
  //     '    );\n' +
  //     '    //End MaterialApp\n' +
  //     '  }\n' +
  //     '}';
}

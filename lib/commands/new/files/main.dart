// ignore_for_file: prefer_interpolation_to_compose_strings, unnecessary_string_escapes

String content(String projectName) {
  return 'import \'package:flutter\/material.dart\';\n'
          '\n'
          'void main() => runApp(MyApp());'
          '\n'
          '\n'
          '\n'
          '\n'
          'class MyApp extends StatelessWidget {\n'
          '  \/\/ This widget is the root of your application.\n'
          '  @override\n'
          '  Widget build(BuildContext context) {\n'
          '    return MaterialApp(\n'
          '      title: \'' +
      projectName +
      '\',\n' +
      '      initialRoute: \'\/\',\n' +
      '      routes: ROUTES,\n' +
      '      theme: ThemeData(),\n' +
      '    );\n' +
      '  }\n' +
      '}';
}

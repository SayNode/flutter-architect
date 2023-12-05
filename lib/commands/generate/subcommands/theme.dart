import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/generate/subcommands/files/theme_service.dart'
    as theme_service;
import 'package:project_initialization_tool/commands/util.dart';

import 'storage.dart';

class GenerateTheme extends Command {
  late final String figmaFileKey;
  late final String figmaToken;
  late String themeName;
  late String colorName;

  //-- Singleton
  GenerateTheme() {
    // Add parser options or flag here
    argParser.addFlag('force',
        defaultsTo: false, help: 'Force replace in case it already exists.');
  }

  @override
  String get description =>
      'Create theme files and boilerplate code from Figma styles.';

  @override
  String get name => 'theme';

  @override
  void run() async {
    stdout.writeln('Enter the file key of your Figma file:');
    figmaFileKey = stdin.readLineSync() ?? '';
    stdout.writeln('Enter your Figma personal access token:');
    figmaToken = stdin.readLineSync() ?? '';
    _setThemeName();
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    // Check if Shared Storage has already been set up. Theme requires Shared Storage.
    // If not, run GenerateStorageService.runShared().
    bool value = await checkIfAlreadyRunWithReturn("shared_storage");
    if (!value) {
      var storageService = GenerateStorageService();
      await storageService.runShared();
    }

    var styles = await getFigmaStyles();
    List colorList = await getColorsFromStyles(styles);

    value = await checkIfAlreadyRunWithReturn("theme");
    if (value) {
      // Already ran
      if (argResults?['force'] ?? false) {
        // If --force, remove all files and add them again.
        // main.dart will not be modified.
        print('Replacing theme...');
        await _removeColorFile();
        await _removeThemeFile();
        await _removeThemeServiceFile();
        await _removeMainLines();
        await _addColorFile(colorList);
        await _addThemeFile(colorList);
        await _addThemeServiceFile(themeName);
        await _modifyMain();
      } else {
        // If not --force, modify files.
        print('Modifying theme...');
        await _modifyColorFile(colorList);
        await _modifyThemeFile(colorList);
        await _modifyThemeServiceFile(themeName);
      }
    } else {
      // First run
      print('Adding theme...');
      await addAlreadyRun("theme-$themeName");
      await _addColorFile(colorList);
      await _addThemeFile(colorList);
      await _addThemeServiceFile(themeName);
      await _modifyMain();
    }
    // Format and fix code
    await formatCode();
    await dartFixCode();
  }

  /// Check if [s] is camelCase.
  bool isCamelCase(String s) {
    return RegExp(r'^[a-z]+(?:[A-Z][a-z]+)*$').hasMatch(s);
  }

  /// Waits for the user to enter a valid camelCase theme name.
  /// Sets the [themeName] and [colorName] variables.
  Future<void> _setThemeName() async {
    var tempThemeName = '';
    for (var i = 0; i < 10; i++) {
      stdout.writeln('Enter the name of your new theme:');
      tempThemeName = stdin.readLineSync() ?? '';
      if (!isCamelCase(tempThemeName)) {
        stdout.writeln(
            'The name of your theme must be in camel case (e.g. myTheme).');
      } else if (await checkIfAlreadyRunWithReturn("theme-$tempThemeName") &&
          !argResults?['force']) {
        stdout.writeln(
            '$tempThemeName already exists. Please choose another name.');
      } else {
        break;
      }
    }
    themeName = tempThemeName;
    colorName = '${themeName[0].toUpperCase()}${themeName.substring(1)}Color';
    stdout.writeln('Success!');
  }

  Future<void> _removeColorFile() async {
    await File(path.join('lib', 'theme', 'color.dart')).delete();
  }

  Future<void> _removeThemeFile() async {
    await File(path.join('lib', 'theme', 'theme.dart')).delete();
  }

  Future<void> _removeThemeServiceFile() async {
    await File(path.join('lib', 'service', 'theme_service.dart')).delete();
  }

  // Remove the Theme-related lines from main.
  Future<void> _removeMainLines() async {
    String mainPath = path.join('lib', 'main.dart');
    List<String> lines = await File(mainPath).readAsLines();
    String mainContent = '';

    for (String line in lines) {
      if (!line.contains('Get.put<ThemeService>(ThemeService());') &&
          !line.contains("import 'service/theme_service.dart';")) {
        mainContent += '$line\n';
      }
    }

    await File(mainPath).writeAsString(mainContent).then((file) {
      print('- Remove ThemeService from Storage ✔');
    });
  }

  Future<void> _addColorFile(List colorList) async {
    String content =
        "import 'package:flutter/material.dart';\n class $colorName {\n";
    for (var color in colorList) {
      content +=
          "static const Color ${color['name']} = Color.fromRGBO(${color['r']}, ${color['g']}, ${color['b']}, ${color['a']});\n\n";
    }
    content += '}';
    await File(path.join('lib', 'theme', 'color.dart')).writeAsString(content);
  }

  Future<void> _addThemeFile(List colorList) async {
    String content =
        "import 'package:flutter/material.dart';\n import 'color.dart'; \n class CustomTheme extends ThemeExtension<CustomTheme>{\nconst CustomTheme(\n{";
    for (var color in colorList) {
      content += "required this.${color['name']},\n";
    }
    content += '});\n\n';

    for (var color in colorList) {
      content += "final Color ${color['name']};\n\n";
    }
    content += '  @override\nCustomTheme copyWith({';
    for (var color in colorList) {
      content += "Color? ${color['name']},\n";
    }
    content += '}) {\nreturn CustomTheme(\n';
    for (var color in colorList) {
      content +=
          "${color['name']}: ${color['name']} ?? this.${color['name']},\n";
    }

    content = '${content.substring(0, content.length - 2)});}\n\n';
    content += '//list of themes\n';
    content += '  static const $themeName = CustomTheme(\n';
    for (var color in colorList) {
      content += "${color['name']}: $colorName.${color['name']},\n";
    }
    content = '${content.substring(0, content.length - 1)});\n\n';
    content +=
        "@override \nThemeExtension<CustomTheme> lerp( \ncovariant ThemeExtension<CustomTheme>? other, double t) { \n// TODO: implement lerp \nthrow UnimplementedError(); \n} \n}";

    await File(path.join('lib', 'theme', 'theme.dart')).writeAsString(content);
  }

  Future<void> _addThemeServiceFile(String name) async {
    await File(path.join('lib', 'service', 'theme_service.dart'))
        .writeAsString(theme_service.content(name));
  }

  Future<void> _modifyColorFile(List colorList) async {
    List<String> lines =
        await File(path.join('lib', 'theme', 'color.dart')).readAsLines();

    String colorFileContent = '';

    for (String line in lines) {
      colorFileContent += '$line\n';

      if (line.contains("import 'package:flutter/material.dart';")) {
        colorFileContent += "class $colorName {\n";
        for (var color in colorList) {
          colorFileContent +=
              "static const Color ${color['name']} = Color.fromRGBO(${color['r']}, ${color['g']}, ${color['b']}, ${color['a']});\n\n";
        }
        colorFileContent += '}';
      }
    }

    await File(path.join('lib', 'theme', 'color.dart'))
        .writeAsString(colorFileContent)
        .then((file) {
      print('- Colors added to Color.dart ✔');
    });
  }

  Future<void> _modifyThemeFile(List colorList) async {
    List<String> lines =
        await File(path.join('lib', 'theme', 'theme.dart')).readAsLines();

    String content = '';

    for (String line in lines) {
      content += '$line\n';

      if (line.contains("//list of themes")) {
        content += '  static const $themeName = CustomTheme(\n';
        for (var color in colorList) {
          content += "${color['name']}: $colorName.${color['name']},\n";
        }
        content = '${content.substring(0, content.length - 1)});\n\n';
      }
    }

    await File(path.join('lib', 'theme', 'theme.dart'))
        .writeAsString(content)
        .then((file) {
      print('- Colors added to Color.dart ✔');
    });
  }

  Future<void> _modifyThemeServiceFile(String name) async {
    String content = '''
      case '$name':
        return ThemeData(
          extensions: const <ThemeExtension<CustomTheme>>[
            CustomTheme.$name,
          ],
        );
        ''';
    List<String> lines =
        await File(path.join('lib', 'service', 'theme_service.dart'))
            .readAsLines();

    String colorFileContent = '';

    for (String line in lines) {
      colorFileContent += '$line\n';

      if (line.contains("//List of themes")) {
        colorFileContent += content;
      }
    }

    await File(path.join('lib', 'service', 'theme_service.dart'))
        .writeAsString(colorFileContent)
        .then((file) {
      print('- theme added to theme_service.dart ✔');
    });
  }

  Future<void> _modifyMain() async {
    String mainPath = path.join('lib', 'main.dart');
    List<String> lines = await File(mainPath).readAsLines();
    String mainContent = '';

    mainContent += "import 'service/theme_service.dart';\n";

    for (String line in lines) {
      mainContent += '$line\n';
      if (line.contains('await storage.init();')) {
        mainContent += "Get.put<ThemeService>(ThemeService());\n";
      }
    }

    await File(mainPath).writeAsString(mainContent).then((file) {
      print('- Inject ThemeService in Storage ✔');
    });
  }

  Future<dynamic> getFigmaStyles() async {
    try {
      final headers = {
        'X-FIGMA-TOKEN': figmaToken,
      };

      final url =
          Uri.parse('https://api.figma.com/v1/files/$figmaFileKey/styles');

      final res = await http.get(url, headers: headers);
      final status = res.statusCode;
      if (status != 200) {
        throw Exception(
            'http.get error: statusCode= $status, body= ${res.body}');
      }
      Map data = jsonDecode(res.body);
      if (data['error'] == true) {
        throw Exception('Figma returned an error: ${data['status']}');
      }
      print('got styles');
      return data['meta']['styles'];
    } catch (e) {
      print(e.toString());
      exit(1);
    }
  }

  Future<dynamic> getColorsFromStyles(List styles) async {
    try {
      List<String> ids = [];
      for (var style in styles) {
        if (style['style_type'] == 'FILL') {
          ids.add(style['node_id']);
        }
      }
      final headers = {
        'X-FIGMA-TOKEN': figmaToken,
      };

      final url = Uri.parse(
          'https://api.figma.com/v1/files/$figmaFileKey/nodes?ids=${ids.join(',')}');
      print(url);

      final res = await http.get(url, headers: headers);
      final status = res.statusCode;
      if (status != 200) throw Exception('http.get error: statusCode= $status');
      Map data = jsonDecode(res.body);
      if (data['error'] == true) {
        throw Exception('Figma returned an error: ${data['status']}');
      }

      List colors = [];
      for (var node in ids) {
        data['nodes'][node]['document']['fills'].forEach((fill) {
          if (fill['type'] == 'SOLID') {
            colors.add({
              'name': lowerCamelCase(data['nodes'][node]['document']['name']),
              'r': (255 * fill['color']['r']).toInt(),
              'g': (255 * fill['color']['g']).toInt(),
              'b': (255 * fill['color']['b']).toInt(),
              'a': fill['color']['a']
            });
          }
        });
      }

      return colors;
    } catch (e) {
      print(e.toString());
      exit(1);
    }
  }
}

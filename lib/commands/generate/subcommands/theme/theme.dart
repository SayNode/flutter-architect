import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'code/theme_service.dart'
    as theme_service;
import '../../../util.dart';

import '../storage/storage.dart';

class GenerateThemeService extends Command {

  //-- Singleton
  GenerateThemeService() {
    // Add parser options or flag here
    argParser.addFlag('force', help: 'Force replace in case it already exists.',);
    argParser.addFlag('remove', help: 'Remove in case it already exists.',);
  }
  late final String figmaFileKey;
  late final String figmaToken;
  late String themeName;
  late String colorName;

  @override
  String get description =>
      'Create theme files and boilerplate code from Figma styles;';

  @override
  String get name => 'theme';

  @override
  Future<void> run() async {
    final bool remove = argResults?['remove'] ?? false;
    if (!remove) {
      stdout.writeln('Enter the file key of your Figma file:');
      figmaFileKey = stdin.readLineSync() ?? '';
      stdout.writeln('Enter your Figma personal access token:');
      figmaToken = stdin.readLineSync() ?? '';
      await _setThemeName();
    }
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    // Check if Shared Storage has already been set up. Theme requires Shared Storage.
    // If not, run GenerateStorageService.runShared().
    final bool value = await checkIfAlreadyRunWithReturn('shared_storage');
    if (!value) {
      final GenerateStorageService storageService = GenerateStorageService();
      await storageService.runShared();
    }

    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('theme');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Theme...');
        final styles = await getFigmaStyles();
        final List colorList = await getColorsFromStyles(styles);
        await addAlreadyRun('theme-$themeName');
        await _addColorFile(colorList);
        await _addThemeFile(colorList);
        await _addThemeServiceFile(themeName);
        await _addMainChanges();
      },
      remove: () async {
        print('Removing Theme...');
        await removeAlreadyRunStartingWith('theme');
        await _removeColorFile();
        await _removeThemeFile();
        await _removeThemeServiceFile();
        await _removeMainChanges();
      },
      rejectAdd: () async {
        print('Modifying Theme... (adding $themeName)');
        final styles = await getFigmaStyles();
        final List colorList = await getColorsFromStyles(styles);
        await addAlreadyRun('theme-$themeName');
        await _modifyColorFile(colorList);
        await _modifyThemeFile(colorList);
        await _modifyThemeServiceFile(themeName);
      },
      rejectRemove: () async {
        print("Can't remove Theme as it's not yet configured.");
      },
    );
    formatCode();
    dartFixCode();
  }

  /// Check if [s] is camelCase.
  bool isCamelCase(String s) {
    return RegExp(r'^[a-z]+(?:[A-Z][a-z]+)*$').hasMatch(s);
  }

  /// Waits for the user to enter a valid camelCase theme name.
  /// Sets the [themeName] and [colorName] variables.
  Future<void> _setThemeName() async {
    String tempThemeName = '';
    for (int i = 0; i < 10; i++) {
      stdout.writeln('Enter the name of your new theme:');
      tempThemeName = stdin.readLineSync() ?? '';
      if (!isCamelCase(tempThemeName)) {
        stdout.writeln(
            'The name of your theme must be in camel case (e.g. myTheme).',);
      } else if (await checkIfAlreadyRunWithReturn('theme-$tempThemeName') &&
          !argResults?['force']) {
        stdout.writeln(
            '$tempThemeName already exists. Please choose another name.',);
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
  Future<void> _removeMainChanges() async {
    final String mainPath = path.join('lib', 'main.dart');
    await removeLinesFromFile(
      mainPath,
      <String>[
        'Get.put<ThemeService>(ThemeService());',
        "import 'service/theme_service.dart';",
      ],
    );
    await replaceLineInFile(
      mainPath,
      'theme: Get.put<ThemeService>(ThemeService()).themeData,',
      'theme: ThemeData(),',
    );
  }

  Future<void> _addColorFile(List colorList) async {
    String content =
        "import 'package:flutter/material.dart';\n class $colorName {\n";
    for (final color in colorList) {
      content +=
          "static const Color ${color['name']} = Color.fromRGBO(${color['r']}, ${color['g']}, ${color['b']}, ${color['a']});\n\n";
    }
    content += '}';
    await writeFileWithPrefix(path.join('lib', 'theme', 'color.dart'), content);
  }

  Future<void> _addThemeFile(List colorList) async {
    String content =
        "import 'package:flutter/material.dart';\n import 'color.dart'; \n class CustomTheme extends ThemeExtension<CustomTheme>{\nconst CustomTheme(\n{";
    for (final color in colorList) {
      content += "required this.${color['name']},\n";
    }
    content += '});\n\n';

    for (final color in colorList) {
      content += "final Color ${color['name']};\n\n";
    }
    content += '  @override\nCustomTheme copyWith({';
    for (final color in colorList) {
      content += "Color? ${color['name']},\n";
    }
    content += '}) {\nreturn CustomTheme(\n';
    for (final color in colorList) {
      content +=
          "${color['name']}: ${color['name']} ?? this.${color['name']},\n";
    }

    content = '${content.substring(0, content.length - 2)});}\n\n';
    content += '//list of themes\n';
    content += '  static const $themeName = CustomTheme(\n';
    for (final color in colorList) {
      content += "${color['name']}: $colorName.${color['name']},\n";
    }
    content = '${content.substring(0, content.length - 1)});\n\n';
    content +=
        '@override \nThemeExtension<CustomTheme> lerp( \ncovariant ThemeExtension<CustomTheme>? other, double t) { \n// TODO: implement lerp \nthrow UnimplementedError(); \n} \n}';

    await writeFileWithPrefix(path.join('lib', 'theme', 'theme.dart'), content);
  }

  Future<void> _addThemeServiceFile(String name) async {
    await writeFileWithPrefix(path.join('lib', 'service', 'theme_service.dart'),
        theme_service.content(name),);
  }

  Future<void> _modifyColorFile(List colorList) async {
    final List<String> lines =
        await File(path.join('lib', 'theme', 'color.dart')).readAsLines();

    String colorFileContent = '';

    for (final String line in lines) {
      colorFileContent += '$line\n';

      if (line.contains("import 'package:flutter/material.dart';")) {
        colorFileContent += 'class $colorName {\n';
        for (final color in colorList) {
          colorFileContent +=
              "static const Color ${color['name']} = Color.fromRGBO(${color['r']}, ${color['g']}, ${color['b']}, ${color['a']});\n\n";
        }
        colorFileContent += '}';
      }
    }

    await File(path.join('lib', 'theme', 'color.dart'))
        .writeAsString(colorFileContent)
        .then((File file) {
      print('- Colors added to Color.dart ✔');
    });
  }

  Future<void> _modifyThemeFile(List colorList) async {
    final List<String> lines =
        await File(path.join('lib', 'theme', 'theme.dart')).readAsLines();

    String content = '';

    for (final String line in lines) {
      content += '$line\n';

      if (line.contains('//list of themes')) {
        content += '  static const $themeName = CustomTheme(\n';
        for (final color in colorList) {
          content += "${color['name']}: $colorName.${color['name']},\n";
        }
        content = '${content.substring(0, content.length - 1)});\n\n';
      }
    }

    await File(path.join('lib', 'theme', 'theme.dart'))
        .writeAsString(content)
        .then((File file) {
      print('- Colors added to Color.dart ✔');
    });
  }

  Future<void> _modifyThemeServiceFile(String name) async {
    final String content = '''
      case '$name':
        return ThemeData(
          extensions: const <ThemeExtension<CustomTheme>>[
            CustomTheme.$name,
          ],
        );
        ''';
    final List<String> lines =
        await File(path.join('lib', 'service', 'theme_service.dart'))
            .readAsLines();

    String colorFileContent = '';

    for (final String line in lines) {
      colorFileContent += '$line\n';

      if (line.contains('//List of themes')) {
        colorFileContent += content;
      }
    }

    await File(path.join('lib', 'service', 'theme_service.dart'))
        .writeAsString(colorFileContent)
        .then((File file) {
      print('- theme added to theme_service.dart ✔');
    });
  }

  Future<void> _addMainChanges() async {
    final String mainPath = path.join('lib', 'main.dart');

    await replaceLineInFile(
      mainPath,
      'theme: ThemeData(),',
      'theme: Get.put<ThemeService>(ThemeService()).themeData,',
    );

    await addLinesAfterLineInFile(
      mainPath,
      <String, List<String>>{
        'await storage.init();': <String>[
          'Get.put<ThemeService>(ThemeService());',
        ],
        '// https://saynode.ch': <String>["import 'service/theme_service.dart';"],
      },
    );
  }

  Future<dynamic> getFigmaStyles() async {
    try {
      final Map<String, String> headers = <String, String>{
        'X-FIGMA-TOKEN': figmaToken,
      };

      final Uri url =
          Uri.parse('https://api.figma.com/v1/files/$figmaFileKey/styles');

      final http.Response res = await http.get(url, headers: headers);
      final int status = res.statusCode;
      if (status != 200) {
        throw Exception(
            'http.get error: statusCode= $status, body= ${res.body}',);
      }
      final Map data = jsonDecode(res.body);
      if (data['error'] == true) {
        throw Exception('Figma returned an error: ${data['status']}');
      }
      print('got styles');
      return data['meta']['styles'];
    } catch (e) {
      print(e);
      exit(1);
    }
  }

  Future<dynamic> getColorsFromStyles(List styles) async {
    try {
      final List<String> ids = <String>[];
      for (final style in styles) {
        if (style['style_type'] == 'FILL') {
          ids.add(style['node_id']);
        }
      }
      final Map<String, String> headers = <String, String>{
        'X-FIGMA-TOKEN': figmaToken,
      };

      final Uri url = Uri.parse(
          'https://api.figma.com/v1/files/$figmaFileKey/nodes?ids=${ids.join(',')}',);
      print(url);

      final http.Response res = await http.get(url, headers: headers);
      final int status = res.statusCode;
      if (status != 200) throw Exception('http.get error: statusCode= $status');
      final Map data = jsonDecode(res.body);
      if (data['error'] == true) {
        throw Exception('Figma returned an error: ${data['status']}');
      }

      final List colors = <>[];
      for (final String node in ids) {
        data['nodes'][node]['document']['fills'].forEach((fill) {
          if (fill['type'] == 'SOLID') {
            colors.add(<String, >{
              'name': lowerCamelCase(data['nodes'][node]['document']['name']),
              'r': (255 * fill['color']['r']).toInt(),
              'g': (255 * fill['color']['g']).toInt(),
              'b': (255 * fill['color']['b']).toInt(),
              'a': fill['color']['a'],
            });
          }
        });
      }

      return colors;
    } catch (e) {
      print(e);
      exit(1);
    }
  }
}

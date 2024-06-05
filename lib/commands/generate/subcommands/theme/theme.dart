// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../../../../util/util.dart';
import '../storage/storage.dart';
import 'code/theme_service.dart' as theme_service;

class GenerateThemeService extends Command<dynamic> {
  //-- Singleton
  GenerateThemeService() {
    // Add parser options or flag here
    argParser
      ..addFlag(
        'force',
        help: 'Force replace in case it already exists.',
      )
      ..addFlag(
        'remove',
        help: 'Remove in case it already exists.',
      );
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
      await storageService.run();
    }

    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('theme');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        stderr.writeln('Creating Theme...');
        final List<dynamic> styles = await getFigmaStyles();
        final List<dynamic> colorList = await getColorsFromStyles(styles);
        await addAlreadyRun('theme-$themeName');
        await _addColorFile(colorList);
        await _addThemeFile(colorList);
        await _addThemeServiceFile(themeName);
        await _addMainChanges();
      },
      remove: () async {
        stderr.writeln('Removing Theme...');
        await removeAlreadyRunStartingWith('theme');
        await _removeColorFile();
        await _removeThemeFile();
        await _removeThemeServiceFile();
        await _removeMainChanges();
      },
      rejectAdd: () async {
        stderr.writeln('Modifying Theme... (adding $themeName)');
        final List<dynamic> styles = await getFigmaStyles();
        final List<dynamic> colorList = await getColorsFromStyles(styles);
        await addAlreadyRun('theme-$themeName');
        await _modifyColorFile(colorList);
        await _modifyThemeFile(colorList);
        await _modifyThemeServiceFile(themeName);
      },
      rejectRemove: () async {
        stderr.writeln("Can't remove Theme as it's not yet configured.");
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
          'The name of your theme must be in camel case (e.g. myTheme).',
        );
      } else if (await checkIfAlreadyRunWithReturn('theme-$tempThemeName') &&
          !argResults?['force']) {
        stdout.writeln(
          '$tempThemeName already exists. Please choose another name.',
        );
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

  Future<void> _addColorFile(List<dynamic> colorList) async {
    final StringBuffer buffer = StringBuffer()
      ..write("import 'package:flutter/material.dart';\n class $colorName {\n");
    for (final Map<String, dynamic> color in colorList) {
      buffer.write(
        "static const Color ${color['name']} = Color.fromRGBO(${color['r']}, ${color['g']}, ${color['b']}, ${color['a']});\n\n",
      );
    }
    buffer.write('}');
    await writeFileWithPrefix(
      path.join('lib', 'theme', 'color.dart'),
      buffer.toString(),
    );
  }

  Future<void> _addThemeFile(List<dynamic> colorList) async {
    final StringBuffer content = StringBuffer()
      ..writeln("import 'package:flutter/material.dart';")
      ..writeln("import 'color.dart';")
      ..writeln('class CustomTheme extends ThemeExtension<CustomTheme> {')
      ..writeln('const CustomTheme({');

    for (final Map<String, dynamic> color in colorList) {
      content.writeln("required this.${color['name']},");
    }

    content
      ..writeln('});')
      ..writeln();

    for (final Map<String, dynamic> color in colorList) {
      content
        ..writeln("final Color ${color['name']};")
        ..writeln();
    }

    content
      ..writeln('@override')
      ..writeln('CustomTheme copyWith({');

    for (final Map<String, dynamic> color in colorList) {
      content.writeln("Color? ${color['name']},");
    }

    content
      ..writeln('}) {')
      ..writeln('return CustomTheme(');

    for (final Map<String, dynamic> color in colorList) {
      content.writeln(
        "${color['name']}: ${color['name']} ?? this.${color['name']},",
      );
    }

    content
      ..writeln(');}')
      ..writeln()
      ..writeln('//list of themes')
      ..writeln('static const $themeName = CustomTheme(');

    for (final Map<String, dynamic> color in colorList) {
      content.writeln("${color['name']}: $colorName.${color['name']},");
    }

    content
      ..writeln(');')
      ..writeln()
      ..writeln('@override')
      ..writeln(
        'ThemeExtension<CustomTheme> lerp(ThemeExtension<CustomTheme>? other, double t) {',
      )
      ..writeln('// TODO: implement lerp')
      ..writeln('throw UnimplementedError();')
      ..writeln('}}');

    await writeFileWithPrefix(
      path.join('lib', 'theme', 'theme.dart'),
      content.toString(),
    );
  }

  Future<void> _addThemeServiceFile(String name) async {
    await writeFileWithPrefix(
      path.join('lib', 'service', 'theme_service.dart'),
      theme_service.content(name),
    );
  }

  Future<void> _modifyColorFile(List<dynamic> colorList) async {
    final List<String> lines =
        await File(path.join('lib', 'theme', 'color.dart')).readAsLines();

    final StringBuffer buffer = StringBuffer();
    for (final String line in lines) {
      buffer.write('$line\n');

      if (line.contains("import 'package:flutter/material.dart';")) {
        buffer.write('class $colorName {\n');
        for (final Map<String, dynamic> color in colorList) {
          buffer.write(
            "static const Color ${color['name']} = Color.fromRGBO(${color['r']}, ${color['g']}, ${color['b']}, ${color['a']});\n\n",
          );
        }
        buffer.write('}');
      }
    }

    await File(path.join('lib', 'theme', 'color.dart'))
        .writeAsString(buffer.toString())
        .then((File file) {
      stderr.writeln('- Colors added to Color.dart ✔');
    });
  }

  Future<void> _modifyThemeFile(List<dynamic> colorList) async {
    final List<String> lines =
        await File(path.join('lib', 'theme', 'theme.dart')).readAsLines();

    final StringBuffer buffer = StringBuffer();
    for (final String line in lines) {
      buffer.write('$line\n');

      if (line.contains('//list of themes')) {
        buffer.write('  static const $themeName = CustomTheme(\n');
        for (final Map<String, dynamic> color in colorList) {
          buffer.write("${color['name']}: $colorName.${color['name']},\n");
        }
        buffer.write(
          '${buffer.toString().substring(0, buffer.toString().length - 1)});\n\n',
        );
      }
    }

    await File(path.join('lib', 'theme', 'theme.dart'))
        .writeAsString(buffer.toString())
        .then((File file) {
      stderr.writeln('- Colors added to Color.dart ✔');
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
    final StringBuffer buffer = StringBuffer();
    for (final String line in lines) {
      buffer.write('$line\n');

      if (line.contains('//List of themes')) {
        buffer.write(content);
      }
    }

    await File(path.join('lib', 'service', 'theme_service.dart'))
        .writeAsString(buffer.toString())
        .then((File file) {
      stderr.writeln('- theme added to theme_service.dart ✔');
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
        '// https://saynode.ch': <String>[
          "import 'service/theme_service.dart';",
        ],
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
          'http.get error: statusCode= $status, body= ${res.body}',
        );
      }
      final Map<String, dynamic> data = jsonDecode(res.body);
      if (data['error'] == true) {
        throw Exception('Figma returned an error: ${data['status']}');
      }
      stderr.writeln('got styles');
      return (data['meta'] as Map<String, dynamic>)['styles'];
    } catch (e) {
      stderr.writeln(e);
      exit(1);
    }
  }

  Future<dynamic> getColorsFromStyles(List<dynamic> styles) async {
    try {
      final List<String> ids = <String>[];
      for (final Map<String, dynamic> style in styles) {
        if (style['style_type'] == 'FILL') {
          ids.add(style['node_id']);
        }
      }
      final Map<String, String> headers = <String, String>{
        'X-FIGMA-TOKEN': figmaToken,
      };

      final Uri url = Uri.parse(
        'https://api.figma.com/v1/files/$figmaFileKey/nodes?ids=${ids.join(',')}',
      );
      stderr.writeln(url);

      final http.Response res = await http.get(url, headers: headers);
      final int status = res.statusCode;
      if (status != 200) throw Exception('http.get error: statusCode= $status');
      final Map<String, dynamic> data = jsonDecode(res.body);
      if (data['error'] == true) {
        throw Exception('Figma returned an error: ${data['status']}');
      }

      final List<Map<String, dynamic>> colors = <Map<String, dynamic>>[];
      for (final String node in ids) {
        // ignore: inference_failure_on_untyped_parameter, always_specify_types
        data['nodes'][node]['document']['fills'].forEach((fill) {
          if (fill['type'] == 'SOLID') {
            colors.add(<String, dynamic>{
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
      stderr.writeln(e);
      exit(1);
    }
  }
}

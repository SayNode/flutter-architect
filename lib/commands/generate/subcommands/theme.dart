import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/util.dart';

class GenerateTheme extends Command {
  late final String figmaFileKey;
  late final String figmaToken;
  late String themeName;
  late String colorName;

  //-- Singleton
  GenerateTheme() {
    // Add parser options or flag here
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
    spinnerLoading(_run);
  }

  _run() async {
    var styles = await getFigmaStyles();
    List colorList = await getColorsFromStyles(styles);
    checkIfAllreadyRun().then((value) async {
      print('value: $value');
      if (value) {
        await _modifyColorFile(colorList);
        await _modifyThemeFile(colorList);
      } else {
        await addAllreadyRun("theme");
        await _addColorFile(colorList);
        await _addThemeFile(colorList);
      }
    });

    await formatCode();
  }

  bool isCamelCase(String s) {
    return RegExp(r'^[a-z]+(?:[A-Z][a-z]+)*$').hasMatch(s);
  }

  void _setThemeName() {
    var tempThemeName = '';
    for (var i = 0; i < 10; i++) {
      stdout.writeln('Enter the name of your new theme:');
      tempThemeName = stdin.readLineSync() ?? '';
      if (isCamelCase(tempThemeName)) {
        break;
      }
      stdout.writeln(
          'The name of your theme must be in camel case (e.g. myTheme).');
    }
    themeName = tempThemeName;
    colorName = '${themeName[0].toUpperCase()}${themeName.substring(1)}Color';
    stdout.writeln('Success!');
  }

  Future<void> _addColorFile(List colorList) async {
    String content =
        "import 'package:flutter/material.dart';\n class $colorName {\n";
    for (var color in colorList) {
      content +=
          "static const Color ${color['name']} = Color.fromRGBO(${color['r']}, ${color['g']}, ${color['b']}, ${color['a']});\n\n";
    }
    content += '}';
    File(path.join('lib', 'theme', 'color.dart')).writeAsString(content);
  }

  Future<void> _modifyColorFile(List colorList) async {
    File(path.join('lib', 'theme', 'color.dart'))
        .readAsLines()
        .then((List<String> lines) {
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

      File(path.join('lib', 'theme', 'color.dart'))
          .writeAsString(colorFileContent)
          .then((file) {
        print('- Colors added to Color.dart ✔');
      });
    });
  }

  _addThemeFile(List colorList) {
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

    File(path.join('lib', 'theme', 'theme.dart')).writeAsString(content);
  }

  _modifyThemeFile(List colorList) async {
    File(path.join('lib', 'theme', 'theme.dart'))
        .readAsLines()
        .then((List<String> lines) {
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

      File(path.join('lib', 'theme', 'theme.dart'))
          .writeAsString(content)
          .then((file) {
        print('- Colors added to Color.dart ✔');
      });
    });
  }

  Future<bool> checkIfAllreadyRun() async {
    return await File('added_boilerplate.txt')
        .readAsLines()
        .then((List<String> lines) {
      for (var line in lines) {
        print('line: $line');
        print(line.contains('theme'));
        if (line.contains('theme')) {
          return true;
        }
      }
      return false;
    });
  }

  getFigmaStyles() async {
    try {
      final headers = {
        'X-FIGMA-TOKEN': figmaToken,
      };

      final url =
          Uri.parse('https://api.figma.com/v1/files/$figmaFileKey/styles');

      final res = await http.get(url, headers: headers);
      final status = res.statusCode;
      if (status != 200) throw Exception('http.get error: statusCode= $status');
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

  getColorsFromStyles(List styles) async {
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
              'name': data['nodes'][node]['document']['name'],
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

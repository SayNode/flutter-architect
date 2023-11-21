import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/util.dart';

class GenerateTypography extends Command {
  late final String figmaFileKey;
  late final String figmaToken;

  //-- Singleton
  GenerateTypography() {
    // Add parser options or flag here
  }

  @override
  String get description =>
      'Create typography files and boilerplate code from Figma styles.';

  @override
  String get name => 'typography';

  @override
  void run() async {
    spinnerLoading(_run);
  }

  _run() async {
    stdout.writeln('Enter the file key of your Figma file:');
    figmaFileKey = stdin.readLineSync() ?? '';
    stdout.writeln('Enter your Figma personal access token:');
    figmaToken = stdin.readLineSync() ?? '';
    var styles = await getFigmaStyles();

    checkIfAllreadyRun().then((value) async {
      await addAllreadyRun('typography');
      var textStyles = await getTextStyles(styles);
      await addTypographyFile(textStyles);
      await dartFixCode();
      await formatCode();
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

  addTypographyFile(List textStyleList) async {
    print(textStyleList);
    await addDependencyToPubspec("google_fonts", null);
    String content =
        "import 'package:flutter/material.dart'; \nimport 'package:google_fonts/google_fonts.dart'; \nclass LegacyMainConstants { \nfinal Color color; \nLegacyMainConstants(this.color); \n//List of textstyles\n";
    for (var textStyle in textStyleList) {
      content +=
          "TextStyle get ${textStyle['name']} => TextStyle( \nfontSize: ${textStyle['fontSize']}, \ncolor: color, \nfontFamily: '${textStyle['fontFamily']}', \nfontWeight: FontWeight.w${textStyle['fontWeight']}, \n);\n";
    }
    content +=
        'factory LegacyMainConstants.fromColor(Color color) { \nreturn LegacyMainConstants(color); \n} \n}';
    File(path.join('lib', 'theme', 'typography.dart')).writeAsString(content);
  }

  getTextStyles(List styles) async {
    List<String> ids = [];
    for (var style in styles) {
      if (style['style_type'] == 'TEXT') {
        ids.add(style['node_id']);
      }
    }
    final headers = {
      'X-FIGMA-TOKEN': figmaToken,
    };

    final url = Uri.parse(
        'https://api.figma.com/v1/files/$figmaFileKey/nodes?ids=${ids.join(',')}');
    final res = await http.get(url, headers: headers);
    final status = res.statusCode;
    if (status != 200) throw Exception('http.get error: statusCode= $status');
    Map data = jsonDecode(res.body);
    if (data['error'] == true) {
      throw Exception('Figma returned an error: ${data['status']}');
    }
    List textStyles = [];
    for (var node in ids) {
      var styleMap = data['nodes'][node]['document']['style'];
      textStyles.add({
        'fontFamily': styleMap['fontFamily'],
        'fontSize': styleMap['fontSize'],
        'fontWeight': styleMap['fontWeight'],
        'name': lowerCamelCase(data['nodes'][node]['document']['name'])
      });
    }
    return textStyles;
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
}

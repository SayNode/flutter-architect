import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/util.dart';

class GenerateTypographyService extends Command {
  late final String figmaFileKey;
  late final String figmaToken;

  //-- Singleton
  GenerateTypographyService() {
    // Add parser options or flag here
    argParser.addFlag('force',
        defaultsTo: false, help: 'Force replace in case it already exists.');
    argParser.addFlag('remove',
        defaultsTo: false, help: 'Remove in case it already exists.');
  }

  @override
  String get description =>
      'Create typography files and boilerplate code from Figma styles;';

  @override
  String get name => 'typography';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    stdout.writeln('Enter the file key of your Figma file:');
    figmaFileKey = stdin.readLineSync() ?? '';
    stdout.writeln('Enter your Figma personal access token:');
    figmaToken = stdin.readLineSync() ?? '';
    var styles = await _getFigmaStyles();

    bool alreadyBuilt = await checkIfAlreadyRunWithReturn("typography");
    bool force = argResults?['force'] ?? false;
    bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Typography...');
        await addAlreadyRun('typography');
        var textStyles = await _getTextStyles(styles);
        addDependenciesToPubspecSync(["google_fonts"], null);
        await _addTypographyFile(textStyles);
      },
      remove: () async {
        print('Removing Typography...');
        await removeAlreadyRun('typography');
        removeDependenciesFromPubspecSync(["google_fonts"], null);
        await _removeTypographyFile();
      },
      rejectAdd: () async {
        print("Can't add Typography as it's already configured.");
      },
      rejectRemove: () async {
        print("Can't remove Typography as it's not yet configured.");
      },
    );
    formatCode();
    dartFixCode();
  }

  Future<void> _removeTypographyFile() async {
    await File(path.join('lib', 'theme', 'typography.dart')).delete();
  }

  Future<void> _addTypographyFile(List textStyleList) async {
    print(textStyleList);
    String content =
        "import 'package:flutter/material.dart'; \nimport 'package:google_fonts/google_fonts.dart'; \nclass CustomTypography { \nfinal Color color; \nCustomTypography(this.color); \n//List of textstyles\n";
    for (var textStyle in textStyleList) {
      content +=
          "TextStyle get ${textStyle['name']} => TextStyle( \nfontSize: ${textStyle['fontSize']}, \ncolor: color, \nfontFamily: '${textStyle['fontFamily']}', \nfontWeight: FontWeight.w${textStyle['fontWeight']}, \n);\n";
    }
    content +=
        'factory CustomTypography.fromColor(Color color) { \nreturn CustomTypography(color); \n} \n}';
    File(path.join('lib', 'theme', 'typography.dart')).writeAsString(content);
  }

  Future<dynamic> _getTextStyles(List styles) async {
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

  Future<dynamic> _getFigmaStyles() async {
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

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../../../util.dart';

extension StringCapitalize on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}

class GenerateTypographyService extends Command {

  //-- Singleton
  GenerateTypographyService() {
    // Add parser options or flag here
    argParser.addFlag('force', help: 'Force replace in case it already exists.',);
    argParser.addFlag('remove', help: 'Remove in case it already exists.',);
  }
  late final String figmaFileKey;
  late final String figmaToken;

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
    final styles = await _getFigmaStyles();

    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('typography');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Typography...');
        await addAlreadyRun('typography');
        final textStyles = await _getTextStyles(styles);
        addDependenciesToPubspecSync(<String>['google_fonts'], null);
        await _addTypographyFile(textStyles);
      },
      remove: () async {
        print('Removing Typography...');
        await removeAlreadyRun('typography');
        removeDependenciesFromPubspecSync(<String>['google_fonts'], null);
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
    for (final textStyle in textStyleList) {
      content +=
          "TextStyle get k${(textStyle['name'] as String).capitalize} => TextStyle( \nfontSize: ${textStyle['fontSize']}, \ncolor: color, \nfontFamily: '${textStyle['fontFamily']}', \nfontWeight: FontWeight.w${textStyle['fontWeight']}, \n);\n";
    }
    content +=
        'factory CustomTypography.fromColor(Color color) { \nreturn CustomTypography(color); \n} \n}';
    await writeFileWithPrefix(
        path.join('lib', 'theme', 'typography.dart'), content,);
  }

  Future<dynamic> _getTextStyles(List styles) async {
    final List<String> ids = <String>[];
    for (final style in styles) {
      if (style['style_type'] == 'TEXT') {
        ids.add(style['node_id']);
      }
    }
    final Map<String, String> headers = <String, String>{
      'X-FIGMA-TOKEN': figmaToken,
    };

    final Uri url = Uri.parse(
        'https://api.figma.com/v1/files/$figmaFileKey/nodes?ids=${ids.join(',')}',);
    final http.Response res = await http.get(url, headers: headers);
    final int status = res.statusCode;
    if (status != 200) throw Exception('http.get error: statusCode= $status');
    final Map data = jsonDecode(res.body);
    if (data['error'] == true) {
      throw Exception('Figma returned an error: ${data['status']}');
    }
    final List textStyles = <>[];
    for (final String node in ids) {
      final styleMap = data['nodes'][node]['document']['style'];
      textStyles.add(<String, >{
        'fontFamily': styleMap['fontFamily'],
        'fontSize': styleMap['fontSize'],
        'fontWeight': styleMap['fontWeight'],
        'name': lowerCamelCase(data['nodes'][node]['document']['name']),
      });
    }
    return textStyles;
  }

  Future<dynamic> _getFigmaStyles() async {
    try {
      final Map<String, String> headers = <String, String>{
        'X-FIGMA-TOKEN': figmaToken,
      };

      final Uri url =
          Uri.parse('https://api.figma.com/v1/files/$figmaFileKey/styles');

      final http.Response res = await http.get(url, headers: headers);
      final int status = res.statusCode;
      if (status != 200) throw Exception('http.get error: statusCode= $status');
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
}

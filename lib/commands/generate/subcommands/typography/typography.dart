import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../../../util.dart';

extension StringCapitalize on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}

extension StringDecapitalize on String {
  String get decapitalize => '${this[0].toLowerCase()}${substring(1)}';
}

class GenerateTypographyService extends Command<dynamic> {
  //-- Singleton
  GenerateTypographyService() {
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
    final List<dynamic> styles = await _getFigmaStyles();

    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('typography');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        stderr.writeln('Creating Typography...');
        await addAlreadyRun('typography');
        final List<dynamic> textStyles = await _getTextStyles(styles);
        addDependenciesToPubspecSync(<String>['google_fonts'], null);
        await _addTypographyFile(textStyles);
      },
      remove: () async {
        stderr.writeln('Removing Typography...');
        await removeAlreadyRun('typography');
        removeDependenciesFromPubspecSync(<String>['google_fonts'], null);
        await _removeTypographyFile();
      },
      rejectAdd: () async {
        stderr.writeln("Can't add Typography as it's already configured.");
      },
      rejectRemove: () async {
        stderr.writeln("Can't remove Typography as it's not yet configured.");
      },
    );
    formatCode();
    dartFixCode();
  }

  Future<void> _removeTypographyFile() async {
    await File(path.join('lib', 'theme', 'typography.dart')).delete();
  }

  Future<void> _addTypographyFile(List<dynamic> textStyleList) async {
    stderr.writeln(textStyleList);
    final StringBuffer buffer = StringBuffer()
      ..write(
        "import 'package:flutter/material.dart'; \nimport 'package:google_fonts/google_fonts.dart'; \nclass CustomTypography { \nfinal Color color; \nCustomTypography(this.color); \n//List of textstyles\n",
      );

    for (final Map<String, dynamic> textStyle in textStyleList) {
      buffer.write(
        "TextStyle get k${(textStyle['name'] as String).capitalize} => GoogleFonts.${textStyle['fontFamily'].toString().decapitalize}( \nfontSize: ${textStyle['fontSize']}, \ncolor: color, \nfontWeight: FontWeight.w${textStyle['fontWeight']}, \n);\n",
      );
    }
    buffer.write(
      'factory CustomTypography.fromColor(Color color) { \nreturn CustomTypography(color); \n} \n}',
    );
    await writeFileWithPrefix(
      path.join('lib', 'theme', 'typography.dart'),
      buffer.toString(),
    );
  }

  Future<dynamic> _getTextStyles(List<dynamic> styles) async {
    final List<String> ids = <String>[];
    for (final Map<String, dynamic> style in styles) {
      if (style['style_type'] == 'TEXT') {
        ids.add(style['node_id']);
      }
    }
    final Map<String, String> headers = <String, String>{
      'X-FIGMA-TOKEN': figmaToken,
    };

    final Uri url = Uri.parse(
      'https://api.figma.com/v1/files/$figmaFileKey/nodes?ids=${ids.join(',')}',
    );
    final http.Response res = await http.get(url, headers: headers);
    final int status = res.statusCode;
    if (status != 200) throw Exception('http.get error: statusCode= $status');
    final Map<String, dynamic> data = jsonDecode(res.body);
    if (data['error'] == true) {
      throw Exception('Figma returned an error: ${data['status']}');
    }
    final List<Map<String, dynamic>> textStyles = <Map<String, dynamic>>[];
    for (final String node in ids) {
      final Map<String, dynamic> styleMap =
          // ignore: avoid_dynamic_calls
          data['nodes'][node]['document']['style'];
      textStyles.add(<String, dynamic>{
        'fontFamily': styleMap['fontFamily'],
        'fontSize': styleMap['fontSize'],
        'fontWeight': styleMap['fontWeight'],
        // ignore: avoid_dynamic_calls
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
}

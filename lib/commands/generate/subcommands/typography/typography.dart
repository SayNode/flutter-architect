import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;

import '../../../../util/util.dart';
import 'file_manipulators/typography_manipulator.dart';

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
    await _run();
  }

  Future<void> _run() async {
    stdout.writeln('Enter the file key of your Figma file:');
    figmaFileKey = stdin.readLineSync() ?? '';
    stdout.writeln('Enter your Figma personal access token:');
    figmaToken = stdin.readLineSync() ?? '';
    final List<dynamic> styles = await getFigmaStyles();

    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('typography');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        printColor('------- Creating Typography -------\n', ColorText.cyan);
        await addAlreadyRun('typography');
        final List<dynamic> textStyles = await getTextStyles(styles);
        addDependenciesToPubspecSync(<String>['google_fonts'], null);
        await TypographyManipulator(textStyles).create();
      },
      remove: () async {
        printColor('------- Removing Typography -------\n', ColorText.cyan);
        await removeAlreadyRun('typography');
        removeDependenciesFromPubspecSync(<String>['google_fonts'], null);
        await TypographyManipulator(<dynamic>[]).remove();
      },
      rejectAdd: () async {
        printColor(
          "Can't add Typography as it's already configured.",
          ColorText.red,
        );
      },
      rejectRemove: () async {
        printColor(
          "Can't remove Typography as it's not yet configured.",
          ColorText.red,
        );
      },
    );
  }

  Future<dynamic> getTextStyles(List<dynamic> styles) async {
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

  Future<dynamic> getFigmaStyles() async {
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

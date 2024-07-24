// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;

import '../../../../util/util.dart';
import '../../../new/file_manipulators/main_base_file_manipulator.dart';
import '../storage/storage.dart';
import 'file_manipulators/color_manipulator.dart';
import 'file_manipulators/theme_manipulator.dart';
import 'file_manipulators/theme_service_manipulator.dart';

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
      await setThemeName();
    }
    await _run();
  }

  Future<void> _run() async {
    // Check if Shared Storage has already been set up. Theme requires Shared Storage.
    // If not, run GenerateStorageService.runShared().
    final bool value = await checkIfAlreadyRunWithReturn('storage');
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
        printColor('----- Creating Theme $themeName -----\n', ColorText.cyan);
        final List<dynamic> styles = await getFigmaStyles();
        final List<dynamic> colorList = await getColorsFromStyles(styles);
        await addAlreadyRun('theme-$themeName');
        await ColorManipulator(colorName, colorList).create();
        await ThemeManipulator(colorName, themeName, colorList).create();
        await ThemeServiceManipulator(themeName).create();
        await MainBaseFileManipulator().addTheme();
      },
      remove: () async {
        printColor(
          '------- Removing Theme $themeName -------\n',
          ColorText.cyan,
        );
        await removeAlreadyRunStartingWith('theme');
        await ColorManipulator(colorName, <dynamic>[]).remove();
        await ThemeManipulator(colorName, themeName, <dynamic>[]).remove();
        await ThemeServiceManipulator(themeName).remove();
        await MainBaseFileManipulator().removeTheme();
      },
      rejectAdd: () async {
        printColor('------ Updating Theme $themeName ------\n', ColorText.cyan);
        final List<dynamic> styles = await getFigmaStyles();
        final List<dynamic> colorList = await getColorsFromStyles(styles);
        await addAlreadyRun('theme-$themeName');
        await ColorManipulator(colorName, colorList).update();
        await ThemeManipulator(colorName, themeName, colorList).update();
        await ThemeServiceManipulator(themeName).update();
      },
      rejectRemove: () async {
        printColor(
          "Can't remove Theme as it's not yet configured.",
          ColorText.red,
        );
      },
    );
  }

  /// Check if [s] is camelCase.
  bool isCamelCase(String s) {
    return RegExp(r'^[a-z]+(?:[A-Z][a-z]+)*$').hasMatch(s);
  }

  /// Waits for the user to enter a valid camelCase theme name.
  /// Sets the [themeName] and [colorName] variables.
  Future<void> setThemeName() async {
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
      printColor(e.toString(), ColorText.red);
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
      printColor(e.toString(), ColorText.red);
      exit(1);
    }
  }
}

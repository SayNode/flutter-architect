import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;

class GenerateTheme extends Command {
  late final String figmaFileKey;
  late final String figmaToken;

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
    stdout.writeln('Success!');
    stdout.writeln('Enter your Figma personal access token:');
    figmaToken = stdin.readLineSync() ?? '';
    stdout.writeln('Success!');
    await getFigmaStyles();
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
      print(data);
    } catch (e) {
      print(e.toString());
      exit(1);
    }
  }
}

import 'dart:io';

import 'package:args/command_runner.dart';

class Creator extends Command {
  @override
  String get name => 'new';

  @override
  String get description => 'create new project';

  Creator() {
    argParser.addOption(
      'name',
      abbr: 'f',
      help: 'help for new command',
      mandatory: true,
    );
  }

  @override
  Future<void> run() async {
    final String projectName = argResults?['name'];

    stdout.writeln('Type something:');
    final read = stdin.readLineSync() ?? '';
    stdout.writeln('You typed: $read');
    var directory =
        await Directory('build/$projectName').create(recursive: true);
    print(directory.path);
  }
}

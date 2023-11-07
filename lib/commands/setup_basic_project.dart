import 'dart:io';

import 'package:args/command_runner.dart';

class MakeCommand extends Command {
  @override
  String get name => 'factory';

  @override
  String get description => 'create factory';

  MakeCommand() {
    argParser.addOption(
      'name',
      abbr: 'f',
      help: 'help for factory command',
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

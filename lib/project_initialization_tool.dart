import 'dart:io';

import 'package:args/command_runner.dart';

import 'commands/generate/generate.dart';
import 'commands/new/new.dart';

void main(List<String> arguments) {
  exitCode = 0; //presume success

  final CommandRunner<dynamic> commandRunner = CommandRunner<dynamic>(
    'generator',
    'Code Generator for Flutter Projects.',
  )
    ..addCommand(Creator())
    ..addCommand(Generator.instance);

  commandRunner.run(arguments).catchError((dynamic error) {
    if (error is! UsageException) throw error;
    stderr.writeln(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:project_initialization_tool/commands/generate/generate.dart';
import 'package:project_initialization_tool/commands/new/new.dart';

void main(List<String> arguments) {
  exitCode = 0; //presume success

  final CommandRunner commandRunner =
      CommandRunner('generator', 'Code Generator for Flutter Projects.')
        ..addCommand(Creator())
        ..addCommand(Generator.instance);

  commandRunner.run(arguments).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}

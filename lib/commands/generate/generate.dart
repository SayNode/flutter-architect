import 'dart:io';

import 'package:args/command_runner.dart';

class Generator extends Command {
  //-- Singleton
  Generator._privateConstructor() {
    // Add Sub Commands here

    // Add parser options or flag here
  }

  static final Generator instance = Generator._privateConstructor();

  @override
  String get description => 'Generate a boilerplate code.';

  @override
  String get name => 'generate';

  @override
  void run() {
    runner?.runCommand(argResults!).catchError((error) {
      if (error is! UsageException) throw error;
      print(error);
      exit(64); // Exit code 64 indicates a usage error.
    });
  }
}

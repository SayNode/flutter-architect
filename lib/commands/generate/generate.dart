import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/localization.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/storage.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/theme.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/typography.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics.dart';

import 'subcommands/wallet.dart';

class Generator extends Command {
  //-- Singleton
  Generator._privateConstructor() {
    // Add Sub Commands here
    addSubcommand(GenerateTheme());
    addSubcommand(GenerateStorageService());
    addSubcommand(LocalizationGenerator());
    addSubcommand(GenerateTypography());
    addSubcommand(GenerateWalletService());
    addSubcommand(CrashalyticsGenerator());
    // Add parser options or flag here
  }

  static final Generator instance = Generator._privateConstructor();

  @override
  String get description => 'Generate a boilerplate code for the project.';

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

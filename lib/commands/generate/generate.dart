import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/all.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/localization/localization.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/native_splash/splash.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/storage/storage.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/theme/theme.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/typography/typography.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics/crashalytics.dart';

import 'subcommands/wallet/wallet.dart';

class Generator extends Command {
  //-- Singleton
  Generator._privateConstructor() {
    // Add Sub Commands here
    addSubcommand(GenerateThemeService());
    addSubcommand(GenerateStorageService());
    addSubcommand(GenerateLocalizationService());
    addSubcommand(GenerateTypographyService());
    addSubcommand(GenerateWalletService());
    addSubcommand(GenerateCrashalyticsService());
    addSubcommand(GenerateSplashService());
    addSubcommand(AllGenerator());
    // Add parser options or flag here
  }

  static final Generator instance = Generator._privateConstructor();

  @override
  String get description => 'Generate a boilerplate code for the project;';

  @override
  String get name => 'generate';

  @override
  void run() {
    runner?.runCommand(argResults!).catchError((error) {
      if (error is! UsageException) throw error;
      print('Error $error');
      exit(64); // Exit code 64 indicates a usage error.
    });
  }
}

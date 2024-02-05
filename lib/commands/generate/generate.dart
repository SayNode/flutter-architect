import 'dart:io';

import 'package:args/command_runner.dart';

import 'subcommands/all.dart';
import 'subcommands/api/api.dart';
import 'subcommands/crashalytics/crashalytics.dart';
import 'subcommands/localization/localization.dart';
import 'subcommands/native_splash/splash.dart';
import 'subcommands/page/page.dart';
import 'subcommands/signin/signin.dart';
import 'subcommands/storage/storage.dart';
import 'subcommands/theme/theme.dart';
import 'subcommands/typography/typography.dart';
import 'subcommands/wallet/wallet.dart';

class Generator extends Command<dynamic> {
  //-- Singleton
  Generator._privateConstructor() {
    // Add Sub Commands here (for project components)
    addSubcommand(GenerateStorageService());
    addSubcommand(GenerateThemeService());
    addSubcommand(GenerateTypographyService());
    addSubcommand(GenerateLocalizationService());
    addSubcommand(GenerateWalletService());
    addSubcommand(GenerateCrashalyticsService());
    addSubcommand(GenerateSplashService());
    addSubcommand(GenerateAPIService());
    addSubcommand(GenerateSigninService());

    // Utilitary commands
    addSubcommand(AllGeneratorService());
    addSubcommand(GeneratePageService());
  }

  static final Generator instance = Generator._privateConstructor();

  @override
  String get description => 'Generate a boilerplate code for the project;';

  @override
  String get name => 'generate';

  @override
  void run() {
    runner?.runCommand(argResults!).catchError((dynamic error) {
      if (error is! UsageException) throw error;
      stderr.writeln('Error $error');
      exit(64); // Exit code 64 indicates a usage error.
    });
  }
}

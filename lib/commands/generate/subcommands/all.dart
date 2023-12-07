import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/crashalytics/crashalytics.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/localization/localization.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/storage/storage.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/theme/theme.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/typography/typography.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/wallet/wallet.dart';
import 'package:project_initialization_tool/commands/util.dart';

class AllGenerator extends Command {
  @override
  String get description => 'Add every component to this project;';

  @override
  String get name => 'all';

  AllGenerator() {
    // Add parser options or flag here
    argParser.addFlag('force',
        defaultsTo: false, help: 'Force replace in case it already exists.');
  }

  @override
  void run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    var storageService = GenerateStorageService();
    await storageService.runShared();
    await storageService.runSecure();
    var themeService = GenerateThemeService();
    await themeService.run();
    var typographyService = GenerateTypographyService();
    await typographyService.run();
    var localizationService = GenerateLocalizationService();
    await localizationService.run();
    var walletService = GenerateWalletService();
    await walletService.run();
    var crashlyticsService = GenerateCrashalyticsService();
    await crashlyticsService.run();
  }
}

import 'package:args/command_runner.dart';

import '../../../util/util.dart';
import 'api/api.dart';
import 'crashalytics/crashalytics.dart';
import 'localization/localization.dart';
import 'native_splash/splash.dart';
import 'signin/signin.dart';
import 'storage/storage.dart';
import 'theme/theme.dart';
import 'typography/typography.dart';
import 'wallet/wallet.dart';

class AllGeneratorService extends Command<dynamic> {
  AllGeneratorService() {
    // Add parser options or flag here
    argParser.addFlag(
      'force',
      help: 'Force replace in case it already exists.',
    );
  }
  @override
  String get description => 'Add every component to this project;';

  @override
  String get name => 'all';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    final GenerateStorageService storageService = GenerateStorageService();
    await storageService.run();
    final GenerateThemeService themeService = GenerateThemeService();
    await themeService.run();
    final GenerateTypographyService typographyService =
        GenerateTypographyService();
    await typographyService.run();
    final GenerateLocalizationService localizationService =
        GenerateLocalizationService();
    await localizationService.run();
    final GenerateWalletService walletService = GenerateWalletService();
    await walletService.run();
    final GenerateCrashalyticsService crashlyticsService =
        GenerateCrashalyticsService();
    await crashlyticsService.run();
    final GenerateSplashService splashService = GenerateSplashService();
    await splashService.run();
    final GenerateAPIService apiService = GenerateAPIService();
    await apiService.run();
    final GenerateSigninService signinService = GenerateSigninService();
    await signinService.runGoogle();
    await signinService.runApple();
  }
}

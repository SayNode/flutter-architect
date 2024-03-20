import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../util.dart';
import '../api/api.dart';
import 'code/apple.dart' as apple;
import 'code/google.dart' as google;

class GenerateSigninService extends Command<dynamic> {
  GenerateSigninService() {
    // Add parser options or flag here
    argParser
      ..addFlag(
        'force',
        help: 'Force replace in case it already exists.',
      )
      ..addFlag(
        'remove',
        help: 'Remove in case it already exists.',
      )
      ..addFlag(
        'google',
        help: 'Include Google Auth in Auth Service.',
      )
      ..addFlag(
        'apple',
        help: 'Include Apple Auth in Auth Service.',
      );
  }
  @override
  String get description =>
      'Create platform-specific signin options for the project. --google flag will create the Google Signin option. --apple flag will create the Apple Signin option;';

  @override
  String get name => 'signin';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  String get defaultSwitchCaseApple => '''
        case ProviderTypes.apple:
          return false;''';

  String get defaultSwitchCaseGoogle => '''
        case ProviderTypes.google:
          return false;''';

  Future<void> _run() async {
    if (argResults?['google'] || argResults?['apple']) {
      // Check if API Service has already been set up. Signin requires API Service.
      // If not, run GenerateAPIService.run().
      final bool value = await checkIfAlreadyRunWithReturn('api');
      if (!value) {
        final GenerateAPIService apiService = GenerateAPIService();
        await apiService.run();
      }

      if (argResults?['google'] == true) {
        await runGoogle();
      }
      if (argResults?['apple'] == true) {
        await runApple();
      }
    } else {
      stderr.writeln(
        'Please specify which signin service you want to create. Use --help for more info.',
      );
    }
  }

  Future<void> runGoogle() async {
    final bool alreadyBuilt =
        await checkIfAlreadyRunWithReturn('signin-google');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        stderr.writeln('Creating Google Signin Service...');
        await addAlreadyRun('signin-google');
        addDependenciesToPubspecSync(<String>['google_sign_in'], null);
        await _addGoogleAuthChanges();
        formatCode();
        dartFixCode();
        printGoogleInstructions();
      },
      remove: () async {
        stderr.writeln('Removing Google Signin Service...');
        await removeAlreadyRun('signin-google');
        removeDependenciesFromPubspecSync(<String>['google_sign_in'], null);
        await _removeGoogleAuthChanges();
        formatCode();
        dartFixCode();
      },
      rejectAdd: () async {
        stderr.writeln(
          "Can't add the Google Signin option as it's already configured.",
        );
      },
      rejectRemove: () async {
        stderr.writeln(
          "Can't remove the Google Signin option as it's not yet configured.",
        );
      },
    );
  }

  Future<void> runApple() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('signin-apple');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        stderr.writeln('Creating Apple Signin Service...');
        await addAlreadyRun('signin-apple');
        addDependenciesToPubspecSync(<String>['sign_in_with_apple'], null);
        await _addAppleAuthChanges();
        formatCode();
        dartFixCode();
        printAppleInstructions();
      },
      remove: () async {
        stderr.writeln('Removing Apple Signin Service...');
        await removeAlreadyRun('signin-apple');
        removeDependenciesFromPubspecSync(<String>['sign_in_with_apple'], null);
        await _removeAppleAuthChanges();
        formatCode();
        dartFixCode();
      },
      rejectAdd: () async {
        stderr.writeln(
          "Can't add the Apple Signin option as it's already configured.",
        );
      },
      rejectRemove: () async {
        stderr.writeln(
          "Can't remove the Apple Signin option as it's not yet configured.",
        );
      },
    );
  }

  void printGoogleInstructions() {
    printColor(
      '! Make sure you follow the steps in https://pub.dev/packages/google_sign_in to complete the Google Sign In configuration',
      ColorText.green,
    );
  }

  void printAppleInstructions() {
    printColor(
      '! Make sure you follow the steps in https://pub.dev/packages/sign_in_with_apple to complete the Apple Sign In configuration',
      ColorText.green,
    );
  }

  Future<void> _addGoogleAuthChanges() async {
    final String authPath = path.join('lib', 'service', 'auth_service.dart');

    await _removeDefaultSwitchCaseGoogle();

    await addLinesAfterLineInFile(
      authPath,
      <String, List<String>>{
        '// https://saynode.ch': <String>[google.imports()],
        'APIService apiService = Get.put(APIService());': <String>[
          google.initialization(),
        ],
        'void init() {': <String>[google.initContent()],
        'Future<void> _disconnectProviders() async {': <String>[
          google.disconnect(),
        ],
      },
    );

    await addLinesBeforeLineInFile(
      authPath,
      <String, List<String>>{
        'Future<void> _disconnectProviders() async {': <String>[
          google.signIn(),
        ],
        'case ProviderTypes.none:': <String>[google.switchCase()],
      },
    );
  }

  Future<void> _addAppleAuthChanges() async {
    final String authPath = path.join('lib', 'service', 'auth_service.dart');

    await _removeDefaultSwitchCaseApple();

    await addLinesAfterLineInFile(
      authPath,
      <String, List<String>>{
        '// https://saynode.ch': <String>[apple.imports()],
        'Future<void> _disconnectProviders() async {': <String>[
          apple.disconnect(),
        ],
      },
    );

    await addLinesBeforeLineInFile(
      authPath,
      <String, List<String>>{
        'Future<void> _disconnectProviders() async {': <String>[apple.signIn()],
        'case ProviderTypes.none:': <String>[apple.switchCase()],
      },
    );
  }

  Future<void> _removeGoogleAuthChanges() async {
    final String authPath = path.join('lib', 'service', 'auth_service.dart');

    await removeTextFromFile(authPath, google.imports());
    await removeTextFromFile(authPath, google.initialization());
    await removeTextFromFile(authPath, google.initContent());
    await removeTextFromFile(authPath, google.disconnect());
    await removeTextFromFile(authPath, google.signIn());
    await removeTextFromFile(authPath, google.switchCase());
    await _addDefaultSwitchCaseGoogle();
  }

  Future<void> _removeAppleAuthChanges() async {
    final String authPath = path.join('lib', 'service', 'auth_service.dart');

    await removeTextFromFile(authPath, apple.imports());
    await removeTextFromFile(authPath, apple.disconnect());
    await removeTextFromFile(authPath, apple.signIn());
    await removeTextFromFile(authPath, apple.switchCase());
    await _addDefaultSwitchCaseApple();
  }

  Future<void> _addDefaultSwitchCaseApple() async {
    final String authPath = path.join('lib', 'service', 'auth_service.dart');

    await addLinesBeforeLineInFile(
      authPath,
      <String, List<String>>{
        'case ProviderTypes.none:': <String>[defaultSwitchCaseApple],
      },
    );
  }

  Future<void> _removeDefaultSwitchCaseApple() async {
    final String authPath = path.join('lib', 'service', 'auth_service.dart');

    await removeTextFromFile(authPath, defaultSwitchCaseApple);
  }

  Future<void> _addDefaultSwitchCaseGoogle() async {
    final String authPath = path.join('lib', 'service', 'auth_service.dart');

    await addLinesBeforeLineInFile(
      authPath,
      <String, List<String>>{
        'case ProviderTypes.none:': <String>[defaultSwitchCaseGoogle],
      },
    );
  }

  Future<void> _removeDefaultSwitchCaseGoogle() async {
    final String authPath = path.join('lib', 'service', 'auth_service.dart');

    await removeTextFromFile(authPath, defaultSwitchCaseGoogle);
  }
}

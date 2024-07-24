import 'dart:io';

import 'package:args/command_runner.dart';

import '../../../../util/util.dart';
import '../api/api.dart';
import '../api/file_manipulators/auth_service_manipulator.dart';

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
        await AuthServiceManipulator().createGoogleSignIn();
        printGoogleInstructions();
      },
      remove: () async {
        stderr.writeln('Removing Google Signin Service...');
        await removeAlreadyRun('signin-google');
        removeDependenciesFromPubspecSync(<String>['google_sign_in'], null);
        await AuthServiceManipulator().removeGoogleSignIn();
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
        await AuthServiceManipulator().createAppleSignIn();
        dartFormatCode();
        dartFixCode();
        printAppleInstructions();
      },
      remove: () async {
        stderr.writeln('Removing Apple Signin Service...');
        await removeAlreadyRun('signin-apple');
        removeDependenciesFromPubspecSync(<String>['sign_in_with_apple'], null);
        await AuthServiceManipulator().removeAppleSignIn();
        dartFormatCode();
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
}

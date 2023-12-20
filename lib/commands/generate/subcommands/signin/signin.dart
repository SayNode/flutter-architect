import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/generate/subcommands/api/api.dart';
import 'package:project_initialization_tool/commands/generate/subcommands/signin/code/apple.dart'
    as apple;
import 'package:project_initialization_tool/commands/generate/subcommands/signin/code/google.dart'
    as google;
import 'package:project_initialization_tool/commands/util.dart';

class GenerateSigninService extends Command {
  @override
  String get description =>
      'Create platform-specific signin options for the project. --google flag will create the Google Signin option. --apple flag will create the Apple Signin option;';

  @override
  String get name => 'signin';

  GenerateSigninService() {
    // Add parser options or flag here
    argParser.addFlag('force',
        defaultsTo: false, help: 'Force replace in case it already exists.');
    argParser.addFlag('remove',
        defaultsTo: false, help: 'Remove in case it already exists.');
    argParser.addFlag('google',
        defaultsTo: false, help: 'Include Google Auth in Auth Service.');
    argParser.addFlag('apple',
        defaultsTo: false, help: 'Include Apple Auth in Auth Service.');
  }

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    if (argResults?['google'] || argResults?['apple']) {
      // Check if API Service has already been set up. Signin requires API Service.
      // If not, run GenerateAPIService.run().
      bool value = await checkIfAlreadyRunWithReturn("api");
      if (!value) {
        var apiService = GenerateAPIService();
        await apiService.run();
      }

      if (argResults?['google'] == true) {
        await runGoogle();
      }
      if (argResults?['apple'] == true) {
        await runApple();
      }
    } else {
      print(
          'Please specify which signin service you want to create. Use --help for more info.');
    }
  }

  Future<void> runGoogle() async {
    bool alreadyBuilt = await checkIfAlreadyRunWithReturn("signin-google");
    bool force = argResults?['force'] ?? false;
    bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Google Signin Service...');
        await addAlreadyRun("signin-google");
        addDependenciesToPubspecSync(['google_sign_in'], null);
        await _addGoogleAuthChanges();
        formatCode();
        dartFixCode();
        printGoogleInstructions();
      },
      remove: () async {
        print('Removing Google Signin Service...');
        await removeAlreadyRun("signin-google");
        removeDependenciesFromPubspecSync(['google_sign_in'], null);
        await _removeGoogleAuthChanges();
        formatCode();
        dartFixCode();
      },
      rejectAdd: () async {
        print("Can't add the Google Signin option as it's already configured.");
      },
      rejectRemove: () async {
        print(
            "Can't remove the Google Signin option as it's not yet configured.");
      },
    );
  }

  Future<void> runApple() async {
    bool alreadyBuilt = await checkIfAlreadyRunWithReturn("signin-apple");
    bool force = argResults?['force'] ?? false;
    bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Apple Signin Service...');
        await addAlreadyRun("signin-apple");
        addDependenciesToPubspecSync(['sign_in_with_apple'], null);
        await _addAppleAuthChanges();
        formatCode();
        dartFixCode();
        printAppleInstructions();
      },
      remove: () async {
        print('Removing Apple Signin Service...');
        await removeAlreadyRun("signin-apple");
        removeDependenciesFromPubspecSync(['sign_in_with_apple'], null);
        await _removeAppleAuthChanges();
        formatCode();
        dartFixCode();
      },
      rejectAdd: () async {
        print("Can't add the Apple Signin option as it's already configured.");
      },
      rejectRemove: () async {
        print(
            "Can't remove the Apple Signin option as it's not yet configured.");
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
    String authPath = path.join('lib', 'service', 'auth_service.dart');

    await addLinesAfterLineInFile(
      authPath,
      {
        '/// https://saynode.ch': [google.imports()],
        'APIService apiService = Get.put(APIService());': [
          google.initialization()
        ],
        'void init() {': [google.initContent()],
        'Future<void> _disconnectProviders() async {': [google.disconnect()],
      },
    );

    await addLinesBeforeLineInFile(
      authPath,
      {
        'Future<void> _disconnectProviders() async {': [google.signIn()],
      },
    );
  }

  Future<void> _addAppleAuthChanges() async {
    String authPath = path.join('lib', 'service', 'auth_service.dart');

    await addLinesAfterLineInFile(
      authPath,
      {
        '/// https://saynode.ch': [apple.imports()],
        'Future<void> _disconnectProviders() async {': [apple.disconnect()],
      },
    );

    await addLinesBeforeLineInFile(
      authPath,
      {
        'Future<void> _disconnectProviders() async {': [apple.signIn()],
      },
    );
  }

  Future<void> _removeGoogleAuthChanges() async {
    String authPath = path.join('lib', 'service', 'auth_service.dart');

    await removeTextFromFile(authPath, google.imports());
    await removeTextFromFile(authPath, google.initialization());
    await removeTextFromFile(authPath, google.initContent());
    await removeTextFromFile(authPath, google.disconnect());
    await removeTextFromFile(authPath, google.signIn());
  }

  Future<void> _removeAppleAuthChanges() async {
    String authPath = path.join('lib', 'service', 'auth_service.dart');

    await removeTextFromFile(authPath, apple.imports());
    await removeTextFromFile(authPath, apple.disconnect());
    await removeTextFromFile(authPath, apple.signIn());
  }
}

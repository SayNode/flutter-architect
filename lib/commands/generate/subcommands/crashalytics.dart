import 'package:args/command_runner.dart';
import 'package:project_initialization_tool/commands/util.dart';

class CrashalyticsGenerator extends Command {
  @override
  String get description => 'Create crashalytics files and boilerplate code;';

  @override
  String get name => 'crashalytics';

  @override
  void run() async {
    checkIfAllreadyRun('localization').then((value) async {
      await spinnerLoading(addCrashalyticsTasks);
    });
  }

  addCrashalyticsTasks() async {
    initFirebaseForProject();
  }

  initFirebaseForProject() async {
    // check if firebase is istalled
    bool isfi = await isFirebaseCLIInstalled();
    print(isfi ? 'Firebase CLI is installed' : 'Firebase CLI is not installed');
    if (!isfi) {
      print('Installing Firebase CLI');
      await installFirebaseCLI();
      //TODO: add flutterfire to path
    }
    // check if firebase user is logged in
    await firebaseCLILogin();
    activateFirebaseCLI();

    // install mandatory dependancy
    await installFirebaseDependancy();

    // run flutterfire
    await flutterfireRun();
  }
}

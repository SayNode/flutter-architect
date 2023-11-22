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
    print(
        "This script will add the code required to catch errors and send them to crashalytics");
    print(
        "However, to use this feature, you need to first configure firebase and crashalytics for this project");
    print("You can do this with the following commands:");
    print("`chmod +x ./firebase_configuration.sh`");
    print("`./firebase_configuration.sh`");
    print(
        "if that does work you can follow the official guide for flutter at https://firebase.google.com/docs/crashlytics/get-started?platform=flutter");
    // TODO add code to add crashalytics to the project

    // TODO add simple dialog for errors
  }
}

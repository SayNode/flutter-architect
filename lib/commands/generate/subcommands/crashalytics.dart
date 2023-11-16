import 'package:args/command_runner.dart';
import 'package:project_initialization_tool/commands/util.dart';

class CrashalyticsGenerator extends Command {
  @override
  String get description => 'Create crashalytics files and boilerplate code;';

  @override
  String get name => 'crashalytics';

  @override
  void run() async {
    await spinnerLoading(_run);
  }

  _run() async {
    await addCrashalyticsToMain();
  }

  addCrashalyticsToMain() async {}
}

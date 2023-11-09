import 'package:args/command_runner.dart';

class CrashalyticsGenerator extends Command {
  @override
  String get description => 'Create crashalytics files and boilerplate code;';

  @override
  String get name => 'crashalytics';

  @override
  void run() {
    addCrashalyticsToMain();
  }

  addCrashalyticsToMain() {}
}

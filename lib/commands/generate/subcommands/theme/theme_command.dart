import 'package:args/command_runner.dart';

class ThemeCommand extends Command<dynamic> {
  //-- Singleton
  ThemeCommand() {
    // Add parser options or flag here
    argParser
      ..addFlag(
        'force',
        help: 'Force replace in case it already exists.',
      )
      ..addFlag(
        'remove',
        help: 'Remove in case it already exists.',
      );
  }

  @override
  String get description =>
      'Create theme files and boilerplate code from Figma styles;';

  @override
  String get name => 'theme';

  @override
  Future<void> run() async {}
}

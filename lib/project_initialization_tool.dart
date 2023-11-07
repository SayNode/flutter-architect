import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:project_initialization_tool/commands/setup_basic_project.dart';

void main(List<String> arguments) {
  final runner = CommandRunner('Dart cli', 'Dart cli');
  runner.addCommand(MakeCommand());

  try {
    runner.run(arguments);
  } catch (error) {
    print(red('error $error'));
  }
}

import '../../../interfaces/file_manipulator.dart';

class MainFileManipulator extends FileManipulator {
  @override
  String content() {
    return """
import 'interface/main_interface.dart';

void main() {
  Main().main();
}

class Main extends MainInterface {}
""";
  }

  @override
  String get name => 'Main';

  @override
  String get path => 'lib/main.dart';
}

import '../../../interfaces/file_manipulator.dart';

class MainFileManipulator extends FileManipulator {
  @override
  String content() {
    return """
import 'base/main_base.dart';

void main() {
  Main().main();
}

class Main extends MainBase {}
""";
  }

  @override
  String get name => 'Main';

  @override
  String get path => 'lib/main.dart';
}

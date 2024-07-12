import '../../../interfaces/file_manipulator.dart';
import '../../../util/util.dart';

class MainFileManipulator extends FileManipulator {
  @override
  String content() {
    return """
import 'base/main_interface.dart';

void main() {
  Main().main();
}

class Main extends MainInterface {
  @override
  Future<void> initializeServices() async {
    // Initialize services:
    await super.initializeServices();
  }
}""";
  }

  @override
  String get name => 'Main';

  @override
  String get path => 'lib/main.dart';

  Future<void> createAuthServiceInit() async {
    await addLinesAfterLineInFile(
      path,
      <String, List<String>>{
        '// https://saynode.ch': <String>[
          "import 'service/auth_service.dart';",
        ],
        '// Initialize services:': <String>[
          'Get.find<AuthService>().init();',
        ],
      },
    );
  }
}

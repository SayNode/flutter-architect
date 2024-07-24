import 'dart:io';

import 'package:path/path.dart' as path_package;

import '../../../interfaces/file_manipulator.dart';
import '../../../util/util.dart';

class DependencyInjection extends FileManipulator {
  DependencyInjection({required String projectName})
      : _projectName = projectName;
  final String _projectName;

  String get projectName => _projectName;

  @override
  Future<void> create() async {
    // TODO: implement create
    await _updateMain();
    return super.create();
  }

  @override
  String get name => 'MainBindings';

  @override
  String get path => 'lib/service/main_bindings.dart';

  @override
  String content() {
    return """
// ignore_for_file: cascade_invocations
import 'package:get/get.dart';
import 'package:$projectName/util/constants.dart';

class MainBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    //inject services and controllers
    _injectServices();
    _injectControllers();
  }

  void _injectServices() {
    // Services injection:
  }

  void _injectControllers() {
    // Controllers injection:
  }
}
""";
  }

  Future<void> addService(String serviceName, String servicePath) async {
    await addLinesAfterLineInFile(
      path,
      <String, List<String>>{
        '// https://saynode.ch': <String>[
          "import '../$servicePath';",
        ],
        '// Services injection:': <String>[
          'Get.lazyPut($serviceName.new);',
        ],
      },
    );
  }

  Future<void> addController(String serviceName, String servicePath) async {
    await addLinesAfterLineInFile(
      path,
      <String, List<String>>{
        '// https://saynode.ch': <String>[
          "import '../$servicePath';",
        ],
        '// Services injection:': <String>[
          'Get.lazyPut($serviceName.new);',
        ],
      },
    );
  }

  Future<void> _updateMain() async {
    final String mainPath = path_package.join('lib', 'main.dart');
    await addLinesAfterLineInFile(
      mainPath,
      <String, List<String>>{
        'void main() async {': <String>[
          ' final MainBindings mainBinding = MainBindings();',
          ' await mainBinding.dependencies();',
        ],
        '// https://saynode.ch': <String>[
          "import 'service/main_bindings.dart';",
        ],
      },
    );
  }

  Future<void> removeService(String serviceName, String servicePath) async {
    await removeLinesFromFile(
      path,
      <String>[
        'Get.lazyPut($serviceName.new);',
        "import '../$servicePath';",
      ],
    );
  }
}

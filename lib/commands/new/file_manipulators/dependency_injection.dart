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
    //Services injection
  }

  void _injectControllers() {
    //Controllers injection
  }
}
""";
  }

  Future<void> addService(
    String serviceName, {
    required String servicePath,
    bool initialize = false,
  }) async {
    final File file = File(path);
    final List<String> lines = (await file.readAsString()).split('\n');
    final List<String> newLines = <String>[];
    for (final String line in lines) {
      newLines.add(line);
      // if (line.contains('_injectControllers();') && initialize) {
      //   newLines.add('\nGet.lazyPut($serviceName.new);');
      //   break;
      // }
      if (line.contains("import 'package:get/get.dart';") && initialize) {
        String serviceFileName =
            servicePath.substring(0, servicePath.indexOf('.'));
        serviceFileName =
            serviceFileName.substring(serviceFileName.lastIndexOf('/') + 1);
        newLines.add(
          "\nimport '$serviceFileName.dart';",
        );
      }
      if (line.contains('    //Services injection') && initialize) {
        newLines
          ..add('\n')
          ..add('Get.lazyPut($serviceName.new);');
      }
    }

    await file.writeAsString(newLines.join('\n'));
  }

  Future<void> addController(String controllerName) async {
    final File file = File(path);
    final List<String> lines = (await file.readAsString()).split('\n');
    final List<String> newLines = <String>[];
    bool foundInjectServices = false;
    for (final String line in lines) {
      newLines.add(line);

      if (foundInjectServices && line.trim() == '}') {
        newLines.add('\nGet.lazyPut($controllerName.new);');
        foundInjectServices = false;
      }

      if (line.contains('void _injectControllers() {')) {
        foundInjectServices = true;
      }
    }

    await file.writeAsString(newLines.join('\n'));
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

  Future<void> removeService(String serviceName) async {
    await removeLinesFromFile(
      path,
      <String>[
        'Get.lazyPut(ConnectivityService.new);',
        "import 'connectivity_service.dart';",
      ],
    );
  }
}

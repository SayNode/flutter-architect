import 'dart:io';

import 'package:path/path.dart' as path_package;

import '../../../interfaces/file_manipulator.dart';
import '../../../util/util.dart';

class DependencyInjection extends FileManipulator {
  //NOTE: project name needs to be set before running create command for now
  String projectName = '';
  @override
  Future<void> create() async {
    // TODO: implement create
    await _updateMain();
    return super.create();
  }

  @override
  String get name => 'MainBindings';

  @override
  String get path => (projectName.isNotEmpty)
      ? '$projectName/lib/service/main_bindings.dart'
      : 'lib/service/main_bindings.dart';

  @override
  String content() {
    return """
import 'package:get/get.dart';

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

  Future<void> addService(String serviceName, {bool initialize = false}) async {
    final File file = File(path);
    final List<String> lines = (await file.readAsString()).split('\n');
    final List<String> newLines = <String>[];
    bool foundInjectServices = false;
    for (final String line in lines) {
      newLines.add(line);
      if (line.contains('_injectControllers();') && initialize) {
        newLines.add('\nGet.lazyPut($serviceName.new);');
        break;
      }

      if (foundInjectServices && line.trim() == '}') {
        newLines.add('\nGet.lazyPut($serviceName.new);');
        foundInjectServices = false;
      }

      if (line.contains('void _injectServices() {')) {
        foundInjectServices = true;
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
    final String mainPath = path_package.join(projectName, 'lib', 'main.dart');
    await addLinesAfterLineInFile(
      mainPath,
      <String, List<String>>{
        'void main() async {': <String>[
          'final MainBindings mainBinding = MainBindings();',
          'await mainBinding.dependencies();',
        ],
        '// https://saynode.ch': <String>[
          "import 'service/main_bindings.dart';",
        ],
      },
    );
  }
}

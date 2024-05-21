import 'dart:io';

import '../../../interfaces/file_manipulator.dart';

class DependencyInjection extends FileManipulator {
  @override
  String get name => 'MainBindings';

  @override
  String get path => 'lib/service/main_bindings.dart';

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
}

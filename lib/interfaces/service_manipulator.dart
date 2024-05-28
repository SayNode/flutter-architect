import '../commands/new/files/dependency_injection.dart';
import 'file_manipulator.dart';

///Interface for Service Manipulators
abstract class ServiceManipulator extends FileManipulator {

  @override
  Future<void> create({String projectName = 'Service', bool initialize = false}) {
    final DependencyInjection dependencyInjection = DependencyInjection(projectName: projectName);
    dependencyInjection.addService(name, initialize: initialize);
    return super.create();
  }

  @override

  ///WIP -- do not use
  Future<void> deleteFile() {
    //dependencyInjection.removeService(name);
    return super.deleteFile();
  }
}

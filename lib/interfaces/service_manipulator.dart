import '../commands/new/files/dependency_injection.dart';
import 'file_manipulator.dart';

///Interface for Service Manipulators
abstract class ServiceManipulator extends FileManipulator {
  @override
  Future<void> create(
      {String projectName = 'Service', bool initialize = false}) {
    return super.create();
  }

  @override

  ///WIP -- do not use
  Future<void> deleteFile() {
    //dependencyInjection.removeService(name);
    return super.deleteFile();
  }
}

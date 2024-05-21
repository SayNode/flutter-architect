import '../commands/new/files/dependency_injection.dart';
import 'file_manipulator.dart';

///Interface for Service Manipulators
abstract class ServcieManipulator extends FileManipulator {
  final DependencyInjection dependencyInjection = DependencyInjection();
  @override
  Future<void> create({bool initialize = false}) {
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

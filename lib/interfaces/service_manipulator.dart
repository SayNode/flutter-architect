import '../commands/new/file_manipulators/dependency_injection.dart';
import 'file_manipulator.dart';

///Interface for Service Manipulators
abstract class ServiceManipulator extends FileManipulator {
  final DependencyInjection dependencyInjection =
      DependencyInjection(projectName: 'Service');
  @override
  Future<void> create({
    String projectName = 'Service',
    bool initialize = false,
  }) {
    dependencyInjection.addService(
      name,
      servicePath: path,
      initialize: initialize,
    );
    return super.create();
  }

  ///WIP -- do not use
  Future<void> remove() async {
    await dependencyInjection.removeService(name);

    return super.deleteFile();
  }
}

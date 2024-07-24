import '../commands/new/file_manipulators/dependency_injection.dart';
import 'file_manipulator.dart';

///Interface for Service Manipulators
abstract class ServiceManipulator extends FileManipulator {
  final DependencyInjection dependencyInjection =
      DependencyInjection(projectName: 'Service');
  @override
  Future<void> create({
    String projectName = 'Service',
  }) async {
    await super.create();
    await dependencyInjection.addService(
      name,
      path.substring(4, path.length),
    );
  }

  @override
  Future<void> remove() async {
    await dependencyInjection.removeService(
      name,
      path.substring(4, path.length),
    );
    return super.remove();
  }
}

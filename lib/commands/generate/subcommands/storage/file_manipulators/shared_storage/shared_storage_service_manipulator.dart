import '../../../../../../interfaces/service_manipulator.dart';

class SharedStorageServiceManipulator extends ServiceManipulator {
  @override
  String get name => 'SharedStorageService';

  @override
  String get path => 'lib/service/storage/shared_storage_service.dart';

  @override
  String content() => """
import '../../base/storage/shared_storage_base_service.dart';

class SharedStorageService extends SharedStorageBaseService {}""";
}

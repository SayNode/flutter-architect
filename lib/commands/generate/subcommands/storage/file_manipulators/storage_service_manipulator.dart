import '../../../../../interfaces/service_manipulator.dart';

class StorageServiceManipulator extends ServiceManipulator {
  @override
  String get name => 'StorageService';

  @override
  String get path => 'lib/service/storage/storage_service.dart';

  @override
  String content() {
    return """
import '../../base/storage/storage_base_service.dart';

class StorageService extends StorageBaseService {
  @override
  Future<void> init() async {
    // Storage init:
    await super.init();
  }
}""";
  }
}

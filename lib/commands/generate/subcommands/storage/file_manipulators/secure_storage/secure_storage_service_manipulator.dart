import '../../../../../../interfaces/service_manipulator.dart';

class SecureStorageServiceManipulator extends ServiceManipulator {
  @override
  String get name => 'SecureStorageService';

  @override
  String get path => 'lib/service/storage/secure_storage_service.dart';

  @override
  String content() => """
import '../../base/storage/secure_storage_base_service.dart';

class SecureStorageService extends SecureStorageBaseService {}""";
}

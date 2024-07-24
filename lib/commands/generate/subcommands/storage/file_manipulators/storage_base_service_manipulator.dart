import '../../../../../interfaces/file_manipulator.dart';

class StorageBaseServiceManipulator extends FileManipulator {
  @override
  String get name => 'StorageBaseService';

  @override
  String get path => 'lib/base/storage/storage_base_service.dart';

  @override
  String content() => """
import 'package:get/get.dart';

import '../../service/storage/secure_storage_service.dart';
import '../../service/storage/shared_storage_service.dart';

class StorageBaseService extends GetxService {
  SecureStorageService get secure => Get.find<SecureStorageService>();
  SharedStorageService get shared => Get.find<SharedStorageService>();

  Future<void> init() async {
    await secure.init();
    await shared.init();
  }
}""";
}

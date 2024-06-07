String content() => """
import 'package:get/get.dart';

import 'secure_storage_service.dart';
import 'shared_storage_service.dart';

class StorageService extends GetxService {
  SecureStorageService get secure => Get.find<SecureStorageService>();
  SharedStorageService get shared => Get.find<SharedStorageService>();

  Future<void> init() async {
    await secure.init();
    await shared.init();
  }
}""";

import '../../../../../interfaces/service_manipulator.dart';

class ConnectivityBaseServiceManipulator extends ServiceManipulator {
  @override
  String get name => 'ConnectivityBaseService';

  @override
  String get path => 'lib/base/connectivity_base_service.dart';

  @override
  String content() {
    return """
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../page/lost_connection_page.dart';

class ConnectivityBaseService extends GetxService {
  void init() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult? result) {
      if (result == null || result == ConnectivityResult.none) {
        Get.to<void>(
          () => const LostConnectionPage(),
          transition: Transition.cupertino,
        );
      }
    });
    super.onInit();
  }
}""";
  }
}

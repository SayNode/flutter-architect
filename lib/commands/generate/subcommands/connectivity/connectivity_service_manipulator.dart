import '../../../../interfaces/service_manipulator.dart';
import '../../../../util/util.dart';

class ConnectivityServiceManipulator extends ServiceManipulator {
  @override
  Future<void> create({
    String projectName = 'Service',
    bool initialize = false,
  }) {
    addDependenciesToPubspecSync(<String>['connectivity_plus'], null);
    return super.create(initialize: initialize);
  }

  @override
  String get name => 'ConnectivityService';

  @override
  String get path => 'lib/service/connectivity_service.dart';

  @override
  Future<void> remove() {
    removeDependenciesFromPubspecSync(<String>['connectivity_plus'], null);
    return super.remove();
  }

  @override
  String content() {
    return """
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../page/lost_connection/lost_connection_page.dart';

class ConnectivityService extends GetxService {
  void init() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.first == ConnectivityResult.none) {
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

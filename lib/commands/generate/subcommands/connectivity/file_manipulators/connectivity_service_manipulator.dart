import '../../../../../interfaces/service_manipulator.dart';

class ConnectivityServiceManipulator extends ServiceManipulator {
  @override
  String get name => 'ConnectivityService';

  @override
  String get path => 'lib/service/connectivity_service.dart';

  @override
  String content() {
    return """
import '../base/connectivity_base_service.dart';

class ConnectivityService extends ConnectivityBaseService {}""";
  }
}

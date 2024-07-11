import '../../../../../interfaces/service_manipulator.dart';

class ApiServiceManipulator extends ServiceManipulator {
  @override
  String get name => 'APIService';

  @override
  String get path => 'lib/service/api_service.dart';

  @override
  String content() {
    return """
import '../base/api_service_interface.dart';

class APIService extends ApiServiceInterface {}""";
  }
}

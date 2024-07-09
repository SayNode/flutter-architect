import '../../../../../interfaces/service_manipulator.dart';

class AuthServiceManipulator extends ServiceManipulator {
  @override
  String get name => 'AuthService';

  @override
  String get path => 'lib/service/auth_service.dart';

  @override
  String content() {
    return """
import '../interface/auth_service_base.dart';

class AuthService extends AuthServiceBase {}
""";
  }
}

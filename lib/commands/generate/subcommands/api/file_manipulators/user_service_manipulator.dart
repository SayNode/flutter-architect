import '../../../../../interfaces/service_manipulator.dart';

class UserServiceManipulator extends ServiceManipulator {
  @override
  String get name => 'UserService';

  @override
  String get path => 'lib/service/user_service.dart';

  @override
  String content() {
    return """
import '../base/user_base_service.dart';

class UserService extends UserBaseService {}""";
  }
}

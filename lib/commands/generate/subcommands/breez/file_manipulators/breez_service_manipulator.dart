import '../../../../../interfaces/service_manipulator.dart';

class BreezServiceManipulator extends ServiceManipulator {
  @override
  String get name => 'BreezService';

  @override
  String get path => 'lib/service/breez_service.dart';

  @override
  String content() {
    return """
import '../base/breez_base_service.dart';

class BreezService extends BreezBaseService {}
""";
  }
}

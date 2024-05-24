import '../../../../interfaces/service_manipulator.dart';
import 'code/theme_service.dart';

class ThemeServiceGenerator extends ServiceManipulator {
  ThemeServiceGenerator({required this.themeName});
  final String themeName;

  @override
  String get path => 'lib/services/theme';

  @override
  String get name => 'theme_service';

  @override
  String content() {
    return themeContent(themeName);
  }
}

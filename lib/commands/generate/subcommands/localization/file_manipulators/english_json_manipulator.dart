import '../../../../../../interfaces/file_manipulator.dart';

class EnglishJsonManipulator extends FileManipulator {
  @override
  String get name => 'en';

  @override
  String get path => 'asset/locale/en.json';

  @override
  String content() {
    return '{}';
  }
}

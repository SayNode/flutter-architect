import '../../../../../../interfaces/file_manipulator.dart';

class MessageManipulator extends FileManipulator {
  @override
  String get name => 'Message';

  @override
  String get path => 'lib/model/message.dart';

  @override
  String content() {
    return """
import 'package:get/get.dart';

class Messages extends Translations {
  Messages({required this.languages});
  final Map<String, Map<String, String>> languages;

  @override
  Map<String, Map<String, String>> get keys {
    return languages;
  }
}""";
  }
}

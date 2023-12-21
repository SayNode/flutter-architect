String content() => """
import 'package:get/get.dart';

class Messages extends Translations {
  Messages({required this.languages});
  final Map<String, Map<String, String>> languages;

  @override
  Map<String, Map<String, String>> get keys {
    return languages;
  }
}""";

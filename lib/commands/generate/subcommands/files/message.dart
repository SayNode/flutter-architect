String content() {
  return "import 'package:get/get.dart'; \nclass Messages extends Translations { \nfinal Map<String, Map<String, String>> languages; \nMessages({required this.languages}); \n@override \nMap<String, Map<String, String>> get keys { \nreturn languages; \n} \n}";
}

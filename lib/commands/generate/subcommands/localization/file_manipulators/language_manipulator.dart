import '../../../../../../interfaces/file_manipulator.dart';

class LanguageManipulator extends FileManipulator {
  @override
  String get name => 'Language';

  @override
  String get path => 'lib/model/language.dart';

  @override
  String content() {
    return '''
class LanguageModel {
  LanguageModel({
    required this.imageUrl,
    required this.languageName,
    required this.countryCode,
    required this.languageCode,
  });

  String imageUrl;
  String languageName;
  String languageCode;
  String countryCode;
}''';
  }
}

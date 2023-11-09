//   File(path.join(directory, 'assets.dart')).writeAsStringSync(content); this is how to write a file


//function to create standard model
  // void createModel() {
  //   File(path.join('model' '.dart')).create(recursive: true).then((File file) {
  //     file.writeAsString(content('test', 'stuff')).then((file) {
  //       print('- Model created successfuly ✔');
  //     });
  //   });
  // }

  // String content(String className, String sufix) {
  //   return 'import \'dart:convert\'; \n\nclass $className$sufix {\n\n  // Ctor\n  const $className$sufix();\n\n  // From JSON\n $className$sufix.fromJSON(_json) {\n    dynamic data = json.decode(_json);\n  }\n\n  // From Map\n $className$sufix.fromMap(Map<dynamic, dynamic> data ) {\n\n  }\n\n  // To Map\n  Map<String, dynamic> toMap() {\n    return {\n    };\n  }\n\n}';
  // }
import 'dart:io';

import '../../../interfaces/file_manipulator.dart';

class ConstantManipulator extends FileManipulator {
  @override
  String get name => 'Constants';

  @override
  String get path => 'lib/util/constants.dart';

  @override
  String content() {
    return '''
class Constants {
  // Add your constants here. Do not remove this comment.
}
''';
  }

  /// Adds a constant to the constants file. [constant] is the name of the constant to add. it should be in the format of 'static const String name = value;' or similar.
  Future<void> addConstant(String constant) async {
    //Todo: add check to make sure the constant is valid
    final File file = File(path);
    final List<String> lines = (await file.readAsString()).split('\n');
    final List<String> newLines = <String>[];
    bool foundConstantAddingSpace = false;
    for (final String line in lines) {
      newLines.add(line);

      if (foundConstantAddingSpace) {
        newLines.add('\n$constant');
        foundConstantAddingSpace = false;
      }

      if (line.contains(
        '// Add your constants here. Do not remove this comment.',
      )) {
        foundConstantAddingSpace = true;
      }
    }

    await file.writeAsString(newLines.join('\n'));
  }
}

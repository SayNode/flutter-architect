import 'dart:io';

import '../util/util.dart';

///Basic class to manipulate files. It can be extended to create more specific file manipulators
abstract class FileManipulator {
  String get path;
  String get name;

  ///Function to create everyting related to the service
  Future<void> create() async {
    await _createFile();
  }

  ///Create the file
  Future<void> _createFile() async {
    await writeFileWithPrefix(
      path,
      content(),
    );
    printColor(
      '$path - successfully created ✔',
      ColorText.green,
    );
  }

  ///Delete the file
  Future<void> remove() async {
    await File(path).delete();
    printColor(
      '$path - successfully removed ✔',
      ColorText.green,
    );
  }

  ///Update the file
  Future<void> updateFile() async {
    await remove();
    await _createFile();
  }

  ///Content of the file
  String content();
}

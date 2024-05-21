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
  }

  ///Delete the file
  Future<void> deleteFile() async {
    await File(path).delete();
  }

  ///Update the file
  Future<void> updateFile() async {
    await deleteFile();
    await _createFile();
  }

  ///Content of the file
  String content();
}

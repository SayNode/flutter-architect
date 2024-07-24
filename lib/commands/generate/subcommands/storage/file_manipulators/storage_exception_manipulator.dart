import '../../../../../interfaces/file_manipulator.dart';

class StorageExceptionManipulator extends FileManipulator {
  @override
  String get name => 'StorageException';

  @override
  String get path => 'lib/model/storage_exception.dart';

  @override
  String content() => r'''
class StorageException implements Exception {
  StorageException(this.message);
  final String message;

  @override
  String toString() {
    return 'StorageException: $message';
  }
}''';
}

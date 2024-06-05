String content() => r'''
class StorageException implements Exception {
  StorageException(this.message);
  final String message;

  @override
  String toString() {
    return 'StorageException: $message';
  }
}''';

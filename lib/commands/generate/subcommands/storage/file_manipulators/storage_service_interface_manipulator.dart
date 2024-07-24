import '../../../../../interfaces/file_manipulator.dart';

class StorageServiceInterfaceManipulator extends FileManipulator {
  @override
  String get name => 'StorageServiceInterface';

  @override
  String get path => 'lib/base/storage/storage_service_interface.dart';

  @override
  String content() => '''
abstract class StorageServiceInterface {
  Future<void> init();

  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);
  Future<int?> readInt(String key);
  Future<void> writeInt(String key, int value);
  Future<double?> readDouble(String key);
  Future<void> writeDouble(String key, double value);
  Future<bool?> readBool(String key);
  Future<void> writeBool(String key, bool value);
  Future<List<String>?> readStringList(String key);
  Future<void> writeStringList(String key, List<String> value);

  Future<void> delete(String key);
  Future<void> deleteAll();
}''';
}

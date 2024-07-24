import '../../../../../../interfaces/file_manipulator.dart';

class SecureStorageBaseServiceManipulator extends FileManipulator {
  @override
  String get name => 'SecureStorageBaseService';

  @override
  String get path => 'lib/base/storage/secure_storage_base_service.dart';

  @override
  String content() => r"""
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../model/storage_exception.dart';
import 'storage_service_interface.dart';

class SecureStorageBaseService extends GetxService
    implements StorageServiceInterface {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  static const String stringListSeparator = ',';

  @override
  Future<void> init() async {
    // No initialization needed
  }

  @override
  Future<String?> readString(String key) {
    return read(key);
  }

  @override
  Future<void> writeString(String key, String value) {
    return write(key, value);
  }

  @override
  Future<int?> readInt(String key) async {
    final String? value = await read(key);
    if (value == null) {
      return null;
    }
    return int.parse(value);
  }

  @override
  Future<void> writeInt(String key, int value) {
    return write(key, value.toString());
  }

  @override
  Future<double?> readDouble(String key) async {
    final String? value = await read(key);
    if (value == null) {
      return null;
    }
    return double.parse(value);
  }

  @override
  Future<void> writeDouble(String key, double value) {
    return write(key, value.toString());
  }

  @override
  Future<bool?> readBool(String key) async {
    final String? value = await read(key);
    if (value == null) {
      return null;
    }
    return value == 'true';
  }

  @override
  Future<void> writeBool(String key, bool value) {
    return write(key, value.toString());
  }

  @override
  Future<List<String>?> readStringList(String key) async {
    final String? value = await read(key);
    if (value == null) {
      return null;
    }
    return value.split(stringListSeparator);
  }

  @override
  Future<void> writeStringList(String key, List<String> value) {
    return write(key, value.join(stringListSeparator));
  }

  Future<String?> read(String key) async {
    final bool keyExists = await storage.containsKey(key: key);
    if (keyExists) {
      final String? storedValue = await storage.read(key: key);
      if (storedValue != null) {
        return storedValue;
      } else {
        throw StorageException('Key $key is null in Secure Storage');
      }
    } else {
      return null;
    }
  }

  Future<void> write(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) async {
    await storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await storage.deleteAll();
  }
}

class SecureStorageException implements Exception {
  SecureStorageException(this.message);
  final String message;
}""";
}

String content() => """
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SecureStorageService extends GetxService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<String> read(String key) async {
    await containsKey(key).then((bool value) async {
      if (value) {
        final String? storedValue = await storage.read(key: key);
        if (storedValue != null) {
          return storedValue;
        } else {
          throw SecureStorageException('Key \$key is null');
        }
      } else {
        throw SecureStorageException('Key \$key not found');
      }
    });
    throw SecureStorageException('Critical Error. This should never happen');
  }

  Future<void> write(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future<void> delete(String key) async {
    await storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    return storage.containsKey(key: key);
  }
}

class SecureStorageException implements Exception {
  SecureStorageException(this.message);
  final String message;
}""";

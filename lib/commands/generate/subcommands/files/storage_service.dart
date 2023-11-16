String content() {
  return """
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> setBool(String key, {required bool value}) async {
    await _prefs.setBool(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  String getString(String key) {
    if (!_prefs.containsKey(key)) {
      throw StorageException('Key \$key not found');
    }
    if (_prefs.getString(key) == null) {
      throw StorageException('Key \$key is null');
    }
    return _prefs.getString(key)!;
  }

  bool getBool(String key) {
    if (!_prefs.containsKey(key)) {
      throw StorageException('Key \$key not found');
    }
    if (_prefs.getBool(key) == null) {
      throw StorageException('Key \$key is null');
    }
    return _prefs.getBool(key)!;
  }

  int getInt(String key) {
    if (!_prefs.containsKey(key)) {
      throw StorageException('Key \$key not found');
    }
    if (_prefs.getInt(key) == null) {
      throw StorageException('Key \$key is null');
    }
    return _prefs.getInt(key)!;
  }

  double getDouble(String key) {
    if (!_prefs.containsKey(key)) {
      throw StorageException('Key \$key not found');
    }
    if (_prefs.getDouble(key) == null) {
      throw StorageException('Key \$key is null');
    }
    return _prefs.getDouble(key)!;
  }

  List<String> getStringList(String key) {
    if (!_prefs.containsKey(key)) {
      throw StorageException('Key \$key not found');
    }
    if (_prefs.getStringList(key) == null) {
      throw StorageException('Key \$key is null');
    }
    return _prefs.getStringList(key)!;
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  Future<void> reload() async {
    await _prefs.reload();
  }
}

class StorageException implements Exception {
  StorageException(this.message);
  final String message;

  @override
  String toString() {
    return 'StorageException: \$message';
  }
}
""";
}

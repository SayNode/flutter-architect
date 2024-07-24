import '../../../../../../interfaces/file_manipulator.dart';
import '../../../../../../util/util.dart';

class SharedStorageBaseServiceManipulator extends FileManipulator {
  @override
  String get name => 'SharedStorageBaseService';

  @override
  String get path => 'lib/base/storage/shared_storage_base_service.dart';

  @override
  Future<void> create() {
    printColor(content(), ColorText.cyan);
    return super.create();
  }

  @override
  String content() => r"""
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/storage_exception.dart';
import 'storage_service_interface.dart';

class SharedStorageBaseService extends GetxService
    implements StorageServiceInterface {
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> writeString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  String? readString(String key) {
    if (!_prefs.containsKey(key)) {
      return null;
    }
    final String? value = _prefs.getString(key);
    if (value == null) {
      throw StorageException('Key $key is null in Shared Storage');
    }
    return value;
  }

  @override
  Future<void> writeInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  int? readInt(String key) {
    if (!_prefs.containsKey(key)) {
      return null;
    }
    final int? value = _prefs.getInt(key);
    if (value == null) {
      throw StorageException('Key $key is null in Shared Storage');
    }
    return value;
  }

  @override
  Future<void> writeDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  @override
  double? readDouble(String key) {
    if (!_prefs.containsKey(key)) {
      return null;
    }
    final double? value = _prefs.getDouble(key);
    if (value == null) {
      throw StorageException('Key $key is null in Shared Storage');
    }
    return value;
  }

  @override
  Future<void> writeBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  bool? readBool(String key) {
    if (!_prefs.containsKey(key)) {
      return null;
    }
    final bool? value = _prefs.getBool(key);
    if (value == null) {
      throw StorageException('Key $key is null in Shared Storage');
    }
    return value;
  }

  @override
  Future<void> writeStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  @override
  List<String>? readStringList(String key) {
    if (!_prefs.containsKey(key)) {
      return null;
    }
    final List<String>? value = _prefs.getStringList(key);
    if (value == null) {
      throw StorageException('Key $key is null in Shared Storage');
    }
    return value;
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    await _prefs.clear();
  }
}""";
}

// This file has been automatically generated by Flutter Architect.
//
// Flutter Architect is a tool that generates boilerplate code for your Flutter projects.
// Flutter Architect was created at SayNode Operations AG by Yann Marti, Francesco Romeo and Pedro Gonçalves.
//
// https://saynode.ch

abstract class StorageServiceInterface {
  Future<void> init();

  Future<String> readString(String key);
  Future<void> writeString(String key, String value);
  Future<int> readInt(String key);
  Future<void> writeInt(String key, int value);
  Future<double> readDouble(String key);
  Future<void> writeDouble(String key, double value);
  Future<bool> readBool(String key);
  Future<void> writeBool(String key, bool value);
  Future<List<String>> readStringList(String key);
  Future<void> writeStringList(String key, List<String> value);

  Future<void> delete(String key);
  Future<void> deleteAll();
}

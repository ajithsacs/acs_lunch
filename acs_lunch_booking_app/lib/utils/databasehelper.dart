import 'package:get_storage/get_storage.dart';
class DatabaseHelper {
  final box = GetStorage();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<void> init() async {
    await GetStorage.init();
  }

  Future<void> deleteDb() async {
    await GetStorage().erase();
  }

  Future<void> insertData(String key, dynamic data) async {
    await box.write(key, data);
  }

  Future<dynamic> getData(String key) async {
    return box.read(key);
  }

  Future<void> deleteData(String key) async {
    await box.remove(key);
  }
}

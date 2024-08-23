import '../../../../../interfaces/file_manipulator.dart';

class UserBaseServiceManipulator extends FileManipulator {
  @override
  String get name => 'UserBaseService';

  @override
  String get path => 'lib/base/user_base_service.dart';

  @override
  String content() {
    return """
import 'package:get/get.dart';

import '../model/user.dart';
import '../model/api_response.dart';
import '../service/api_service.dart';

class UserBaseService extends GetxService {
  Rx<User> user = User().obs;

  void clear() {
    user.value = User();
  }

  Future<void> fetch() async {
    final ApiResponse response = await Get.find<APIService>().get('user');
    if (response.result != null) {
      user.value = User.fromJson(response.result!);
    }
  }

  Future<void> update({
    String? name,
    // Add more fields as needed
  }) async {
    final ApiResponse response = await Get.find<APIService>().put(
      'users/update/',
      body: <String, dynamic>{
        'name': name,
        // Add more fields as needed
      }..removeWhere(
          (dynamic key, dynamic value) => key == null || value == null,
        ),
    );
    if (response.result != null) {
      user.value = User.fromJson(response.result!);
    }
  }
}
""";
  }
}

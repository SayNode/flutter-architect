String content() => """
import 'package:get/get.dart';

import '../model/user.dart';

class UserStateService extends GetxService {
  Rx<User> user = User().obs;

  void clear() {
    user.value = User();
  }
}""";

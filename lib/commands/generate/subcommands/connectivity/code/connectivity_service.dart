String content() => """
import 'dart:async';

import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService extends GetxController {
  Stream<bool> get onConnectivityChanged => Connectivity()
          .onConnectivityChanged
          .map<bool>((List<ConnectivityResult> result) {
        return result.contains(ConnectivityResult.mobile) ||
            result.contains(ConnectivityResult.wifi) ||
            result.contains(ConnectivityResult.ethernet);
      });
}""";

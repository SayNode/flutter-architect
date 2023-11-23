content(String projectName) {
  return """
import 'package:flutter/material.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:get/get.dart';

import 'package:$projectName/page/lost_connection/lost_connection_page.dart';

class NetworkService extends GetxService {
  RxBool isConnectedToInternet = true.obs;
  RxBool onInternetLostPage = false.obs;
  FlutterNetworkConnectivity flutterNetworkConnectivity =
      FlutterNetworkConnectivity(isContinousLookUp: true);

  checkInternetStatus() async {
    isConnectedToInternet.value =
        await flutterNetworkConnectivity.isInternetConnectionAvailable();
    if (onInternetLostPage.value && isConnectedToInternet.value) {
      onInternetLostPage.value = false;
      Get.back();
    }
  }

  Future<void> init() async {
    try {
      isConnectedToInternet.bindStream(
          flutterNetworkConnectivity.getInternetAvailabilityStream());
      ever(isConnectedToInternet, (callback) {
        if (!callback) {
          if (!onInternetLostPage.value) {
            Get.to(() => const LostConnectionPage());
            onInternetLostPage.value = true;
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    super.onInit();
  }
}
  """;
}

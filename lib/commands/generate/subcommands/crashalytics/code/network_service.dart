content(String projectName) => """
// This file has been automatically generated by Flutter Architect.
//
// Flutter Architect is a tool that generates boilerplate code for your Flutter projects.
// Flutter Architect was created at SayNode Operations AG by Yann Marti, Francesco Romeo and Pedro Gonçalves.
//
// https://saynode.ch

// ignore_for_file: inference_failure_on_function_return_type, inference_failure_on_function_invocation
import 'package:flutter/material.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:get/get.dart';

import '../page/lost_connection/lost_connection_page.dart';

class NetworkService extends GetxService {
  RxBool isConnectedToInternet = true.obs;
  RxBool onInternetLostPage = false.obs;
  FlutterNetworkConnectivity flutterNetworkConnectivity =
      FlutterNetworkConnectivity(isContinousLookUp: true);

  Future<void> checkInternetStatus() async {
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
        flutterNetworkConnectivity.getInternetAvailabilityStream(),
      );
      ever(isConnectedToInternet, (bool callback) {
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

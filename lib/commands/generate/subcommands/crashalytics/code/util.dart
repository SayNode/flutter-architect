content() => """
import 'package:flutter/material.dart';
import 'package:get/get.dart';

bool getMaterialAppCalled = false;

double getRelativeWidth(double width) {
  final Size screenSize = MediaQuery.of(Get.context!).size;
  return screenSize.width *
      (width / 428); // TODO: check this value with your current design
}

double getRelativeHeight(double height) {
  final Size screenSize = MediaQuery.of(Get.context!).size;
  return screenSize.height *
      (height / 926); // TODO: check this value with your current design
}""";

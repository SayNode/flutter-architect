content() {
  return """
import 'package:flutter/material.dart';
import 'package:get/get.dart';

bool getMaterialAppCalled = false;

double getRelativeWidth(double width) {
  var screenSize = MediaQuery.of(Get.context!).size;
  return screenSize.width * (width / 428);
}

double getRelativeHeight(double height) {
  var screenSize = MediaQuery.of(Get.context!).size;
  return screenSize.height * (height / 926);
}

//Checks if string is a valid address(42 characters, starts with 0x and is hex)
bool isAddress(String address) {
  if (address.length != 42) {
    return false;
  }
  if (!address.startsWith("0x")) {
    return false;
  }
  try {
    int.parse(address.substring(2), radix: 16);
  } catch (e) {
    return false;
  }
  return true;
}

  """;
}

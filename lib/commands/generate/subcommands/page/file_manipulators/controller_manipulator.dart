import '../../../../../interfaces/file_manipulator.dart';

class ControllerManipulator extends FileManipulator {
  ControllerManipulator(String pascalName, String path) {
    _pascalName = pascalName;
    _path = path;
  }

  late String _pascalName;
  late String _path;

  @override
  String get name => _pascalName;

  @override
  String get path => _path;

  @override
  String content() => """
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ${_pascalName}Controller extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
}""";
}

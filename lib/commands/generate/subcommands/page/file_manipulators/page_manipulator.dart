import '../../../../../interfaces/file_manipulator.dart';

class PageManipulator extends FileManipulator {
  PageManipulator(String snakeName, String pascalName, String path) {
    _snakeName = snakeName;
    _pascalName = pascalName;
    _path = path;
  }

  late String _snakeName;
  late String _pascalName;
  late String _path;

  @override
  String get name => _pascalName;

  @override
  String get path => _path;

  @override
  String content() => """
import 'controller/${_snakeName}_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ${_pascalName}Page extends GetView<${_pascalName}Controller> {
  const ${_pascalName}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}""";
}

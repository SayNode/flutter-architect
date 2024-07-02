String content(String pascal, String snake) => """
import 'controller/${snake}_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ${pascal}Page extends GetView<${pascal}Controller> {
  const ${pascal}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}""";

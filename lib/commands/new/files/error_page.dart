String content() => r"""
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/error_page_controller.dart';

class ErrorPage extends GetView<ErrorController> {
  const ErrorPage({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    Get.put(ErrorController());

    return Scaffold(
      body: Center(
        child: Text(
          'This is the Error Page. You can customize it in error_page.dart.\n$error',
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}""";

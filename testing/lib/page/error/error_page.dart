// This file has been automatically generated by Flutter Architect.
//
// Flutter Architect is a tool that generates boilerplate code for your Flutter projects.
// Flutter Architect was created at SayNode Operations AG by Yann Marti, Francesco Romeo and Pedro Gonçalves.
//
// https://saynode.ch

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
}

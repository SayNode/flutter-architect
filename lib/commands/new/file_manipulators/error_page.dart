import '../../../interfaces/file_manipulator.dart';

class ErrorPageManipulator extends FileManipulator {
  @override
  String get name => 'ErrorPage';

  @override
  String get path => 'lib/page/error/error_page.dart';

  @override
  String content() => r"""
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Text(
          'This is the Error Page. You can customize it in error_page.dart.\n$error',
        ),
      ),
    );
  }
}""";
}

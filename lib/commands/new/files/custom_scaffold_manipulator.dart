import '../../../interfaces/file_manipulator.dart';

class CustomScaffoldManipulator extends FileManipulator {
  @override
  String get name => 'CustomScaffold';

  @override
  String get path => 'lib/widgets/custom_scaffold.dart';

  @override
  String content() {
    return """
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'service/logger_service.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({required this.body, super.key});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Get.find<Logger>().show();
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.logo_dev_rounded),
      ),
    );
  }
}
""";
  }
}

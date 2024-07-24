import '../../../../../interfaces/file_manipulator.dart';

class LostConnectionPageManipulator extends FileManipulator {
  @override
  String get name => 'LostConnectionPage';

  @override
  String get path => 'lib/page/lost_connection_page.dart';

  @override
  String content() => """
import 'package:flutter/material.dart';

class LostConnectionPage extends StatelessWidget {
  const LostConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'This is the Lost Connection Page. You can customize it in lost_connection_page.dart',
        ),
      ),
    );
  }
}""";
}

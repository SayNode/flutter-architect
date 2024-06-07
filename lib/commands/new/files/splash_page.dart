String content() {
  return """
import 'package:flutter/material.dart';
import '../widget/custom_scaffold.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(body:Container());
  }
}""";
}

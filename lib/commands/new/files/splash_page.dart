String content() {
  return "import 'package:flutter/material.dart'; \nimport '../widget/custom_scaffold.dart'; \nclass SplashPage extends StatelessWidget { \nconst SplashPage({super.key}); \n@override \nWidget build(BuildContext context) { \nreturn CustomScaffold(body:Container()); \n} \n}";
}

content() => """
class RestartWidget extends StatefulWidget {
  const RestartWidget({required this.child, super.key});

  final Widget child;

  static Future<void> restartApp(BuildContext context) async {
    await context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp();
  }

  @override
  // ignore: library_private_types_in_public_api
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  Future<void> restartApp() async {
    await Get.deleteAll(); //deleting all controllers
    setState(() {
      key = UniqueKey();
    });
    Get.reset();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}""";

import 'dart:io';

import '../../../../../interfaces/file_manipulator.dart';
import '../../../../../util/util.dart';

class ColorManipulator extends FileManipulator {
  ColorManipulator(
    String colorName,
    List<dynamic> colors,
  ) {
    _colorName = colorName;
    _colors = colors;
  }

  late List<dynamic> _colors;
  late String _colorName;

  @override
  String get name => 'Color';

  @override
  String get path => 'lib/theme/color.dart';

  @override
  Future<void> create() async {
    final StringBuffer buffer = StringBuffer()
      ..writeln(
        "import 'package:flutter/material.dart';\n class $_colorName {",
      );
    for (final Map<String, dynamic> color in _colors) {
      buffer.writeln(
        "static const Color ${color['name']} = Color.fromRGBO(${color['r']}, ${color['g']}, ${color['b']}, ${color['a']});",
      );
    }
    buffer.writeln('}');
    await writeFileWithPrefix(
      path,
      buffer.toString(),
    );
    printColor(
      'Colors added to Color file (lib/theme/color.dart) ✔',
      ColorText.green,
    );
  }

  Future<void> update() async {
    final List<String> lines = await File(path).readAsLines();

    final StringBuffer buffer = StringBuffer();
    for (final String line in lines) {
      buffer.writeln(line);

      if (line.contains("import 'package:flutter/material.dart';")) {
        buffer.writeln('class $_colors {');
        for (final Map<String, dynamic> color in _colors) {
          buffer.writeln(
            "static const Color ${color['name']} = Color.fromRGBO(${color['r']}, ${color['g']}, ${color['b']}, ${color['a']});",
          );
        }
        buffer.writeln('}');
      }
    }

    await File(path).writeAsString(buffer.toString());
    printColor(
      'Colors added to Color file (lib/theme/color.dart) ✔',
      ColorText.green,
    );
  }

  @override
  String content() => '';
}

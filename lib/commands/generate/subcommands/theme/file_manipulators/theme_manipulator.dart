import 'dart:io';

import '../../../../../interfaces/file_manipulator.dart';
import '../../../../../util/util.dart';

class ThemeManipulator extends FileManipulator {
  ThemeManipulator(
    String colorName,
    String themeName,
    List<dynamic> colors,
  ) {
    _colorName = colorName;
    _themeName = themeName;
    _colors = colors;
  }

  late List<dynamic> _colors;
  late String _colorName;
  late String _themeName;

  @override
  String get name => 'Theme';

  @override
  String get path => 'lib/theme/theme.dart';

  @override
  Future<void> create() async {
    final StringBuffer content = StringBuffer()..write("""
import 'package:flutter/material.dart';
import 'color.dart';
class CustomTheme extends ThemeExtension<CustomTheme> {
  const CustomTheme({""");

    for (final Map<String, dynamic> color in _colors) {
      content.writeln("required this.${color['name']},");
    }

    content
      ..writeln('});')
      ..writeln();

    for (final Map<String, dynamic> color in _colors) {
      content
        ..writeln("final Color ${color['name']};")
        ..writeln();
    }

    content.write('''
  @override
  CustomTheme copyWith({''');

    for (final Map<String, dynamic> color in _colors) {
      content.writeln("Color? ${color['name']},");
    }

    content.write('''
  }) {
    return CustomTheme(''');

    for (final Map<String, dynamic> color in _colors) {
      content.writeln(
        "${color['name']}: ${color['name']} ?? this.${color['name']},",
      );
    }

    content.write('''
    );
  }

  // List of themes
  static const $_themeName = CustomTheme(''');

    for (final Map<String, dynamic> color in _colors) {
      content.writeln("${color['name']}: $_colorName.${color['name']},");
    }

    content.write('''
  );

  @override
  ThemeExtension<CustomTheme> lerp(ThemeExtension<CustomTheme>? other, double t) {
    // TODO: implement lerp
    throw UnimplementedError();
  }
}''');

    await writeFileWithPrefix(path, content.toString());
    printColor(
      'Colors added to Theme file (lib/theme/theme.dart) ✔',
      ColorText.green,
    );
  }

  Future<void> update() async {
    final List<String> lines = await File(path).readAsLines();
    final StringBuffer buffer = StringBuffer();
    for (final String line in lines) {
      buffer.write('$line\n');
      if (line.contains('// List of themes')) {
        buffer.writeln('static const $_themeName = CustomTheme(');
        for (final Map<String, dynamic> color in _colors) {
          buffer.writeln("${color['name']}: $_colorName.${color['name']},");
        }
        buffer.writeln(
          '${buffer.toString().substring(0, buffer.toString().length - 1)});\n',
        );
      }
    }

    await File(path).writeAsString(buffer.toString());
    printColor(
      'Colors added to Theme file (lib/theme/theme.dart) ✔',
      ColorText.green,
    );
  }

  @override
  String content() => '';
}

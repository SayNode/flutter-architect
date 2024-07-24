import '../../../../../interfaces/file_manipulator.dart';
import '../../../../../util/util.dart';

class TypographyManipulator extends FileManipulator {
  TypographyManipulator(
    List<dynamic> textStyles,
  ) {
    _textStyles = textStyles;
  }

  late List<dynamic> _textStyles;

  @override
  String get name => 'Typography';

  @override
  String get path => 'lib/theme/typography.dart';

  @override
  Future<void> create() async {
    final StringBuffer buffer = StringBuffer()..write("""
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class CustomTypography {
  final Color color;
  CustomTypography(this.color);
  // List of textstyles""");

    for (final Map<String, dynamic> textStyle in _textStyles) {
      buffer.writeln(
        "TextStyle get k${(textStyle['name'] as String).capitalize} => GoogleFonts.${textStyle['fontFamily'].toString().decapitalize}( \nfontSize: ${textStyle['fontSize']}, \ncolor: color, \nfontWeight: FontWeight.w${textStyle['fontWeight']}, \n);",
      );
    }
    buffer.write('''
  factory CustomTypography.fromColor(Color color) {
    return CustomTypography(color);
  }
}''');
    await writeFileWithPrefix(
      path,
      buffer.toString(),
    );
    printColor(
      'Typography file updated (lib/theme/typography.dart) ✔',
      ColorText.green,
    );
  }

  @override
  String content() => '';
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../commands/new/files/prefix.dart' as prefix;

/// Logic for building a component.
/// Receives the command-line arguments [force], [removeOnly].
/// Receives the [alreadyBuilt] boolean.
/// [add] and [remove] will be called if the component is not already built.
/// [rejectAdd] and [rejectRemove] will be called if the component is already built.
Future<void> componentBuilder({
  required bool force,
  required bool alreadyBuilt,
  required bool removeOnly,
  Future<dynamic> Function()? add,
  Future<dynamic> Function()? remove,
  Future<dynamic> Function()? rejectAdd,
  Future<dynamic> Function()? rejectRemove,
}) async {
  if (removeOnly) {
    // If removeOnly is true, remove the component.
    if (alreadyBuilt) {
      // If the component is already built, remove it.
      await remove?.call();
      emptyLine();
      dartFormatCode();
      dartFixCode();
    } else {
      // If the component is not built, reject the removal.
      await rejectRemove?.call();
    }
  } else {
    // If removeOnly is false, add the component.
    if (!alreadyBuilt) {
      // If the component is not already built, add it.
      await add?.call();
      emptyLine();
      dartFormatCode();
      dartFixCode();
    } else {
      // If the component is already built, check if should force the addition.
      if (force) {
        // If force is true, remove the component and add it again.
        await remove?.call();
        await add?.call();
        emptyLine();
        dartFormatCode();
        dartFixCode();
      } else {
        // If force is false, reject the addition.
        await rejectAdd?.call();
      }
    }
  }
}

/// Add dependencies to pubspec.yaml
Future<ProcessResult> addDependenciesToPubspec(
  List<String> dependencies,
  String? workingDirectory,
) async {
  printColor(
    'Adding the following dependencies to pubspec.yaml:',
    ColorText.white,
  );
  printColor(dependencies.join('\n'), ColorText.white);
  printColor(
    '\n----------- Pub Get Output -----------',
    ColorText.blue,
  );
  final ProcessResult result = await Process.run(
    'flutter',
    <String>['pub', 'add', ...dependencies],
    runInShell: true,
    workingDirectory: workingDirectory,
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
  emptyLine();
  printColor('Dependencies added ✔\n', ColorText.green);
  return result;
}

/// Add dependencies to pubspec.yaml
ProcessResult addDependenciesToPubspecSync(
  List<String> dependencies,
  String? workingDirectory,
) {
  printColor(
    'Adding the following dependencies to pubspec.yaml:',
    ColorText.white,
  );
  printColor(dependencies.join('\n'), ColorText.white);
  printColor(
    '\n----------- Pub Get Output -----------',
    ColorText.blue,
  );
  final ProcessResult result = Process.runSync(
    'flutter',
    <String>['pub', 'add', ...dependencies],
    runInShell: true,
    workingDirectory: workingDirectory,
    stdoutEncoding: Encoding.getByName('utf-8'),
    stderrEncoding: Encoding.getByName('utf-8'),
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
  emptyLine();
  printColor('Dependencies added ✔\n', ColorText.green);
  return result;
}

/// Remove dependencies from pubspec.yaml
Future<ProcessResult> removeDependenciesFromPubspec(
  List<String> dependencies,
  String? workingDirectory,
) async {
  printColor(
    'Removing the following dependencies to pubspec.yaml:',
    ColorText.white,
  );
  printColor(dependencies.join('\n'), ColorText.white);
  printColor(
    '\n----------- Pub Get Output -----------',
    ColorText.blue,
  );
  final ProcessResult result = await Process.run(
    'flutter',
    <String>['pub', 'remove', ...dependencies],
    runInShell: true,
    workingDirectory: workingDirectory,
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
  emptyLine();
  printColor('Dependencies removed ✔\n', ColorText.green);
  return result;
}

/// Remove dependencies from pubspec.yaml
ProcessResult removeDependenciesFromPubspecSync(
  List<String> dependencies,
  String? workingDirectory,
) {
  printColor(
    'Removing the following dependencies to pubspec.yaml:',
    ColorText.white,
  );
  printColor(dependencies.join('\n'), ColorText.white);
  printColor(
    '\n----------- Pub Get Output -----------',
    ColorText.blue,
  );
  final ProcessResult result = Process.runSync(
    'flutter',
    <String>['pub', 'remove', ...dependencies],
    runInShell: true,
    workingDirectory: workingDirectory,
    stdoutEncoding: Encoding.getByName('utf-8'),
    stderrEncoding: Encoding.getByName('utf-8'),
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
  emptyLine();
  printColor('Dependencies removed ✔\n', ColorText.green);
  return result;
}

/// Run flutter_native_splash command
ProcessResult runNativeSplash(String? workingDirectory) {
  printColor(
    '----- Native Splash Screen Output -----',
    ColorText.cyan,
  );
  final ProcessResult result = Process.runSync(
    'dart',
    <String>[
      'run',
      'flutter_native_splash:create',
      '--path=flutter_native_splash.yaml',
    ],
    runInShell: true,
    workingDirectory: workingDirectory,
    stdoutEncoding: Encoding.getByName('utf-8'),
    stderrEncoding: Encoding.getByName('utf-8'),
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
  emptyLine();
  return result;
}

/// Run dart format
void dartFormatCode() {
  printColor(
    '------------ Dart Format ------------',
    ColorText.blue,
  );
  final ProcessResult result = Process.runSync(
    'dart',
    <String>['format', '.'],
    runInShell: true,
    stdoutEncoding: Encoding.getByName('utf-8'),
    stderrEncoding: Encoding.getByName('utf-8'),
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
  emptyLine();
}

// Run dart fix
void dartFixCode() {
  printColor(
    '-------------- Dart Fix --------------',
    ColorText.blue,
  );
  final ProcessResult result = Process.runSync(
    'dart',
    <String>['fix', '--apply'],
    runInShell: true,
    stdoutEncoding: Encoding.getByName('utf-8'),
    stderrEncoding: Encoding.getByName('utf-8'),
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
  emptyLine();
}

/// Mark [command] as already ran.
Future<void> addAlreadyRun(String command) async {
  await File('added_boilerplate.txt')
      .writeAsString('$command\n', mode: FileMode.append);
}

/// Remove [command] as already ran.
Future<void> removeAlreadyRun(String command) async {
  await removeLinesFromFile(
    'added_boilerplate.txt',
    <String>[command],
  );
}

/// Remove lines that start with [command] as already ran.
Future<void> removeAlreadyRunStartingWith(String command) async {
  await removeLinesStartingWithFromFile(
    'added_boilerplate.txt',
    command,
  );
}

/// Check if [command] already run for this project
/// Exits if [command] already run
Future<void> checkIfAlreadyRun(String command) async {
  await File('added_boilerplate.txt').readAsLines().then((List<String> lines) {
    for (final String line in lines) {
      if (line.contains(command)) {
        //print('$command already added');
        exit(0);
      }
    }
  });
}

/// Check if [command] already run for this project
/// Returns true if [command] already run, otheriwse false
Future<bool> checkIfAlreadyRunWithReturn(String command) async {
  return File('added_boilerplate.txt').readAsLines().then((List<String> lines) {
    for (final String line in lines) {
      //print('line: $line');
      if (line.contains(command)) {
        return true;
      }
    }
    return false;
  });
}

/// Delete [lines] from [file].
Future<void> removeLinesFromFile(String file, List<String> lines) async {
  final List<String> fileLines = await File(file).readAsLines();
  final List<String> newFileLines = <String>[];
  for (final String line in fileLines) {
    if (!lines.contains(line.trim())) {
      newFileLines.add(line);
    }
  }
  await File(file).writeAsString(newFileLines.join('\n'));
}

/// Delete lines from [file] that start with [startsWith].
Future<void> removeLinesStartingWithFromFile(
  String file,
  String startsWith,
) async {
  final List<String> fileLines = await File(file).readAsLines();
  final List<String> newFileLines = <String>[];
  for (final String line in fileLines) {
    if (!line.trim().startsWith(startsWith)) {
      newFileLines.add(line);
    }
  }
  await File(file).writeAsString(newFileLines.join('\n'));
}

/// Delete lines from [file], from [line1] to [line2].
Future<void> removeLineRangeFromFile(
  String file,
  String line1,
  String line2,
) async {
  final List<String> fileLines = await File(file).readAsLines();
  final List<String> newFileLines = <String>[];
  bool delete = false;
  for (final String line in fileLines) {
    if (line.trim().contains(line1)) {
      delete = true;
    }
    if (!delete) {
      newFileLines.add(line);
    }
    if (line.trim().contains(line2)) {
      delete = false;
    }
  }
  await File(file).writeAsString(newFileLines.join('\n'));
}

/// Delete string [text] from file in path [file].
Future<void> removeTextFromFile(String file, String text) async {
  final List<String> lines = text.split('\n');

  final List<String> fileLines = await File(file).readAsLines();
  final List<String> newFileLines = <String>[];

  final List<String> toDeleteLines = <String>[];

  for (int i = 0; i < fileLines.length; i++) {
    final String fileLine = fileLines[i];
    if (toDeleteLines.length == lines.length) {
      toDeleteLines.clear();
      newFileLines.add(fileLine);
    } else {
      if (fileLine.trim().contains(lines[toDeleteLines.length].trim())) {
        toDeleteLines.add(fileLine);
      } else {
        newFileLines.addAll(toDeleteLines);
        toDeleteLines.clear();
        newFileLines.add(fileLine);
      }
    }
  }
  await File(file).writeAsString(newFileLines.join('\n'));
}

/// Delete [amount] lines from file in path [file], after line [line].
Future<void> removeLinesAfterFromFile(
  String file,
  String line,
  int amount, {
  bool includeFirst = false,
}) async {
  final List<String> fileLines = await File(file).readAsLines();
  final List<String> newFileLines = <String>[];
  for (int i = 0; i < fileLines.length; i++) {
    final String fileLine = fileLines[i];
    if (fileLine.trim().contains(line.trim())) {
      i += amount;
      if (!includeFirst) {
        newFileLines.add(fileLine);
      }
    } else {
      newFileLines.add(fileLine);
    }
  }
  await File(file).writeAsString(newFileLines.join('\n'));
}

/// Replace [line] with [newLine] in [file].
Future<void> replaceLineInFile(String file, String line, String newLine) async {
  final List<String> fileLines = await File(file).readAsLines();
  final List<String> newFileLines = <String>[];
  for (final String l in fileLines) {
    if (l.trim().contains(line)) {
      newFileLines.add(newLine);
    } else {
      newFileLines.add(l);
    }
  }
  await File(file).writeAsString(newFileLines.join('\n'));
}

/// Add lines in value of [lines] after line in key of [lines], in file [file].
Future<void> addLinesAfterLineInFile(
  String file,
  Map<String, List<String>> lines, {
  List<String> leading = const <String>[],
  List<String> trailing = const <String>[],
}) async {
  final List<String> fileLines = await File(file).readAsLines();
  final List<String> newFileLines = <String>[...leading];

  for (final String line in fileLines) {
    newFileLines
      ..add(line)
      ..addAll(lines[line.trim()] ?? <String>[]);
  }

  newFileLines.addAll(trailing);

  await File(file).writeAsString(newFileLines.join('\n'));
}

/// Add lines in value of [lines] before line in key of [lines], in file [file].
Future<void> addLinesBeforeLineInFile(
  String file,
  Map<String, List<String>> lines, {
  List<String> leading = const <String>[],
  List<String> trailing = const <String>[],
}) async {
  final List<String> fileLines = await File(file).readAsLines();
  final List<String> newFileLines = <String>[...leading];

  for (final String line in fileLines) {
    newFileLines
      ..addAll(lines[line.trim()] ?? <String>[])
      ..add(line);
  }

  newFileLines.addAll(trailing);

  await File(file).writeAsString(newFileLines.join('\n'));
}

/// Get project name from pubspec.yaml
Future<String> getProjectName() async {
  String name = '';
  await File('pubspec.yaml').readAsLines().then((List<String> lines) {
    for (final String line in lines) {
      if (line.contains('name:')) {
        name = line.split(':')[1].trim();
        break;
      }
    }
  });
  return name;
}

/// Get pre-built file prefix
String get getPrefix => prefix.content();

/// Write file
Future<File> writeFile(String path, String content) async {
  File file;
  try {
    file = await File(path).writeAsString(content);
  } catch (e) {
    File(path).createSync(recursive: true);
    file = await File(path).writeAsString(content);
  }
  return file;
}

/// Write file with prefix
Future<File> writeFileWithPrefix(String path, String content) async {
  File file;
  try {
    file = await File(path).writeAsString(getPrefix + content);
  } catch (e) {
    File(path).createSync(recursive: true);
    file = await File(path).writeAsString(getPrefix + content);
  }
  return file;
}

/// Show spinner loading animation in Command Line
Future<void> spinnerLoading(Function function) async {
  final List<String> P = <String>[r'\', '|', '/', '-'];
  int x = 0;
  final Timer timer =
      Timer.periodic(const Duration(milliseconds: 250), (Timer timer) {
    stdout.write('\r${P[x++]}');
    x &= 3;
  });
  // ignore: avoid_dynamic_calls
  await function();
  timer.cancel();
}

void emptyLine() {
  emptyLine();
}

extension StringCapitalize on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}

extension StringDecapitalize on String {
  String get decapitalize => '${this[0].toLowerCase()}${substring(1)}';
}

// Convert snake_case to lowerCamelCase
String lowerCamelCase(String s) {
  final List<String> words = s.split(RegExp(r'[_\s-]'));
  final StringBuffer buffer = StringBuffer()..write(words[0].toLowerCase());
  for (int i = 1; i < words.length; i++) {
    buffer.write(words[i].capitalize);
  }
  return buffer.toString();
}

/// Print colored text to the console
/// Color memo:
/// Black:   \x1B[30m
/// Red:     \x1B[31m
/// Green:   \x1B[32m
/// Yellow:  \x1B[33m
/// Blue:    \x1B[34m
/// Magenta: \x1B[35m
/// Cyan:    \x1B[36m
/// White:   \x1B[37m
/// Reset:   \x1B[0m
/// \x1B  [31m  Hello  \x1B  [0m
void printColor(String textToPrint, ColorText colorText) {
  // generate a switch on the colorText enum
  switch (colorText) {
    case ColorText.black:
      stderr.writeln('\x1B[30m$textToPrint\x1B[0m');
    case ColorText.red:
      stderr.writeln('\x1B[31m$textToPrint\x1B[0m');
    case ColorText.green:
      stderr.writeln('\x1B[32m$textToPrint\x1B[0m');
    case ColorText.yellow:
      stderr.writeln('\x1B[33m$textToPrint\x1B[0m');
    case ColorText.blue:
      stderr.writeln('\x1B[34m$textToPrint\x1B[0m');
    case ColorText.magenta:
      stderr.writeln('\x1B[35m$textToPrint\x1B[0m');
    case ColorText.cyan:
      stderr.writeln('\x1B[36m$textToPrint\x1B[0m');
    case ColorText.white:
      stderr.writeln('\x1B[37m$textToPrint\x1B[0m');
    case ColorText.reset:
      stderr.writeln('\x1B[0m$textToPrint\x1B[0m');
  }
}

enum ColorText { black, red, green, yellow, blue, magenta, cyan, white, reset }

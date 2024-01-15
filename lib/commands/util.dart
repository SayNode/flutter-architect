import 'dart:async';
import 'dart:io';

import 'package:project_initialization_tool/commands/new/files/prefix.dart'
    as prefix;

/// Logic for building a component.
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
    if (alreadyBuilt) {
      await remove?.call();
    } else {
      await rejectRemove?.call();
    }
  } else {
    if (!alreadyBuilt) {
      await add?.call();
    } else {
      if (force) {
        await remove?.call();
        await add?.call();
      } else {
        await rejectAdd?.call();
      }
    }
  }
}

/// Add dependencies to pubspec.yaml
Future<ProcessResult> addDependenciesToPubspec(
    List<String> dependencies, String? workingDirectory) async {
  var result = await Process.run('flutter', ['pub', 'add', ...dependencies],
      runInShell: true, workingDirectory: workingDirectory);
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
  return result;
}

/// Add dependencies to pubspec.yaml
ProcessResult addDependenciesToPubspecSync(
    List<String> dependencies, String? workingDirectory) {
  var result = Process.runSync('flutter', ['pub', 'add', ...dependencies],
      runInShell: true, workingDirectory: workingDirectory);
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
  return result;
}

/// Remove dependencies from pubspec.yaml
Future<ProcessResult> removeDependenciesFromPubspec(
    List<String> dependencies, String? workingDirectory) async {
  var result = await Process.run('flutter', ['pub', 'remove', ...dependencies],
      runInShell: true, workingDirectory: workingDirectory);
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
  return result;
}

/// Remove dependencies from pubspec.yaml
ProcessResult removeDependenciesFromPubspecSync(
    List<String> dependencies, String? workingDirectory) {
  var result = Process.runSync('flutter', ['pub', 'remove', ...dependencies],
      runInShell: true, workingDirectory: workingDirectory);
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
  return result;
}

/// Run flutter_native_splash command
ProcessResult runNativeSplash(String? workingDirectory) {
  var result = Process.runSync(
      'dart',
      [
        'run',
        'flutter_native_splash:create',
        '--path=flutter_native_splash.yaml',
      ],
      runInShell: true,
      workingDirectory: workingDirectory);
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
  return result;
}

/// Run dart format
void formatCode() {
  var result = Process.runSync(
    'dart',
    ['format', '.'],
    runInShell: true,
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
}

// Run dart fix
void dartFixCode() {
  var result = Process.runSync(
    'dart',
    ['fix', '--apply'],
    runInShell: true,
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
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
    [command],
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
    for (var line in lines) {
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
  return await File('added_boilerplate.txt')
      .readAsLines()
      .then((List<String> lines) {
    for (var line in lines) {
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
  var fileLines = await File(file).readAsLines();
  var newFileLines = <String>[];
  for (var line in fileLines) {
    if (!lines.contains(line.trim())) {
      newFileLines.add(line);
    }
  }
  await File(file).writeAsString(newFileLines.join('\n'));
}

/// Delete lines from [file] that start with [startsWith].
Future<void> removeLinesStartingWithFromFile(
    String file, String startsWith) async {
  var fileLines = await File(file).readAsLines();
  var newFileLines = <String>[];
  for (var line in fileLines) {
    if (!line.trim().startsWith(startsWith)) {
      newFileLines.add(line);
    }
  }
  await File(file).writeAsString(newFileLines.join('\n'));
}

/// Delete lines from [file], from [line1] to [line2].
Future<void> removeLineRangeFromFile(
    String file, String line1, String line2) async {
  var fileLines = await File(file).readAsLines();
  var newFileLines = <String>[];
  var delete = false;
  for (var line in fileLines) {
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
  List<String> lines = text.split('\n');

  await removeLinesAfterFromFile(
    file,
    lines.first,
    lines.length - 1,
    includeFirst: true,
  );
}

/// Delete [amount] lines from file in path [file], after line [line].
Future<void> removeLinesAfterFromFile(String file, String line, int amount,
    {bool includeFirst = false}) async {
  var fileLines = await File(file).readAsLines();
  var newFileLines = <String>[];
  for (int i = 0; i < fileLines.length; i++) {
    String fileLine = fileLines[i];
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
  var fileLines = await File(file).readAsLines();
  var newFileLines = <String>[];
  for (var l in fileLines) {
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
    String file, Map<String, List<String>> lines,
    {List<String> leading = const [], List<String> trailing = const []}) async {
  var fileLines = await File(file).readAsLines();
  var newFileLines = <String>[];

  newFileLines.addAll(leading);

  for (String line in fileLines) {
    newFileLines.add(line);
    newFileLines.addAll(lines[line.trim()] ?? []);
  }

  newFileLines.addAll(trailing);

  await File(file).writeAsString(newFileLines.join('\n'));
}

/// Add lines in value of [lines] before line in key of [lines], in file [file].
Future<void> addLinesBeforeLineInFile(
    String file, Map<String, List<String>> lines,
    {List<String> leading = const [], List<String> trailing = const []}) async {
  var fileLines = await File(file).readAsLines();
  var newFileLines = <String>[];

  newFileLines.addAll(leading);

  for (String line in fileLines) {
    newFileLines.addAll(lines[line.trim()] ?? []);
    newFileLines.add(line);
  }

  newFileLines.addAll(trailing);

  await File(file).writeAsString(newFileLines.join('\n'));
}

Future<String> getProjectName() async {
  String name = '';
  await File('pubspec.yaml').readAsLines().then((List<String> lines) {
    for (var line in lines) {
      if (line.contains('name:')) {
        name = line.split(':')[1].trim();
        break;
      }
    }
  });
  return name;
}

String get getPrefix => prefix.content();

Future<File> writeFileWithPrefix(String path, String content) async {
  return await File(path).writeAsString(prefix.content() + content);
}

spinnerLoading(Function function) async {
  var P = ["\\", "|", "/", "-"];
  var x = 0;
  var timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
    stdout.write("\r${P[x++]}");
    x &= 3;
  });
  await function();
  timer.cancel();
}

String capitalizeFirstLetter(String s) {
  return s[0].toUpperCase() + s.substring(1);
}

//function to turn string to lower camel case
String lowerCamelCase(String s) {
  var words = s.split(RegExp(r'[_\s-]'));
  var result = '';
  result += words[0].toLowerCase();
  for (var i = 1; i < words.length; i++) {
    result += capitalizeFirstLetter(words[i]);
  }
  return result;
}

// Black:   \x1B[30m
// Red:     \x1B[31m
// Green:   \x1B[32m
// Yellow:  \x1B[33m
// Blue:    \x1B[34m
// Magenta: \x1B[35m
// Cyan:    \x1B[36m
// White:   \x1B[37m
// Reset:   \x1B[0m

// \x1B  [31m  Hello  \x1B  [0m

printColor(String textToPrint, ColorText colorText) {
  // generate a switch on the colorText enum
  switch (colorText) {
    case ColorText.black:
      print('\x1B[30m$textToPrint\x1B[0m');
      break;
    case ColorText.red:
      print('\x1B[31m$textToPrint\x1B[0m');
      break;
    case ColorText.green:
      print('\x1B[32m$textToPrint\x1B[0m');
      break;
    case ColorText.yellow:
      print('\x1B[33m$textToPrint\x1B[0m');
      break;
    case ColorText.blue:
      print('\x1B[34m$textToPrint\x1B[0m');
      break;
    case ColorText.magenta:
      print('\x1B[35m$textToPrint\x1B[0m');
      break;
    case ColorText.cyan:
      print('\x1B[36m$textToPrint\x1B[0m');
      break;
    case ColorText.white:
      print('\x1B[37m$textToPrint\x1B[0m');
      break;
    case ColorText.reset:
      print('\x1B[0m$textToPrint\x1B[0m');
      break;
  }
}

enum ColorText { black, red, green, yellow, blue, magenta, cyan, white, reset }

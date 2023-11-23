import 'dart:async';
import 'dart:io';

/// Add dependencies to pubspec.yaml
Future<ProcessResult> addDependencyToPubspec(
    String dependency, String? workingDirectory) async {
  var result = await Process.run('flutter', ['pub', 'add', dependency],
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
Future<ProcessResult> addDependencyToPubspecSync(
    String dependency, String? workingDirectory) async {
  var result = Process.runSync('flutter', ['pub', 'add', dependency],
      runInShell: true, workingDirectory: workingDirectory);
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
  return result;
}

///Format dart code
Future<void> formatCode() async {
  var result = await Process.run(
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

Future<void> dartFixCode() async {
  var result = await Process.run(
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

Future<void> addAllreadyRun(String command) async {
  await File('added_boilerplate.txt')
      .writeAsString('$command\n', mode: FileMode.append);
}

Future<void> checkIfAllreadyRun(String command) async {
  await File('added_boilerplate.txt').readAsLines().then((List<String> lines) {
    for (var line in lines) {
      if (line.contains(command)) {
        print('$command already added');
        exit(0);
      }
    }
  });
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

Future<bool> checkIfAllreadyRunWithReturn(String command) async {
  return await File('added_boilerplate.txt')
      .readAsLines()
      .then((List<String> lines) {
    for (var line in lines) {
      print('line: $line');
      if (line.contains(command)) {
        return true;
      }
    }
    return false;
  });
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

import 'dart:async';
import 'dart:io';

/// Add dependencies to pubspec.yaml
Future<void> addDependencyToPubspec(
    String dependency, String? workingDirectory) async {
  var result = await Process.run('flutter', ['pub', 'add', dependency],
      runInShell: true, workingDirectory: workingDirectory);
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
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

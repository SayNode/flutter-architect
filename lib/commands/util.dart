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

///check if firebase CLI is installed
Future<bool> isFirebaseCLIInstalled() async {
  var result = await Process.run(
    'firebase',
    ['--version'],
    runInShell: true,
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
    return false;
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
    return true;
  }
  return false;
}

///install firebase CLI
Future<void> installFirebaseCLI() async {
  var result = await Process.run(
    'curl',
    ['-sL', 'https://firebase.tools', '|', 'bash'],
    runInShell: true,
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
}

///activate firebase CLI
Future<void> activateFirebaseCLI() async {
  var result = await Process.run(
    'dart',
    ['pub', 'global', 'activate', 'flutterfire_cli'],
    runInShell: true,
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
}

///check if user is logged in firebase
Future<void> firebaseCLILogin() async {
  var result = await Process.run(
    'firebase',
    ['login'],
    runInShell: true,
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
}

///check if user is logged in firebase
Future<void> installFirebaseDependancy() async {
  var result = await Process.run(
    'flutter',
    ['pub', 'add', 'firebase_core'],
    runInShell: true,
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
}

///check if user is logged in firebase
Future<void> flutterfireRun() async {
  var result = await Process.run(
    'flutterfire',
    ['configure'],
    runInShell: true,
  );
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
}

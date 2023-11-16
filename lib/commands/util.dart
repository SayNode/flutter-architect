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

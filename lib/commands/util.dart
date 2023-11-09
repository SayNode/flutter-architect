import 'dart:io';

/// Add dependencies to pubspec.yaml
Future<void> addDependencyToPubspec(
    String dependency, String workingDirectory) async {
  var result = await Process.run('flutter', ['pub', 'add', dependency],
      runInShell: true, workingDirectory: workingDirectory);
  if (result.stderr != null) {
    stderr.write(result.stderr);
  }
  if (result.stdout != null) {
    stdout.write(result.stdout);
  }
}

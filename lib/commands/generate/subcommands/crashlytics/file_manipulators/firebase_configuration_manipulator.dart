import '../../../../../interfaces/file_manipulator.dart';

class FirebaseConfigurationManipulator extends FileManipulator {
  @override
  String get name => 'firebase_configuration';

  @override
  String get path => 'firebase_configuration.sh';

  @override
  String content() => r'''
#!/bin/bash
# This script launches the firebase login command

sudo npm install -g firebase-tools
dart pub global activate flutterfire_cli

alias firebase="`npm config get prefix`/bin/firebase"
export PATH="$PATH":"$HOME/.pub-cache/bin"
firebase login --interactive
flutterfire configure''';
}

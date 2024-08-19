import 'dart:io';

import 'package:args/command_runner.dart';

import '../../../../util/util.dart';
import 'file_manipulators/breez_base_service_manipulator.dart';
import 'file_manipulators/breez_service_manipulator.dart';

class GenerateBreezService extends Command<dynamic> {
  GenerateBreezService() {
    // Add parser options or flag here
    argParser
      ..addFlag(
        'force',
        help: 'Force replace in case it already exists.',
      )
      ..addFlag(
        'remove',
        help: 'Remove in case it already exists.',
      );
  }

  @override
  String get description =>
      'Create Breez Service related files and boilerplate code;';

  @override
  String get name => 'breez';

  @override
  Future<void> run() async {
    await _run();
  }

  Future<void> _run() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('breez');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        printColor(
          '-------- Creating Breez service --------\n',
          ColorText.cyan,
        );
        await addAlreadyRun('breez');
        await _addDependencies();
        await _editAndroidFiles();
        await BreezBaseServiceManipulator().create();
        await BreezServiceManipulator().create();
      },
      remove: () async {
        printColor(
          '-------- Removing Breez service --------\n',
          ColorText.cyan,
        );
        await removeAlreadyRun('breez');
        await _removeDependencies();
        await _cleanAndroidFiles();
        await BreezBaseServiceManipulator().remove();
        await BreezServiceManipulator().remove();

        printColor('Constants removed ✔', ColorText.green);
      },
      rejectAdd: () async {
        printColor(
          "Can't add Breez Service as it's already configured.\n",
          ColorText.red,
        );
      },
      rejectRemove: () async {
        printColor(
          "Can't remove Breez Service as it's not yet configured.\n",
          ColorText.red,
        );
      },
    );
  }

  Future<void> _editAndroidFiles() async {
    await addLinesAfterLineInFile(
        'android/settings.gradle', <String, List<String>>{
      'plugins {': <String>[
        '//breez imports start',
        'id "org.jetbrains.kotlin.plugin.serialization" version "1.8.20" apply false',
        '//breez imports end',
      ],
    });

    final File file = File('android/app/build.gradle');
    final String contents = await file.readAsString();
    if (contents.contains('dependencies')) {
      await addLinesAfterLineInFile(
          'android/app/build.gradle', <String, List<String>>{
        'plugins {': <String>[
          '//breez imports start',
          "id 'kotlinx-serialization'",
          '//breez imports end',
        ],
        'dependencies {': <String>[
          '//breez imports start',
          'implementation "org.jetbrains.kotlin:kotlin-stdlib:1.8.20"',
          'implementation "org.jetbrains.kotlinx:kotlinx-serialization-json:1.5.0"',
          '//breez imports end',
        ],
      });
    } else {
      await addLinesAfterLineInFile(
          'android/app/build.gradle', <String, List<String>>{
        'plugins {': <String>[
          '//breez imports start',
          "id 'kotlinx-serialization'",
          '//breez imports end',
        ],
        '}': <String>[
          '//breez imports start',
          'dependencies {',
          ' implementation "org.jetbrains.kotlin:kotlin-stdlib:1.8.20"',
          ' implementation "org.jetbrains.kotlinx:kotlinx-serialization-json:1.5.0"',
          '}',
        ],
      });
    }
  }

  Future<void> _addDependencies() async {
    await addLinesAfterLineInFile('pubspec.yaml', <String, List<String>>{
      'sdk: flutter': <String>[
        '  breez_sdk:',
        '    git:',
        '      url:  https://github.com/breez/breez-sdk-flutter.git',
      ],
    });

    addDependenciesToPubspecSync(<String>['path_provider'], null);
  }

  Future<void> _cleanAndroidFiles() async {}

  Future<void> _removeDependencies() async {}
}

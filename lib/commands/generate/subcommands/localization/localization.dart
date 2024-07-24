import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import '../../../../util/util.dart';
import '../../../new/file_manipulators/main_base_file_manipulator.dart';
import 'file_manipulators/english_json_manipulator.dart';
import 'file_manipulators/language_manipulator.dart';
import 'file_manipulators/localization_controller_manipulator.dart';
import 'file_manipulators/message_manipulator.dart';

class GenerateLocalizationService extends Command<dynamic> {
  GenerateLocalizationService() {
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
  String get description => 'Create localization files and boilerplate code;';

  @override
  String get name => 'localization';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  Future<void> _run() async {
    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('localization');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        printColor('-------- Creating Localization -------\n', ColorText.cyan);
        await addAlreadyRun('localization');
        await LanguageManipulator().create();
        await MessageManipulator().create();
        await LocalizationControllerManipulator().create();
        await EnglishJsonManipulator().create();
        await MainBaseFileManipulator().addLocalization();
        printColor(
          'Adding /locale to assets in pubspec.yaml...',
          ColorText.white,
        );
        await addAssetToPubspec();
        printColor('Added ✔', ColorText.white);
      },
      remove: () async {
        printColor('-------- Removing Localization -------\n', ColorText.cyan);
        await removeAlreadyRun('localization');
        printColor('Removing changes from main...', ColorText.white);
        await MainBaseFileManipulator().removeLocalization();
        printColor('Changes removed ✔\n', ColorText.green);
        await LanguageManipulator().remove();
        await MessageManipulator().remove();
        await LocalizationControllerManipulator().remove();
        await EnglishJsonManipulator().remove();
        printColor(
          '\nRemoving /locale to assets in pubspec.yaml...',
          ColorText.white,
        );
        await removeAssetFromPubspec();
        printColor('Removed ✔', ColorText.white);
      },
      rejectAdd: () async {
        stderr.writeln("Can't add Localization as it's already configured.");
      },
      rejectRemove: () async {
        stderr.writeln("Can't remove Localization as it's not yet configured.");
      },
    );
  }

  Future<void> removeAssetFromPubspec() async {
    final String pubspecPath = path.join('pubspec.yaml');
    await removeLinesFromFile(
      pubspecPath,
      <String>[
        '    - asset/locale/',
      ],
    );
  }

  Future<void> addAssetToPubspec() async {
    final String pubspecPath = path.join('pubspec.yaml');
    await addLinesAfterLineInFile(
      pubspecPath,
      <String, List<String>>{
        '- asset/': <String>[
          '    - asset/locale/',
        ],
      },
    );
  }
}

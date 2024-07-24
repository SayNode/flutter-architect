import 'dart:io';

import 'package:args/command_runner.dart';

import '../../../../util/util.dart';
import '../storage/storage.dart';
import 'file_manipulators/wallet_manipulator.dart';
import 'file_manipulators/wallet_service_manipulator.dart';

class GenerateWalletService extends Command<dynamic> {
  //-- Singleton
  GenerateWalletService() {
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
      'Create wallet service for the project. --secure flag will create wallet service. --shared flag will create wallet service;';

  @override
  String get name => 'wallet';

  @override
  Future<void> run() async {
    await _run();
  }

  Future<void> _run() async {
    final bool storageIsSetUp = await checkIfAlreadyRunWithReturn('storage');

    // Check for required storage
    if (!storageIsSetUp) {
      stderr.writeln(
        "Configuring Storage, as it's requried for Wallet Service...",
      );
      final GenerateStorageService storageService = GenerateStorageService();
      await storageService.run();
    }

    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('wallet');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        printColor('----- Creating Wallet Services -----\n', ColorText.cyan);
        addDependenciesToPubspecSync(<String>['thor_devkit_dart'], null);
        await addAlreadyRun('wallet');
        await WalletManipulator().create();
        await WalletServiceManipulator().create();
      },
      remove: () async {
        printColor('----- Removing Wallet Services -----\n', ColorText.cyan);
        removeDependenciesFromPubspecSync(<String>['thor_devkit_dart'], null);
        await removeAlreadyRun('wallet');
        await WalletServiceManipulator().remove();
        await WalletManipulator().remove();
      },
      rejectAdd: () async {
        printColor(
          "Can't add Wallet Service as it's already configured.",
          ColorText.red,
        );
      },
      rejectRemove: () async {
        printColor(
          "Can't remove Wallet Service as it's not yet configured.",
          ColorText.red,
        );
      },
    );
  }
}

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/generate/subcommands/wallet/code/wallet_model.dart'
    as wallet_model;
import 'package:project_initialization_tool/commands/generate/subcommands/wallet/code/wallet_service.dart'
    as wallet_service;
import 'package:project_initialization_tool/commands/util.dart';

import '../storage/storage.dart';

class GenerateWalletService extends Command {
  //-- Singleton
  GenerateWalletService() {
    // Add parser options or flag here
    argParser.addFlag('force',
        defaultsTo: false, help: 'Force replace in case it already exists.');
    argParser.addFlag('remove',
        defaultsTo: false, help: 'Remove in case it already exists.');
  }

  @override
  String get description =>
      'Create storage services for the project. --secure flag will create secure storage service. --shared flag will create shared storage service;';

  @override
  String get name => 'wallet';

  @override
  Future<void> run() async {
    await spinnerLoading(_run);
  }

  _run() async {
    bool storageIsSetUp = await checkIfAlreadyRunWithReturn("shared_storage");

    // Check for required storage
    if (!storageIsSetUp) {
      print(
          "Configuring Shared Storage, as it's requried for Wallet Service...");
      var storageService = GenerateStorageService();
      await storageService.runShared();
    }

    bool alreadyBuilt = await checkIfAlreadyRunWithReturn("wallet");
    bool force = argResults?['force'] ?? false;
    bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Wallet Service...');
        addDependenciesToPubspecSync(['thor_devkit_dart'], null);
        await addAlreadyRun('wallet');
        await _addWalletService();
        await _addWalletModel();
      },
      remove: () async {
        print('Removing Wallet Service...');
        removeDependenciesFromPubspecSync(['thor_devkit_dart'], null);
        await removeAlreadyRun('wallet');
        await _removeWalletService();
        await _removeWalletModel();
      },
      rejectAdd: () async {
        print("Can't add Wallet Service as it's already configured.");
      },
      rejectRemove: () async {
        print("Can't remove Wallet Service as it's not yet configured.");
      },
    );
    formatCode();
    dartFixCode();
  }

  Future<void> _removeWalletService() async {
    await File(path.join('lib', 'service', 'wallet_service.dart')).delete();
  }

  Future<void> _removeWalletModel() async {
    await File(path.join('lib', 'model', 'wallet_model.dart')).delete();
  }

  Future<void> _addWalletService() async {
    File(path.join('lib', 'service', 'wallet_service.dart'))
        .writeAsString(wallet_service.content());
  }

  Future<void> _addWalletModel() async {
    File(path.join('lib', 'model', 'wallet_model.dart'))
        .writeAsString(wallet_model.content());
  }
}

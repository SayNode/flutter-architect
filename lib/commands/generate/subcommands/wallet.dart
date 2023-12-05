import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:project_initialization_tool/commands/generate/subcommands/files/wallet_model.dart'
    as wallet_model;
import 'package:project_initialization_tool/commands/generate/subcommands/files/wallet_service.dart'
    as wallet_service;
import 'package:project_initialization_tool/commands/util.dart';

import 'storage.dart';

class GenerateWalletService extends Command {
  //-- Singleton
  GenerateWalletService() {
    // Add parser options or flag here
    argParser.addFlag('force',
        defaultsTo: false, help: 'Force replace in case it already exists.');
  }

  @override
  String get description =>
      'Create storage services for the project. --secure flag will create secure storage service. --shared flag will create shared storage service.';

  @override
  String get name => 'wallet';

  @override
  void run() async {
    spinnerLoading(_run);
  }

  _run() async {
    bool storageIsSetUp = await checkIfAlreadyRunWithReturn("shared_storage");

    // Check for required storage
    if (!storageIsSetUp) {
      var storageService = GenerateStorageService();
      await storageService.runShared();
    }

    bool value = await checkIfAlreadyRunWithReturn('wallet');
    bool force = argResults?['force'] ?? false;
    if (value && force) {
      print('Replacing wallet service...');
      removeDependencyFromPubspecSync('thor_devkit_dart', null);
      await _removeWalletService();
      await _removeWalletModel();
      addDependencyToPubspecSync('thor_devkit_dart', null);
      await _addWalletService();
      await _addWalletModel();
    } else if (!value) {
      print('Creating wallet service...');
      await addDependencyToPubspec('thor_devkit_dart', null);
      await addAlreadyRun('wallet');
      await _addWalletService();
      await _addWalletModel();
    } else {
      print('Wallet service already exists.');
      exit(0);
    }
    await formatCode();
    await dartFixCode();
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

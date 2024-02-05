import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'code/wallet_model.dart'
    as wallet_model;
import 'code/wallet_service.dart'
    as wallet_service;
import '../../../util.dart';

import '../storage/storage.dart';

class GenerateWalletService extends Command {
  //-- Singleton
  GenerateWalletService() {
    // Add parser options or flag here
    argParser.addFlag('force', help: 'Force replace in case it already exists.',);
    argParser.addFlag('remove', help: 'Remove in case it already exists.',);
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
    final bool storageIsSetUp = await checkIfAlreadyRunWithReturn('shared_storage');

    // Check for required storage
    if (!storageIsSetUp) {
      print(
          "Configuring Shared Storage, as it's requried for Wallet Service...",);
      final GenerateStorageService storageService = GenerateStorageService();
      await storageService.runShared();
    }

    final bool alreadyBuilt = await checkIfAlreadyRunWithReturn('wallet');
    final bool force = argResults?['force'] ?? false;
    final bool remove = argResults?['remove'] ?? false;
    await componentBuilder(
      force: force,
      alreadyBuilt: alreadyBuilt,
      removeOnly: remove,
      add: () async {
        print('Creating Wallet Service...');
        addDependenciesToPubspecSync(<String>['thor_devkit_dart'], null);
        await addAlreadyRun('wallet');
        await _addWalletService();
        await _addWalletModel();
      },
      remove: () async {
        print('Removing Wallet Service...');
        removeDependenciesFromPubspecSync(<String>['thor_devkit_dart'], null);
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
    await writeFileWithPrefix(
        path.join('lib', 'service', 'wallet_service.dart'),
        wallet_service.content(),);
  }

  Future<void> _addWalletModel() async {
    await writeFileWithPrefix(
        path.join('lib', 'model', 'wallet_model.dart'), wallet_model.content(),);
  }
}

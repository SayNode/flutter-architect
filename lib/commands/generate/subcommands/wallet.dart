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
    checkIfAllreadyRunWithReturn("shared_storage").then((value) async {
      if (!value) {
        var storageService = GenerateStorageService();
        storageService.runShared();
      }
    });

    checkIfAllreadyRun("wallet").then((value) async {
      print('Creating wallet service...');
      addDependencyToPubspec('thor_devkit_dart', null);
      await addAllreadyRun('wallet');
      await _addWalletService();
      await _addWalletModel();
    });
  }

  _addWalletService() async {
    File(path.join('lib', 'service', 'wallet_service.dart'))
        .writeAsString(wallet_service.content());
  }

  _addWalletModel() async {
    File(path.join('lib', 'model', 'wallet_model.dart'))
        .writeAsString(wallet_model.content());
  }
}

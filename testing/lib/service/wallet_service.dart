import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:thor_devkit_dart/crypto/address.dart';
import 'package:thor_devkit_dart/crypto/keystore.dart';
import 'package:thor_devkit_dart/crypto/mnemonic.dart';
import 'package:thor_devkit_dart/crypto/secp256k1.dart';
import 'package:thor_devkit_dart/utils.dart';

import '../model/wallet_model.dart';
import 'storage_service.dart';

class WalletService extends GetxService {
  late Wallet? _wallet;
  String get walletAddress => _getWalletAddress();
  Map<String, dynamic> get keystore => _getWalletKeystore();
  final StorageService _storage = Get.find<StorageService>();

  @override
  void onInit() {
    try {
      final String walletString = _storage.getString('wallet');
      _wallet = Wallet.fromJson(
        json.decode(walletString) as Map<String, dynamic>,
      );
    } on StorageException catch (_) {
      _wallet = null;
    }

    super.onInit();
  }

  String _getWalletAddress() {
    if (_wallet == null) {
      throw WalletException('No Wallet found');
    } else {
      return _wallet!.address;
    }
  }

  Map<String, dynamic> _getWalletKeystore() {
    if (_wallet == null) {
      throw WalletException('No Wallet found');
    } else {
      return _wallet!.keystore;
    }
  }

  List<String> generateMnemonic() {
    return Mnemonic.generate();
  }

  ///Create a new wallet from a given password and seed words and store it locally.
  void createWalletFromSeedWords(String password, List<String> seedWords) {
    final Uint8List privateKey = Mnemonic.derivePrivateKey(seedWords);
    final String address = Address.publicKeyToAddressString(
      derivePublicKeyFromBytes(privateKey, false),
    );
    final Map<String, dynamic> keystore = json.decode(
      Keystore.encrypt(privateKey, password),
    ) as Map<String, dynamic>;

    final Wallet wallet = Wallet(address, keystore);
    _wallet = wallet;
    _storage.setString('wallet', json.encode(wallet.toJson()));
  }

  ///Create a new wallet from a given password and PrivateKey and store it locally.
  void createWalletFromPrivateKey(String password, String privateKey) {
    final Uint8List privateKeyInBytes = hexToBytes(privateKey);
    final String address = Address.publicKeyToAddressString(
      derivePublicKeyFromBytes(privateKeyInBytes, false),
    );
    final Map<String, dynamic> keystore = json.decode(
      Keystore.encrypt(privateKeyInBytes, password),
    ) as Map<String, dynamic>;

    final Wallet wallet = Wallet(address, keystore);
    _wallet = wallet;
    _storage.setString('wallet', json.encode(wallet.toJson()));
  }

  String getPrivateKey(String password) {
    final Uint8List privateKey = Keystore.decrypt(
      json.encode(keystore),
      password,
    );
    return bytesToHex(privateKey);
  }

  void deleteWallet() {
    _wallet = null;
    _storage.remove('wallet');
  }

  bool validateMnemonic(List<String> words) {
    return Mnemonic.validate(words);
  }
}

class WalletException implements Exception {
  WalletException(this.message);
  final String message;
}

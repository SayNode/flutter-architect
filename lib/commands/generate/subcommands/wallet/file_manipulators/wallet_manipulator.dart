import '../../../../../interfaces/file_manipulator.dart';

class WalletManipulator extends FileManipulator {
  @override
  String get name => 'Wallet';

  @override
  String get path => 'lib/model/wallet.dart';

  @override
  String content() => """
class Wallet {
  Wallet(
    this.address,
    this.keystore,
  );

  Wallet.fromJson(Map<String, dynamic> json)
      : address = json['address'] as String,
        keystore = json['keystore'] as Map<String, dynamic>;

  final String address;

  final Map<String, dynamic> keystore;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'address': address,
        'keystore': keystore,
      };
}""";
}

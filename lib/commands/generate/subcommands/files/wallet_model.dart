String content() {
  return '''
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
}
''';
}

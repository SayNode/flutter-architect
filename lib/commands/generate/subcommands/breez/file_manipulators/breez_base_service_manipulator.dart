import '../../../../../interfaces/file_manipulator.dart';

class BreezBaseServiceManipulator extends FileManipulator {
  @override
  String get name => 'BreezBaseService';

  @override
  String get path => 'lib/base/breez_base_service.dart';

  @override
  String content() {
    return r"""
import 'dart:io';

import 'package:breez_sdk/breez_sdk.dart';
import 'package:breez_sdk/bridge_generated.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

abstract class BreezBaseService extends GetxService {
  final BreezSDK breezSDK = BreezSDK();
  final RxBool isConnected = false.obs;
  final Rx<NodeState> nodeState = const NodeState(
    channelsBalanceMsat: -1,
    onchainBalanceMsat: -1,
    id: '-1',
    blockHeight: -1,
    pendingOnchainBalanceMsat: -1,
    utxos: <UnspentTransactionOutput>[],
    maxPayableMsat: -1,
    maxReceivableMsat: -1,
    maxSinglePaymentAmountMsat: -1,
    maxChanReserveMsats: -1,
    connectedPeers: <String>[],
    inboundLiquidityMsats: -1,
  ).obs;

  @override
  void onInit() {
    breezSDK.initialize();
    super.onInit();
  }

  void onLogEntry(dynamic log) {
    // ignore: avoid_dynamic_calls
    debugPrint('Received log ${log.level}]: ${log.line}');
  }

  void logging(BreezSDK breezSDK) {
    breezSDK.logStream.listen(onLogEntry);
  }

  Future<void> connectToNode(String seedPhrase) async {
    // Load the Greenlight credentials
    final GreenlightCredentials greenlightCredentials =
        await _loadGreenlightCredentials();
    // Create the default config
    final Uint8List seed = await breezSDK.mnemonicToSeed(
      seedPhrase,
    );

    const String brrezApiKey = String.fromEnvironment('BREEZ_API_KEY');
    final NodeConfig nodeConfig = NodeConfig.greenlight(
      config: GreenlightNodeConfig(
        partnerCredentials: greenlightCredentials,
      ),
    );
    Config config = await breezSDK.defaultConfig(
      envType: EnvironmentType.Production,
      apiKey: brrezApiKey,
      nodeConfig: nodeConfig,
    );

    final Directory directory = await getApplicationDocumentsDirectory();
    config = config.copyWith(workingDir: directory.path);

// Connect to the Breez SDK make it ready for use
    final ConnectRequest connectRequest =
        ConnectRequest(config: config, seed: seed);
    final dynamic res = await breezSDK.connect(req: connectRequest);
    isConnected.value = true;
    return res;
  }

  ///Function to create an invoice. It takes in a [description] and an [amountInSatoshi] and returns a String of the invoice.
  Future<String> createInvoice({
    required String description,
    required int amountInSatoshi,
  }) async {
    try {
      final ReceivePaymentRequest req = ReceivePaymentRequest(
        amountMsat: amountInSatoshi * 1000,
        description: description,
      );
      final ReceivePaymentResponse receivePaymentResponse =
          await breezSDK.receivePayment(req: req);

      final String bolt11 = receivePaymentResponse.lnInvoice.bolt11;

      return bolt11;
    } catch (e) {
      throw Exception('BreezService -- Error creating invoice: $e');
    }
  }

  Future<SendPaymentResponse> sendPayment({required String bolt11}) async {
    try {
      final SendPaymentRequest req = SendPaymentRequest(bolt11: bolt11);
      final SendPaymentResponse sendPaymentResponse =
          await breezSDK.sendPayment(req: req);
      return sendPaymentResponse;
    } catch (e) {
      throw Exception('BreezService -- Error sending payment: $e');
    }
  }

  Future<List<Payment>> getPaymentHistory() async {
    try {
      const ListPaymentsRequest req = ListPaymentsRequest();
      final List<Payment> paymentsList = await breezSDK.listPayments(req: req);
      return paymentsList;
    } catch (e) {
      throw Exception('BreezService -- Error getting payment history: $e');
    }
  }

  Future<LspInformation?>? getCurrentLSP() async {
    //String? lspId = await breezSDK.lspId();
    final LspInformation? lspInfo = await breezSDK.lspInfo();
    return lspInfo;
  }

  Future<List<LspInformation>> getAvilableLSPs() async {
    final List<LspInformation> lsps = await breezSDK.listLsps();
    return lsps;
  }

  Future<void> switchLSP({required String lspId}) async {
    try {
      await breezSDK.connectLSP(lspId);
    } catch (e) {
      throw Exception('BreezService -- Error switching LSP: $e');
    }
  }

  Future<void> clearApplicationDocumentsDirectory() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    if (directory.existsSync()) {
      directory.listSync().forEach((FileSystemEntity file) {
        if (file is File) {
          file.deleteSync();
        } else if (file is Directory) {
          file.deleteSync(recursive: true);
        }
      });
    }
  }

  Future<NodeState?> getNodeState() async {
    final NodeState? nodeInfo = await breezSDK.nodeInfo();
    return nodeInfo;
  }

  Future<GreenlightCredentials> _loadGreenlightCredentials() async {
    final Uint8List greenlightDeveloperKey =
        (await rootBundle.load('asset/greenlight/client-key.pem'))
            .buffer
            .asUint8List();
    final Uint8List greenlightCertificate =
        (await rootBundle.load('asset/greenlight/client.crt'))
            .buffer
            .asUint8List();

    final GreenlightCredentials partnerCredentials = GreenlightCredentials(
      developerKey: greenlightDeveloperKey,
      developerCert: greenlightCertificate,
    );

    return partnerCredentials;
  }
}

""";
  }
}

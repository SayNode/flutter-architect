import '../../../../../interfaces/service_manipulator.dart';

class UpgraderServiceManipulator extends ServiceManipulator {
  @override
  String get name => 'UpgraderService';

  @override
  String get path => 'lib/service/upgrader_service.dart';

  @override
  String content() {
    return r'''
import 'dart:io';

import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';

class UpgraderService extends GetxService {
  PlayStoreSearchAPI playStoreSearchAPI =
      PlayStoreSearchAPI(client: http.Client());
  ITunesSearchAPI iTunesSearchAPI = ITunesSearchAPI();
  late PackageInfo packageInfo;
  late bool isUpdateAvailable;
  late String updateUrl;
  late String version;
  late String buildNumber;

  Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    isUpdateAvailable = !await checkIfAppOnLatestVersion();
  }

  Future<bool> checkIfAppOnLatestVersion() async {
    if (Platform.isAndroid) {
      return packageInfo.version ==
          (await _getVersionOnPlayStore(packageInfo.packageName));
    } else if (Platform.isIOS) {
      return packageInfo.version ==
          (await _getVersionOnAppStore(packageInfo.packageName));
    } else {
      return true;
    }
  }

  Future<String> _getVersionOnPlayStore(String packageName) async {
    final dom.Document? response =
        await playStoreSearchAPI.lookupById(packageName);
    updateUrl = 'market://details?id=$packageName';
    if (response != null) {
      return playStoreSearchAPI.version(response) ?? packageInfo.version;
    } else {
      return packageInfo.version;
    }
  }

  Future<String> _getVersionOnAppStore(String packageName) async {
    final Map<dynamic, dynamic>? response =
        await iTunesSearchAPI.lookupByBundleId(packageName);
    updateUrl = await _getIosStoreLink();
    if (response != null) {
      return iTunesSearchAPI.version(response) ?? packageInfo.version;
    } else {
      return packageInfo.version;
    }
  }

  Future<String> _getIosStoreLink() async {
    final Map<dynamic, dynamic>? res =
        await iTunesSearchAPI.lookupByBundleId('com.google.ios.youtube');
    final String trackId = ((res!['results'] as List<dynamic>)[0]
            as Map<String, dynamic>)['trackId']
        .toString();
    return '"https://apps.apple.com/app/id$trackId"';
  }
}

''';
  }
}

String content() {
  return """
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../model/language_model.dart';

class LocalizationController extends GetxController implements GetxService {
  Map<String, Map<String, String>> translations =
      <String, Map<String, String>>{};
  Locale get locale => _locale;
  final List<LanguageModel> _supportedLanguageList = <LanguageModel>[
    LanguageModel(
      imageUrl: '🇺🇸',
      languageName: 'English',
      languageCode: 'en',
      countryCode: 'US',
    ),
  ];
  final Locale _locale = const Locale(
    'en',
    'US',
  );
  Future<void> init() async {
    await _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    for (final LanguageModel languageModel in _supportedLanguageList) {
      final String jsonStringValues = await rootBundle
          .loadString('asset/locale/\${languageModel.languageCode}.json');
      final Map<String, dynamic> mappedJson =
          jsonDecode(jsonStringValues) as Map<String, dynamic>;
      final Map<String, String> json = <String, String>{};
      mappedJson.forEach((String key, dynamic value) {
        json[key] = value.toString();
      });
      translations[
          '\${languageModel.languageCode}_\${languageModel.countryCode}'] = json;
    }
  }
}
""";
}

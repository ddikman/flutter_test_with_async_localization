import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:test_with_async_localization/app_localizations.dart';

class AsyncAppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {

  static List<Locale> get supportedLocales => [
    const Locale('en', 'GB'),
    const Locale('sv', 'SE')
  ];

  @override
  bool isSupported(Locale locale) {
    if (supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
      return true;
    }
    print("Missing support for requested locale '${locale.countryCode}|${locale.languageCode}'.");
    return false;
  }

  @override
  bool shouldReload(AsyncAppLocalizationsDelegate old) => false;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    await Future.delayed(Duration(seconds: 1));
    return await AppLocalizations.load(locale);
  }
}
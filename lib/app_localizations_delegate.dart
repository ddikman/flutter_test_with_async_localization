import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:test_with_async_localization/app_localizations.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {

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
  bool shouldReload(AppLocalizationsDelegate old) => false;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return await AppLocalizations.load(locale);
  }
}
import 'dart:async';
import 'dart:ui';

import 'package:intl/intl.dart';

import 'package:flutter/widgets.dart';
import 'package:test_with_async_localization/l10n/messages_all.dart';

class AppLocalizations {

  AppLocalizations();

  static Future<AppLocalizations> load(Locale locale) async {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    print("Initializing localisations for '$localeName'.");

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get mainScreenLabel => Intl.message(
      "This is a test app"
  );
}
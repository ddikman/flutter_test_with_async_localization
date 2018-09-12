import 'package:flutter/widgets.dart';
import 'package:test_with_async_localization/app_localizations.dart';

class LocalizedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(AppLocalizations.of(context).mainScreenLabel);
  }
}
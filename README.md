# Testing flutter with async loaded localizations

During a different project I found that the rendered widget tree was completely empty when I was adding my localizations delegate. Of course, I needed this delegate since without it my localizations could not be accessed.

Digging into the issue it seemed that the Localizations widget which loads and keeps the localizations defers the loading of the first frame until the time when all localizations have been loaded. This is fair enough but it seems that the flutter testing framework never reloads the tree when pumping due to this, in other words, our tree never gets rendered.

# Proving tests
Take a look at the `localization_tests.dart` in the tests folder. This file highlights two seemingly identical tests, one failing and one succeeding.
The only difference between the two is that the one is using a LocalizationDelegate which has an async operation.

The printouts from each test shows us that the successful test has a proper widget tree as this:
```
MaterialApp
ScrollConfiguration(behavior: _MaterialScrollBehavior)
AnimatedTheme(duration: 200ms)
MaterialApp
...
Builder
Semantics(container: false, properties: SemanticsProperties, label: null, value: null, hint: null)
LocalizedWidget
Text("This is a test app")
```

Whilst the failing test simply gives us a very empty tree instead.

```
ScrollConfiguration(behavior: _MaterialScrollBehavior)
AnimatedTheme(duration: 200ms)
Theme(ThemeData#59053(buttonTheme: ButtonThemeData#6df6b, textTheme: TextTheme#574a2, primaryTextTheme: TextTheme#a788d(display4: TextStyle(debugLabel: whiteMountainView display4, inherit: true, color: Color(0xb3ffffff), family: Roboto, decoration: TextDecoration.none), display3: TextStyle(debugLabel: whiteMountainView display3, inherit: true, color: Color(0xb3ffffff), family: Roboto, decoration: TextDecoration.none), display2: TextStyle(debugLabel: whiteMountainView display2, inherit: true, color: Color(0xb3ffffff), family: Roboto, decoration: TextDecoration.none), display1: TextStyle(debugLabel: whiteMountainView display1, inherit: true, color: Color(0xb3ffffff), family: Roboto, decoration: TextDecoration.none), headline: TextStyle(debugLabel: whiteMountainView headline, inherit: true, color: Color(0xffffffff), family: Roboto, decoration: TextDecoration.none), title: TextStyle(debugLabel: whiteMountainView title, inherit: true, color: Color(0xffffffff), family: Roboto, decoration: TextDecoration.none), subhead: TextStyle(debugLabel: whiteMountainView subhead, inherit: true, color: Color(0xffffffff), family: Roboto, decoration: TextDecoration.none), body2: TextStyle(debugLabel: whiteMountainView body2, inherit: true, color: Color(0xffffffff), family: Roboto, decoration: TextDecoration.none), body1: TextStyle(debugLabel: whiteMountainView body1, inherit: true, color: Color(0xffffffff), family: Roboto, decoration: TextDecoration.none), caption: TextStyle(debugLabel: whiteMountainView caption, inherit: true, color: Color(0xb3ffffff), family: Roboto, decoration: TextDecoration.none), button: TextStyle(debugLabel: whiteMountainView button, inherit: true, color: Color(0xffffffff), family: Roboto, decoration: TextDecoration.none)), accentTextTheme: TextTheme#a788d(display4: TextStyle(debugLabel: whiteMountainView display4, inherit: true, color: Color(0xb3ffffff), family: Roboto, decoration: TextDecoration.none), display3: TextStyle(debugLabel: whiteMountainView display3, inherit: true, color: Color(0xb3ffffff), family: Roboto, decoration: TextDecoration.none), display2: TextStyle(debugLabel: whiteMountainView display2, inherit: true, color: Color(0xb3ffffff), family: Roboto, decoration: TextDecoration.none), display1: TextStyle(debugLabel: whiteMountainView display1, inherit: true, color: Color(0xb3ffffff), family: Roboto, decoration: TextDecoration.none), headline: TextStyle(debugLabel: whiteMountainView headline, inherit: true, color: Color(0xffffffff), family: Roboto, decoration: TextDecoration.none), title: TextStyle(debugLabel: whiteMountainView title, inherit: true, color: Color(0xffffffff), family: Roboto, decoration: TextDecoration.none), subhead: TextStyle(debugLabel: whiteMountainView subhead, inherit: true, color: Color(0xffffffff), family: Roboto, decoration: TextDecoration.none), body2: TextStyle(debugLabel: whiteMountainView body2, inherit: true, color: Color(0xffffffff), family: Roboto, decoration: TextDecoration.none), body1: TextStyle(debugLabel: whiteMountainView body1, inherit: true, color: Color(0xffffffff), family: Roboto, decoration: TextDecoration.none), caption: TextStyle(debugLabel: whiteMountainView caption, inherit: true, color: Color(0xb3ffffff), family: Roboto, decoration: TextDecoration.none), button: TextStyle(debugLabel: whiteMountainView button, inherit: true, color: Color(0xffffffff), family: Roboto, decoration: TextDecoration.none)), inputDecorationTheme: InputDecorationTheme#e1652, iconTheme: IconThemeData#a143c(color: Color(0xff000000)), primaryIconTheme: IconThemeData#15fa8(color: Color(0xffffffff)), accentIconTheme: IconThemeData#15fa8(color: Color(0xffffffff)), sliderTheme: SliderThemeData#7a172, chipTheme: ChipThemeData#4326f))
_InheritedTheme
IconTheme(IconThemeData#a143c(color: Color(0xff000000)))
WidgetsApp-[GlobalObjectKey _MaterialAppState#dcc8c]
MediaQuery(MediaQueryData(size: Size(800.0, 600.0), devicePixelRatio: 3.0, textScaleFactor: 1.0, padding: EdgeInsets.zero, viewInsets: EdgeInsets.zero, alwaysUse24HourFormat: false))
Localizations(locale: en_GB, delegates: [AsyncAppLocalizationsDelegate[AppLocalizations], _MaterialLocalizationsDelegate[MaterialLocalizations], _WidgetsLocalizationsDelegate[WidgetsLocalizations]])
Container
LimitedBox(maxWidth: 0.0, maxHeight: 0.0)
ConstrainedBox(BoxConstraints(biggest))
```

# Source
I believe the issue stems from the Localizations locale not existing until the localizations are loaded as can bee seen in [localizations.dart:545](https://github.com/flutter/flutter/blob/354416e8c213da7e9dfc8c9a7c2b304bfec0ab48/packages/flutter/lib/src/widgets/localizations.dart#L545).

If any of the localization delegates are async it seems the locale is set only first when all are loaded as in [localizations.dart:525](https://github.com/flutter/flutter/blob/354416e8c213da7e9dfc8c9a7c2b304bfec0ab48/packages/flutter/lib/src/widgets/localizations.dart#L525).

This works perfectly when running the app but in the tests the framework seems not to rebuild after `WidgetsBinding.instance.allowFirstFrameReport();` and the `setState` has been called.
 

# Generating the localizations

Just for reference, these are the two commands required to (re)generate the localization files.

```bash
flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/app_localizations.dart --output-file=intl_en.arb
flutter pub pub run intl_translation:generate_from_arb --no-use-deferred-loading --output-dir=lib/l10n lib/app_localizations.dart lib/l10n/intl*.arb
```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_with_async_localization/app_localizations_delegate.dart';
import 'package:test_with_async_localization/async_app_localizations_delegate.dart';
import 'package:test_with_async_localization/localized_widget.dart';

void main() {
  testWidgets('MaterialApp with async localization', (WidgetTester tester) async {
    await tester.pumpWidget(new MaterialApp(
      localizationsDelegates: [
        AsyncAppLocalizationsDelegate()
      ],
      supportedLocales: AsyncAppLocalizationsDelegate.supportedLocales,
      home: new LocalizedWidget(),
    ));

    // just to prove there's nothing else we need to wait for
    await tester.pumpAndSettle();

    printTree(tester.allWidgets);

    // and surprisingly this fails
    expect(find.byType(LocalizedWidget), findsOneWidget);
  });

  testWidgets('MaterialApp with sync localization', (WidgetTester tester) async {
    await tester.pumpWidget(new MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate()
      ],
      supportedLocales: AppLocalizationsDelegate.supportedLocales,
      home: new LocalizedWidget(),
    ));

    // just to prove there's nothing else we need to wait for
    await tester.pumpAndSettle();

    printTree(tester.allWidgets);

    // and this succeeds without any problem as we would expect
    expect(find.byType(LocalizedWidget), findsOneWidget);
  });
}

/// Prints all widgets just to show what is being rendered
void printTree(Iterable<Widget> allWidgets) {
  for (Widget widget in allWidgets) {
    print(widget);
  }
}

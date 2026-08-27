import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fight_camp/l10n/app_localizations.dart';

void main() {
  test('generated localizations resolve lookups in both languages', () {
    final it = lookupAppLocalizations(const Locale('it'));
    final en = lookupAppLocalizations(const Locale('en'));
    expect(it.navTrain, 'Allenati');
    expect(en.navTrain, 'Train');
    expect(en.commonCancel, 'Cancel');
    expect(it.commonCancel, 'Annulla');
  });

  test('placeholders are generated', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.pickerDone(3), 'Done (3)');
    final it = lookupAppLocalizations(const Locale('it'));
    expect(it.pickerDone(3), 'Fatto (3)');
  });

  testWidgets('MaterialApp resolves unsupported locales to Italian', (tester) async {
    late AppLocalizations captured;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (deviceLocale, supported) {
        for (final l in supported) {
          if (l.languageCode == deviceLocale?.languageCode) return l;
        }
        return const Locale('it');
      },
      locale: const Locale('fr'),
      home: Builder(builder: (context) {
        captured = AppLocalizations.of(context)!;
        return const SizedBox();
      }),
    ));
    expect(captured.navTrain, 'Allenati');
  });
}

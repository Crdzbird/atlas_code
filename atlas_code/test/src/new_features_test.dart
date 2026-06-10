import 'dart:ui' show Locale;

import 'package:atlas_code/atlas_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CountryCode enum', () {
    test('has one value per country, in dataset order', () {
      expect(CountryCode.values.length, Countries.all.length);
      expect(
        CountryCode.values.map((code) => code.name),
        Countries.all.map((country) => country.alpha2),
      );
    });

    test('reserved-word codes exist in uppercase form', () {
      // India, Iceland, Dominican Republic, American Samoa — lowercase
      // would collide with Dart keywords.
      expect(CountryCode.IN.country.name, 'India');
      expect(CountryCode.IS.country.name, 'Iceland');
      expect(CountryCode.DO.country.name, 'Dominican Republic');
      expect(CountryCode.AS.country.name, 'American Samoa');
    });

    test('Countries.of is non-nullable and round-trips', () {
      final us = Countries.of(CountryCode.US);
      expect(us.alpha2, 'US');
      expect(us.code, CountryCode.US);
      for (final code in CountryCode.values) {
        expect(Countries.of(code).code, code);
      }
    });
  });

  group('richer fields', () {
    test('capitals, tlds, borders and coordinates are populated', () {
      final pt = Countries.of(CountryCode.PT);
      expect(pt.capitals, ['Lisbon']);
      expect(pt.tlds, ['.pt']);
      expect(pt.borderAlpha3Codes, ['ESP']);
      expect(pt.latitude, isNotNull);
      expect(pt.longitude, isNotNull);
    });

    test('neighbors resolve to countries', () {
      final de = Countries.of(CountryCode.DE);
      final neighborCodes = de.neighbors.map((c) => c.alpha2);
      expect(neighborCodes, containsAll(['FR', 'PL', 'AT', 'CH']));
    });

    test('landlocked-free territories have empty borders', () {
      expect(Countries.of(CountryCode.IS).borderAlpha3Codes, isEmpty);
    });
  });

  group('Currency', () {
    test('currency lookup is case-insensitive and typed', () {
      final eur = Countries.currency('eur');
      expect(eur, isNotNull);
      expect(eur!.name, 'Euro');
      expect(eur.symbol, '€');
      expect(Countries.currency('XXX'), isNull);
    });

    test('country currencies resolve from codes', () {
      final us = Countries.of(CountryCode.US);
      expect(us.currencies.single, Countries.currency('USD'));
      expect(us.currencies.single.symbol, r'$');
    });

    test('byCurrency finds the eurozone', () {
      final eurozone = Countries.byCurrency('EUR').map((c) => c.alpha2);
      expect(eurozone, containsAll(['PT', 'DE', 'FR', 'ES']));
      expect(eurozone, isNot(contains('US')));
    });

    test('currencies equal by code', () {
      expect(
        Countries.currency('USD'),
        const Currency(code: 'USD', name: 'x', symbol: 'y'),
      );
    });
  });

  group('Countries.byPhoneNumber', () {
    test('longest prefix wins over a shared plan', () {
      expect(
        Countries.byPhoneNumber('+1 684 555 0100').single.alpha2,
        'AS',
      );
      expect(
        Countries.byPhoneNumber('+1 212 555 0100').map((c) => c.alpha2),
        containsAll(['US', 'CA']),
      );
    });

    test('resolves nested territory prefixes', () {
      expect(Countries.byPhoneNumber('+358 18 1234').single.alpha2, 'AX');
      expect(Countries.byPhoneNumber('+358 40 1234').single.alpha2, 'FI');
    });

    test('accepts 00 prefix and separators', () {
      expect(
        Countries.byPhoneNumber('00351 912-345-678').single.alpha2,
        'PT',
      );
      // +44 is shared by the UK and its Crown Dependencies.
      expect(
        Countries.byPhoneNumber('+44 (0) 7700 900123').map((c) => c.alpha2),
        containsAll(['GB', 'GG', 'IM', 'JE']),
      );
    });

    test('rejects national or malformed input', () {
      expect(Countries.byPhoneNumber('912345678'), isEmpty);
      expect(Countries.byPhoneNumber('+'), isEmpty);
      expect(Countries.byPhoneNumber('+abc'), isEmpty);
      expect(Countries.byPhoneNumber(''), isEmpty);
      expect(Countries.byPhoneNumber('+999 123'), isEmpty);
    });
  });

  group('search and sorting', () {
    const names = LocalizedCountryNames(
      languageTag: 'es',
      names: {'ES': 'España', 'DE': 'Alemania', 'US': 'Estados Unidos'},
      isFallback: false,
    );

    test('foldedDiacritics folds and lowercases', () {
      expect('España'.foldedDiacritics, 'espana');
      expect('Åland'.foldedDiacritics, 'aland');
      expect('Curaçao'.foldedDiacritics, 'curacao');
      expect('Türkiye'.foldedDiacritics, 'turkiye');
    });

    test('localized search ignores diacritics and case', () {
      expect(
        names.search('espana').map((c) => c.alpha2),
        contains('ES'),
      );
      expect(
        names.search('ALEMANIA').single.alpha2,
        'DE',
      );
    });

    test('search also matches English names, codes and dial codes', () {
      expect(names.search('germany').single.alpha2, 'DE');
      expect(names.search('de').map((c) => c.alpha2), contains('DE'));
      expect(names.search('+351').single.alpha2, 'PT');
      expect(names.search('351').single.alpha2, 'PT');
    });

    test('sortedCountries orders by localized name', () {
      final sorted = names.sortedCountries();
      final de = sorted.indexWhere((c) => c.alpha2 == 'DE');
      final es = sorted.indexWhere((c) => c.alpha2 == 'ES');
      final us = sorted.indexWhere((c) => c.alpha2 == 'US');
      // Alemania < España < Estados Unidos.
      expect(de, lessThan(es));
      expect(es, lessThan(us));
    });

    test('English matcher works without localized names', () {
      final spain = Countries.of(CountryCode.ES);
      expect(spain.matches('spain'), isTrue);
      expect(spain.matches('esp'), isTrue);
      expect(spain.matches('germany'), isFalse);
    });
  });

  group('flag emoji support', () {
    test('reports support off Windows', () {
      // Tests run with a non-Windows defaultTargetPlatform on this host.
      expect(Countries.flagEmojiSupported, isTrue);
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      expect(Countries.flagEmojiSupported, isFalse);
    });
  });

  group('deviceLocaleChanges', () {
    testWidgets('emits when the platform locales change', (tester) async {
      final atlas = AtlasCode();
      final received = <Locale>[];
      final countries = <Country?>[];
      final localeSub = atlas.deviceLocaleChanges.listen(received.add);
      final countrySub = atlas.deviceCountryChanges.listen(countries.add);
      addTearDown(localeSub.cancel);
      addTearDown(countrySub.cancel);

      tester.binding.platformDispatcher.localesTestValue = [
        const Locale('pt', 'PT'),
      ];
      await tester.pump();

      expect(received, [const Locale('pt', 'PT')]);
      expect(countries, [Countries.of(CountryCode.PT)]);
    });
  });
}

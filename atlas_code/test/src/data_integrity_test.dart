import 'package:atlas_code/atlas_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bundled dataset', () {
    test('contains every ISO 3166-1 entity', () {
      expect(Countries.all.length, 250);
    });

    test('alpha-2 codes are unique, uppercase and sorted', () {
      final codes = Countries.all.map((c) => c.alpha2).toList();
      expect(codes.toSet().length, codes.length);
      for (final code in codes) {
        expect(code, matches(RegExp(r'^[A-Z]{2}$')));
      }
      final sorted = [...codes]..sort();
      expect(codes, sorted);
    });

    test('alpha-3 codes are unique and well-formed', () {
      final codes = Countries.all.map((c) => c.alpha3).toList();
      expect(codes.toSet().length, codes.length);
      for (final code in codes) {
        expect(code, matches(RegExp(r'^[A-Z]{3}$')));
      }
    });

    test('numeric codes are unique and three digits where assigned', () {
      final codes = Countries.all
          .map((c) => c.numeric)
          .whereType<String>()
          .toList();
      expect(codes.toSet().length, codes.length);
      for (final code in codes) {
        expect(code, matches(RegExp(r'^\d{3}$')));
      }
    });

    test('dial codes are well-formed where assigned', () {
      for (final country in Countries.all) {
        final dial = country.dialCode;
        if (dial != null) {
          // Up to 7 digits: dependent territories carry an in-plan prefix
          // (e.g. Åland is +35818 inside Finland's +358).
          expect(dial, matches(RegExp(r'^\+\d{1,7}$')), reason: country.alpha2);
        }
      }
    });

    test('names are never empty', () {
      for (final country in Countries.all) {
        expect(country.name, isNotEmpty);
        expect(country.officialName, isNotEmpty);
      }
    });

    test('spot checks match known facts', () {
      final us = Countries.fromAlpha2('US')!;
      expect(us.alpha3, 'USA');
      expect(us.numeric, '840');
      expect(us.dialCode, '+1');
      expect(us.currencyCodes, ['USD']);
      expect(us.flagEmoji, '🇺🇸');
      expect(us.unMember, isTrue);

      final pt = Countries.fromAlpha2('PT')!;
      expect(pt.name, 'Portugal');
      expect(pt.dialCode, '+351');
      expect(pt.currencyCodes, ['EUR']);

      // Entities without an assigned numeric / dial code.
      expect(Countries.fromAlpha2('XK')!.numeric, isNull);
      expect(Countries.fromAlpha2('AQ')!.dialCode, isNull);
    });
  });
}

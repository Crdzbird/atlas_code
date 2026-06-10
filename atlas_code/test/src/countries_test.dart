import 'dart:ui' show Locale;

import 'package:atlas_code/atlas_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Countries', () {
    test('fromAlpha2 is case-insensitive', () {
      expect(Countries.fromAlpha2('us')?.name, 'United States');
      expect(Countries.fromAlpha2('Us')?.name, 'United States');
    });

    test('fromAlpha2 remaps deprecated region codes', () {
      expect(Countries.fromAlpha2('YU')?.alpha2, 'RS');
      expect(Countries.fromAlpha2('AN')?.alpha2, 'NL');
      expect(Countries.fromAlpha2('TP')?.alpha2, 'TL');
    });

    test('fromAlpha2 returns null for unknown codes', () {
      expect(Countries.fromAlpha2('ZZ'), isNull);
    });

    test('fromAlpha3 resolves codes case-insensitively', () {
      expect(Countries.fromAlpha3('prt')?.alpha2, 'PT');
      expect(Countries.fromAlpha3('ZZZ'), isNull);
    });

    test('fromNumeric handles zero-padding', () {
      expect(Countries.fromNumeric('840')?.alpha2, 'US');
      expect(Countries.fromNumeric('40')?.alpha2, 'AT');
      expect(Countries.fromNumeric('999'), isNull);
    });

    test('fromCode dispatches across code systems', () {
      expect(Countries.fromCode('US')?.alpha2, 'US');
      expect(Countries.fromCode('USA')?.alpha2, 'US');
      expect(Countries.fromCode('840')?.alpha2, 'US');
      expect(Countries.fromCode('40')?.alpha2, 'AT');
      expect(Countries.fromCode(' pt ')?.alpha2, 'PT');
      expect(Countries.fromCode('invalid'), isNull);
    });

    test('withDialCode returns every NANP country for +1', () {
      final nanp = Countries.withDialCode('+1').map((c) => c.alpha2);
      expect(nanp, containsAll(['US', 'CA']));
      // Accepts the prefix without the plus sign too.
      expect(Countries.withDialCode('351').single.alpha2, 'PT');
    });

    test('forLocale resolves the region and tolerates missing one', () {
      expect(
        Countries.forLocale(const Locale('en', 'US'))?.alpha2,
        'US',
      );
      expect(Countries.forLocale(const Locale('en')), isNull);
    });

    test('unMembers excludes dependent territories', () {
      final members = Countries.unMembers;
      expect(members.map((c) => c.alpha2), contains('US'));
      expect(members.map((c) => c.alpha2), isNot(contains('PR')));
      expect(members.length, 193);
    });

    test('countries equal by alpha-2 identity', () {
      expect(
        Countries.fromAlpha2('US'),
        equals(Countries.fromAlpha3('USA')),
      );
      expect(
        Countries.fromAlpha2('US').hashCode,
        Countries.fromAlpha3('USA').hashCode,
      );
    });

    test('flag emoji is derived from alpha-2', () {
      expect(Countries.fromAlpha2('PT')?.flagEmoji, '🇵🇹');
      expect(Countries.fromAlpha2('DE')?.flagEmoji, '🇩🇪');
    });
  });
}

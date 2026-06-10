import 'package:atlas_code/atlas_code.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue _value(String text, [int? offset]) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: offset ?? text.length),
);

void main() {
  group('DialCodeFormatter', () {
    test('normalizes a prefix given without a plus sign', () {
      final formatter = DialCodeFormatter('351');
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        _value('9'),
      );
      expect(result.text, '+351 9');
    });

    test('prepends the dial code on first input', () {
      final formatter = DialCodeFormatter('+351');
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        _value('91'),
      );
      expect(result.text, '+351 91');
      expect(result.selection.baseOffset, result.text.length);
    });

    test('leaves conforming input untouched', () {
      final formatter = DialCodeFormatter('+351');
      final input = _value('+351 912', 6);
      final result = formatter.formatEditUpdate(_value('+351 91'), input);
      expect(result, same(input));
    });

    test('restores the prefix when the user deletes into it', () {
      final formatter = DialCodeFormatter('+351');
      final result = formatter.formatEditUpdate(
        _value('+351 912'),
        _value('+351912'),
      );
      expect(result.text, '+351 912');
    });

    test('replaces a pasted foreign dial code', () {
      final formatter = DialCodeFormatter('+351');
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        _value('+44 7700 900123'),
      );
      expect(result.text, '+351 7700 900123');
    });

    test('forCountry uses the country dial code', () {
      final formatter = DialCodeFormatter.forCountry(
        Countries.fromAlpha2('PT')!,
      );
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        _value(''),
      );
      expect(result.text, '+351 ');
    });

    test('forCountry asserts on countries without a dial code', () {
      expect(
        () => DialCodeFormatter.forCountry(Countries.fromAlpha2('AQ')!),
        throwsAssertionError,
      );
    });
  });
}

import 'package:atlas_code/src/models/country.dart';
import 'package:flutter/services.dart';

/// A [TextInputFormatter] that keeps a country's dial code (e.g. `+351 `)
/// as an immutable prefix of a phone-number field.
///
/// Unlike naive prefix formatters, it survives paste, select-all-delete and
/// attempts to edit inside the prefix: the prefix is restored and the
/// remaining digits are preserved, with the cursor kept after the edit.
class DialCodeFormatter extends TextInputFormatter {
  /// Creates a formatter enforcing [dialCode] (with or without the leading
  /// `+`) followed by a space.
  DialCodeFormatter(String dialCode)
    : assert(dialCode.isNotEmpty, 'dialCode must not be empty'),
      _prefix = '${dialCode.startsWith('+') ? dialCode : '+$dialCode'} ';

  /// Creates a formatter for [country]'s dial code.
  ///
  /// [country] must have a dial code — territories such as Antarctica do
  /// not, and there is no sensible prefix to enforce for them.
  DialCodeFormatter.forCountry(Country country)
    : assert(
        country.dialCode != null,
        '${country.name} has no dial code to enforce',
      ),
      _prefix = '${country.dialCode} ';

  final String _prefix;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith(_prefix)) return newValue;

    // The edit broke the prefix (deletion into it, paste over it, or first
    // input). Keep everything that isn't a leading dial code and re-attach
    // the prefix.
    final input = newValue.text.trimLeft();
    final String remainder;
    if (input.startsWith('+')) {
      final dialDigits = _prefix.substring(1).trim();
      final digits = input.substring(1);
      remainder = digits.startsWith(dialDigits)
          // Our own dial code with mangled separators — keep what follows.
          ? digits.substring(dialDigits.length).trimLeft()
          // A foreign dial code — drop it, keep the subscriber part.
          : digits.replaceFirst(RegExp(r'^\d*[\s\-./]*'), '');
    } else {
      remainder = input;
    }
    final text = '$_prefix$remainder';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

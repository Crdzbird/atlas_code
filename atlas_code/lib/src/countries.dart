import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:atlas_code/src/data/countries.g.dart';
import 'package:atlas_code/src/data/country_code.g.dart';
import 'package:atlas_code/src/data/currencies.g.dart';
import 'package:atlas_code/src/data/subregion_mapping.dart';
import 'package:atlas_code/src/models/country.dart';
import 'package:atlas_code/src/models/currency.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

/// Synchronous lookups over the bundled ISO 3166-1 dataset.
///
/// All lookups are O(1) (backed by lazily-built indexes), case-insensitive,
/// and never throw — unknown codes return `null`.
abstract final class Countries {
  /// Every country and territory in the dataset, sorted by alpha-2 code.
  static List<Country> get all => allCountries;

  /// Only the countries that are members of the United Nations.
  ///
  /// Useful for pickers that should not list dependent territories.
  static List<Country> get unMembers =>
      allCountries.where((country) => country.unMember).toList();

  static final Map<String, Country> _byAlpha2 = {
    for (final country in allCountries) country.alpha2: country,
  };

  static final Map<String, Country> _byAlpha3 = {
    for (final country in allCountries) country.alpha3: country,
  };

  static final Map<String, Country> _byNumeric = {
    for (final country in allCountries) ?country.numeric: country,
  };

  /// The country for an ISO 3166-1 alpha-2 [code] (e.g. `US`).
  ///
  /// Deprecated and special-use codes some devices report (e.g. `AN`, `YU`)
  /// are remapped to their current equivalent.
  static Country? fromAlpha2(String code) {
    final normalized = code.toUpperCase();
    return _byAlpha2[normalized] ??
        _byAlpha2[subregionToAlpha2[normalized] ?? ''];
  }

  /// The country for an ISO 3166-1 alpha-3 [code] (e.g. `USA`).
  static Country? fromAlpha3(String code) => _byAlpha3[code.toUpperCase()];

  /// The country for an ISO 3166-1 numeric [code], with or without
  /// zero-padding (e.g. `840`, `40`).
  static Country? fromNumeric(String code) => _byNumeric[code.padLeft(3, '0')];

  /// The country for any ISO 3166-1 [code] — alpha-2, alpha-3 or numeric.
  static Country? fromCode(String code) {
    final trimmed = code.trim();
    if (int.tryParse(trimmed) != null) return fromNumeric(trimmed);
    return switch (trimmed.length) {
      2 => fromAlpha2(trimmed),
      3 => fromAlpha3(trimmed),
      _ => null,
    };
  }

  /// Every country using the international dialing [prefix]
  /// (e.g. `+1` matches both the United States and Canada).
  static List<Country> withDialCode(String prefix) {
    final normalized = prefix.startsWith('+') ? prefix : '+$prefix';
    return allCountries
        .where((country) => country.dialCode == normalized)
        .toList();
  }

  /// The country a [locale]'s region refers to, or `null` when the locale
  /// carries no recognizable country code.
  static Country? forLocale(Locale locale) {
    final code = locale.countryCode;
    if (code == null || code.isEmpty) return null;
    return fromAlpha2(code);
  }

  /// The country configured in the device's region settings, derived from
  /// the platform locale — available synchronously, no initialization
  /// required.
  ///
  /// `null` when the platform reports no region (common on misconfigured
  /// simulators).
  static Country? get current => forLocale(PlatformDispatcher.instance.locale);

  /// The country for a type-safe [CountryCode] — never `null`, since the
  /// enum is generated from the same dataset.
  static Country of(CountryCode code) => _byAlpha2[code.name]!;

  /// Every ISO 4217 currency in the dataset, sorted by code.
  static List<Currency> get currencies => currenciesByCode.values.toList();

  /// The currency for an ISO 4217 [code] (e.g. `EUR`), or `null` when
  /// unknown.
  static Currency? currency(String code) =>
      currenciesByCode[code.toUpperCase()];

  /// Every country officially using the currency with ISO 4217 [code].
  static List<Country> byCurrency(String code) {
    final normalized = code.toUpperCase();
    return allCountries
        .where((country) => country.currencyCodes.contains(normalized))
        .toList();
  }

  static final Map<String, List<Country>> _byDialDigits = () {
    final map = <String, List<Country>>{};
    for (final country in allCountries) {
      if (country.dialCode case final dial?) {
        map.putIfAbsent(dial.substring(1), () => []).add(country);
      }
    }
    return map;
  }();

  static final int _longestDialCode = _byDialDigits.keys.fold(
    0,
    (longest, digits) => digits.length > longest ? digits.length : longest,
  );

  /// The countries whose dial code is the longest prefix of an
  /// international [phoneNumber].
  ///
  /// The number must be in international form — starting with `+` or `00` —
  /// since national formats are inherently ambiguous; anything else returns
  /// an empty list. Separators (spaces, dashes, dots, parentheses) are
  /// ignored.
  ///
  /// Longest match wins: `+1 684 555 0100` resolves to American Samoa
  /// (`+1684`) rather than the whole `+1` numbering plan, while
  /// `+1 212 555 0100` returns every `+1` country (alpha-2 order).
  static List<Country> byPhoneNumber(String phoneNumber) {
    var normalized = phoneNumber.replaceAll(RegExp(r'[\s\-.() ]'), '');
    if (normalized.startsWith('00')) {
      normalized = '+${normalized.substring(2)}';
    }
    if (!normalized.startsWith('+')) return const [];
    final digits = normalized.substring(1);
    if (digits.isEmpty || digits.contains(RegExp(r'\D'))) return const [];

    var best = const <Country>[];
    final maxLength = digits.length < _longestDialCode
        ? digits.length
        : _longestDialCode;
    for (var length = 1; length <= maxLength; length++) {
      best = _byDialDigits[digits.substring(0, length)] ?? best;
    }
    return List.unmodifiable(best);
  }

  /// Whether [Country.flagEmoji] renders as an actual flag on this
  /// platform.
  ///
  /// Windows (including browsers running on Windows) ships no flag emoji
  /// font, so flags appear as letter pairs there — use this to decide
  /// between emoji and a custom flag asset. On Linux, rendering depends on
  /// the installed emoji font (commonly Noto Color Emoji, which includes
  /// flags); this getter reports `true` there.
  static bool get flagEmojiSupported =>
      defaultTargetPlatform != TargetPlatform.windows;
}

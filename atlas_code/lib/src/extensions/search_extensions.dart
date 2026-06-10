import 'package:atlas_code/src/countries.dart';
import 'package:atlas_code/src/extensions/string_extensions.dart';
import 'package:atlas_code/src/models/country.dart';
import 'package:atlas_code/src/models/localized_country_names.dart';

/// Whether [country] matches the folded [query], optionally also against a
/// localized [name].
bool _matches(Country country, String query, String? name) {
  if (query.isEmpty) return true;
  final digits = query.replaceAll(RegExp(r'[+\s]'), '');
  return country.name.foldedDiacritics.contains(query) ||
      (name != null && name.foldedDiacritics.contains(query)) ||
      country.alpha2.toLowerCase() == query ||
      country.alpha3.toLowerCase() == query ||
      (digits.isNotEmpty &&
          int.tryParse(digits) != null &&
          (country.dialCode?.substring(1).startsWith(digits) ?? false));
}

/// Diacritic-insensitive search over the English dataset.
extension CountriesSearch on Country {
  /// Whether this country matches [query] by English name (ignoring
  /// diacritics and case), alpha-2/alpha-3 code, or dial-code prefix.
  bool matches(String query) =>
      _matches(this, query.trim().foldedDiacritics, null);
}

/// Search and sorting over OS-localized country names.
extension LocalizedCountryNamesSearch on LocalizedCountryNames {
  /// The countries matching [query] against their localized name, English
  /// name, alpha-2/alpha-3 code, or dial-code prefix — ignoring case and
  /// Latin diacritics (`espana` finds `España`).
  ///
  /// An empty query returns every country, sorted like [sortedCountries].
  List<Country> search(String query) {
    final folded = query.trim().foldedDiacritics;
    return [
      for (final country in sortedCountries())
        if (_matches(country, folded, of(country))) country,
    ];
  }

  /// Every country sorted alphabetically by localized name.
  ///
  /// Ordering uses diacritic folding rather than full ICU collation — an
  /// approximation that is correct for the typical picker use case.
  List<Country> sortedCountries() {
    final countries = [...Countries.all]
      ..sort(
        (a, b) => of(a).foldedDiacritics.compareTo(of(b).foldedDiacritics),
      );
    return countries;
  }
}

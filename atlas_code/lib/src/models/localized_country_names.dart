import 'package:atlas_code/src/models/country.dart';

/// {@template localized_country_names}
/// Country display names localized to a specific language, keyed by
/// uppercase ISO 3166-1 alpha-2 code.
///
/// Obtained from the operating system's locale data when available, or the
/// bundled English names otherwise — see [isFallback].
/// {@endtemplate}
final class LocalizedCountryNames {
  /// {@macro localized_country_names}
  const LocalizedCountryNames({
    required this.languageTag,
    required this._names,
    required this.isFallback,
  });

  /// The BCP-47 language tag the names are localized to (e.g. `pt-PT`).
  final String languageTag;

  /// Whether these names come from the bundled English dataset because the
  /// platform provided no localization data.
  final bool isFallback;

  final Map<String, String> _names;

  /// The localized name for an ISO 3166-1 alpha-2 [code], or `null` when
  /// unknown.
  String? operator [](String code) => _names[code.toUpperCase()];

  /// The localized name for [country], falling back to its English name.
  String of(Country country) => _names[country.alpha2] ?? country.name;

  /// An unmodifiable view of all names, keyed by alpha-2 code.
  Map<String, String> get asMap => Map.unmodifiable(_names);

  @override
  String toString() =>
      'LocalizedCountryNames($languageTag, ${_names.length} entries'
      '${isFallback ? ', fallback' : ''})';
}

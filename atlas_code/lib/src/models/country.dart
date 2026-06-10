/// {@template country}
/// An immutable description of a country or territory as defined by
/// ISO 3166-1, enriched with dialing, currency and region metadata.
///
/// Instances are bundled with the package as compile-time constants and
/// generated from the maintained
/// [mledoze/countries](https://github.com/mledoze/countries) dataset.
/// {@endtemplate}
final class Country {
  /// {@macro country}
  const Country({
    required this.alpha2,
    required this.alpha3,
    required this.name,
    required this.officialName,
    this.numeric,
    this.dialCode,
    this.currencyCodes = const [],
    this.languageCodes = const [],
    this.region,
    this.subregion,
    this.capitals = const [],
    this.tlds = const [],
    this.borderAlpha3Codes = const [],
    this.latitude,
    this.longitude,
    this.independent,
    this.unMember = false,
  });

  /// ISO 3166-1 alpha-2 code, always uppercase.
  ///
  /// Example: `US`, `PT`.
  final String alpha2;

  /// ISO 3166-1 alpha-3 code, always uppercase.
  ///
  /// Example: `USA`, `PRT`.
  final String alpha3;

  /// ISO 3166-1 numeric code as a zero-padded string, when assigned.
  ///
  /// Example: `840` for the United States. `null` for entities without an
  /// assigned numeric code (e.g. Kosovo).
  final String? numeric;

  /// Common country name in English.
  ///
  /// Example: `United States`, `Portugal`.
  final String name;

  /// Official country name in English.
  ///
  /// Example: `United States of America`, `Portuguese Republic`.
  final String officialName;

  /// International dialing prefix including the leading `+`.
  ///
  /// Example: `+1`, `+351`. `null` for territories without an assigned
  /// prefix (e.g. Antarctica).
  ///
  /// Countries inside a shared numbering plan (such as the NANP) report the
  /// shared root only (e.g. `+1` for both the United States and Canada).
  final String? dialCode;

  /// ISO 4217 codes of the currencies in official use.
  ///
  /// Example: `['USD']`, `['EUR']`.
  final List<String> currencyCodes;

  /// ISO 639-3 codes of the official languages.
  ///
  /// Example: `['eng']`, `['por']`.
  final List<String> languageCodes;

  /// Continental region per the UN M49 scheme.
  ///
  /// Example: `Americas`, `Europe`.
  final String? region;

  /// Subregion per the UN M49 scheme.
  ///
  /// Example: `North America`, `Southern Europe`.
  final String? subregion;

  /// Capital cities, in significance order. Usually one entry; a few
  /// countries have several (e.g. South Africa) and a few territories none.
  final List<String> capitals;

  /// Country-code top-level internet domains, including the leading dot.
  ///
  /// Example: `['.us']`, `['.uk']`.
  final List<String> tlds;

  /// ISO 3166-1 alpha-3 codes of the countries sharing a land border.
  ///
  /// Resolve to [Country] instances with the `neighbors` extension getter.
  final List<String> borderAlpha3Codes;

  /// Representative latitude of the country, in degrees.
  final double? latitude;

  /// Representative longitude of the country, in degrees.
  final double? longitude;

  /// Whether the entity is an independent state (as opposed to a dependent
  /// territory). `null` when the status is disputed or unrecorded.
  final bool? independent;

  /// Whether the entity is a member state of the United Nations.
  final bool unMember;

  /// The country flag as a Unicode emoji, derived from [alpha2] using
  /// regional indicator symbols.
  ///
  /// Example: 🇺🇸 for `US`.
  String get flagEmoji => String.fromCharCodes(
    alpha2.codeUnits.map((unit) => 0x1F1E6 + (unit - 0x41)),
  );

  /// Countries are identified by their [alpha2] code: two instances with the
  /// same code refer to the same country.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Country && other.alpha2 == alpha2);

  @override
  int get hashCode => alpha2.hashCode;

  @override
  String toString() => 'Country($alpha2, $name)';
}

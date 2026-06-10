import 'package:atlas_code/src/countries.dart';
import 'package:atlas_code/src/data/country_code.g.dart';
import 'package:atlas_code/src/data/currencies.g.dart';
import 'package:atlas_code/src/models/country.dart';
import 'package:atlas_code/src/models/currency.dart';

/// Lookups from a [Country] into the rest of the dataset.
extension CountryDataX on Country {
  /// The type-safe [CountryCode] for this country.
  CountryCode get code => CountryCode.values.byName(alpha2);

  /// The currencies in official use, resolved from [Country.currencyCodes].
  List<Currency> get currencies => [
    for (final code in currencyCodes) ?currenciesByCode[code],
  ];

  /// The countries sharing a land border, resolved from
  /// [Country.borderAlpha3Codes].
  List<Country> get neighbors => [
    for (final code in borderAlpha3Codes) ?Countries.fromAlpha3(code),
  ];
}

/// Dataset access from a [CountryCode].
extension CountryCodeX on CountryCode {
  /// The [Country] this code identifies.
  ///
  /// Non-nullable: every [CountryCode] value is generated from the same
  /// dataset as the countries themselves.
  Country get country => Countries.of(this);
}

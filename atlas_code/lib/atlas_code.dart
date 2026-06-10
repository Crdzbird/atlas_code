/// Country codes and metadata for every ISO 3166-1 country — alpha-2,
/// alpha-3 and numeric codes, dial codes, flag emojis, currencies and
/// regions — plus OS-localized country names.
library;

export 'src/atlas_code.dart' show AtlasCode;
export 'src/countries.dart' show Countries;
export 'src/data/country_code.g.dart' show CountryCode;
export 'src/extensions/country_extensions.dart' show CountryCodeX, CountryDataX;
export 'src/extensions/search_extensions.dart'
    show CountriesSearch, LocalizedCountryNamesSearch;
export 'src/extensions/string_extensions.dart' show DiacriticFoldingX;
export 'src/formatters/dial_code_formatter.dart' show DialCodeFormatter;
export 'src/models/country.dart' show Country;
export 'src/models/currency.dart' show Currency;
export 'src/models/localized_country_names.dart' show LocalizedCountryNames;

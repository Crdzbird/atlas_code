// Regenerates lib/src/data/countries.g.dart from the maintained
// mledoze/countries dataset.
//
// Usage:
//   dart run tool/generate_countries.dart [path/to/countries.json]
//
// When no path is given, the dataset is downloaded from GitHub.
import 'dart:convert';
import 'dart:io';

const _sourceUrl =
    'https://raw.githubusercontent.com/mledoze/countries/master/countries.json';
const _outputPath = 'lib/src/data/countries.g.dart';
const _codesOutputPath =
    '../atlas_code_platform_interface/lib/src/iso_alpha2_codes.dart';
const _currenciesOutputPath = 'lib/src/data/currencies.g.dart';
const _enumOutputPath = 'lib/src/data/country_code.g.dart';

/// Corrections applied on top of the upstream dataset, keyed by alpha-2
/// code. Each value is merged over the upstream entry.
///
/// Keep this list short and each entry justified.
const _overrides = <String, Map<String, dynamic>>{
  // Vatican City is a UN permanent observer, not a member; upstream
  // erroneously flags it as one (the UN has 193 members, all in this
  // dataset besides this entry).
  'VA': {'unMember': false},
};

Future<void> main(List<String> args) async {
  final raw = args.isNotEmpty
      ? File(args.first).readAsStringSync()
      : await _download(_sourceUrl);

  final entries =
      (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>()..sort(
        (a, b) => (a['cca2'] as String).compareTo(b['cca2'] as String),
      );

  final buffer = StringBuffer()
    ..writeln(_generatedHeader)
    ..writeln("import 'package:atlas_code/src/models/country.dart';")
    ..writeln()
    ..writeln(
      '/// Every ISO 3166-1 country and territory, '
      'sorted by alpha-2 code.',
    )
    ..writeln('const List<Country> allCountries = [');

  for (final entry in entries) {
    buffer.writeln(_countryLiteral(entry));
  }
  buffer.writeln('];');

  File(_outputPath).writeAsStringSync(buffer.toString());
  stdout.writeln('Wrote ${entries.length} countries to $_outputPath');

  _writeCodesFile(entries);
  _writeCurrenciesFile(entries);
  _writeEnumFile(entries);

  final format = Process.runSync('dart', [
    'format',
    _outputPath,
    _codesOutputPath,
    _currenciesOutputPath,
    _enumOutputPath,
  ]);
  if (format.exitCode != 0) {
    stderr.writeln('dart format failed: ${format.stderr}');
    exitCode = 1;
  }
}

/// Emits the deduplicated ISO 4217 currency table. When countries disagree
/// on a currency's name/symbol (cosmetic variants), the first occurrence in
/// alpha-2 order wins — which is the issuing country for every known case
/// (GB for GBP, DK for DKK, DZ for DZD).
void _writeCurrenciesFile(List<Map<String, dynamic>> entries) {
  final currencies = <String, (String, String)>{};
  for (final entry in entries) {
    final entryCurrencies =
        (entry['currencies'] as Map<String, dynamic>?) ?? const {};
    for (final MapEntry(key: code, value: info) in entryCurrencies.entries) {
      if (info is! Map<String, dynamic>) continue;
      currencies.putIfAbsent(
        code,
        () => (
          (info['name'] as String?) ?? code,
          (info['symbol'] as String?) ?? '',
        ),
      );
    }
  }

  final buffer = StringBuffer()
    ..writeln(_generatedHeader)
    ..writeln("import 'package:atlas_code/src/models/currency.dart';")
    ..writeln()
    ..writeln('/// Every ISO 4217 currency in use, keyed by code.')
    ..writeln('const Map<String, Currency> currenciesByCode = {');
  for (final code in currencies.keys.toList()..sort()) {
    final (name, symbol) = currencies[code]!;
    buffer.writeln(
      "  '$code': Currency(code: '$code', name: ${_str(name)}, "
      'symbol: ${_str(symbol)}),',
    );
  }
  buffer.writeln('};');
  File(_currenciesOutputPath).writeAsStringSync(buffer.toString());
  stdout.writeln(
    'Wrote ${currencies.length} currencies to $_currenciesOutputPath',
  );
}

/// Emits the `CountryCode` enum. Values use the uppercase ISO spelling
/// (`CountryCode.US`) because the lowercase codes of India, Iceland, the
/// Dominican Republic and American Samoa (`in`, `is`, `do`, `as`) are Dart
/// reserved words.
void _writeEnumFile(List<Map<String, dynamic>> entries) {
  final buffer = StringBuffer()
    ..writeln(_generatedHeader)
    ..writeln('// Uppercase ISO codes are intentional: see enum doc comment.')
    ..writeln('// ignore_for_file: constant_identifier_names')
    ..writeln()
    ..writeln('/// Type-safe ISO 3166-1 alpha-2 country codes.')
    ..writeln('///')
    ..writeln('/// Use with `Countries.of` for a non-nullable lookup, or')
    ..writeln('/// `code.country` directly.')
    ..writeln('enum CountryCode {');
  for (final entry in entries) {
    final code = entry['cca2'] as String;
    final name = (entry['name'] as Map<String, dynamic>)['common'] as String;
    buffer
      ..writeln('  /// $name')
      ..writeln('  $code,');
  }
  buffer.writeln('}');
  File(_enumOutputPath).writeAsStringSync(buffer.toString());
  stdout.writeln('Wrote ${entries.length} enum values to $_enumOutputPath');
}

const _generatedHeader =
    '''
// GENERATED CODE - DO NOT EDIT BY HAND
//
// Source: $_sourceUrl
// Regenerate with: dart run tool/generate_countries.dart
// ignore_for_file: lines_longer_than_80_chars, avoid_escaping_inner_quotes
// ignore_for_file: prefer_int_literals, use_raw_strings
''';

/// Emits the bare alpha-2 code list into the platform interface package so
/// implementations that must enumerate codes themselves (e.g. web, which
/// has no JS API for listing regions) share one source of truth.
void _writeCodesFile(List<Map<String, dynamic>> entries) {
  final codes = entries.map((e) => "'${e['cca2']}'").join(', ');
  File(_codesOutputPath).writeAsStringSync('''
// GENERATED CODE - DO NOT EDIT BY HAND
//
// Source: $_sourceUrl
// Regenerate with: dart run tool/generate_countries.dart (in atlas_code)

/// Every ISO 3166-1 alpha-2 code, for platform implementations that need
/// to enumerate regions themselves.
const List<String> isoAlpha2Codes = [$codes];
''');
  stdout.writeln('Wrote ${entries.length} codes to $_codesOutputPath');
}

String _countryLiteral(Map<String, dynamic> rawEntry) {
  final entry = {...rawEntry, ...?_overrides[rawEntry['cca2']]};
  final name = entry['name'] as Map<String, dynamic>;
  final idd = (entry['idd'] as Map<String, dynamic>?) ?? const {};
  final currencies =
      ((entry['currencies'] as Map<String, dynamic>?) ?? const {}).keys.toList()
        ..sort();
  final languages =
      ((entry['languages'] as Map<String, dynamic>?) ?? const {}).keys.toList()
        ..sort();

  final fields = <String>[
    "alpha2: '${entry['cca2']}'",
    "alpha3: '${entry['cca3']}'",
    'name: ${_str(name['common'] as String)}',
    'officialName: ${_str(name['official'] as String)}',
    if (_nonEmpty(entry['ccn3'] as String?) case final numeric?)
      "numeric: '$numeric'",
    if (_dialCode(idd) case final dial?) "dialCode: '$dial'",
    if (currencies.isNotEmpty)
      'currencyCodes: [${currencies.map((c) => "'$c'").join(', ')}]',
    if (languages.isNotEmpty)
      'languageCodes: [${languages.map((c) => "'$c'").join(', ')}]',
    if (_nonEmpty(entry['region'] as String?) case final region?)
      'region: ${_str(region)}',
    if (_nonEmpty(entry['subregion'] as String?) case final subregion?)
      'subregion: ${_str(subregion)}',
    if (_strList(entry['capital']) case final capitals?) 'capitals: $capitals',
    if (_strList(entry['tld']) case final tlds?) 'tlds: $tlds',
    if (_strList(entry['borders']) case final borders?)
      'borderAlpha3Codes: $borders',
    if (_latLng(entry['latlng']) case (final lat, final lng))
      'latitude: $lat, longitude: $lng',
    if (entry['independent'] case final bool independent)
      'independent: $independent',
    if (entry['unMember'] == true) 'unMember: true',
  ];

  return '  Country(${fields.join(', ')}),';
}

/// Dial code for an `idd` block: the root alone when the country shares a
/// numbering plan (multiple suffixes, e.g. NANP), root + suffix otherwise.
String? _dialCode(Map<String, dynamic> idd) {
  final root = _nonEmpty(idd['root'] as String?);
  if (root == null) return null;
  final suffixes = ((idd['suffixes'] as List<dynamic>?) ?? const [])
      .cast<String>();
  if (suffixes.length == 1) return '$root${suffixes.single}';
  return root;
}

String? _nonEmpty(String? value) =>
    (value == null || value.isEmpty) ? null : value;

/// A Dart list literal for a JSON string array, or `null` when empty.
String? _strList(Object? value) {
  final items = ((value as List<dynamic>?) ?? const []).cast<String>();
  if (items.isEmpty) return null;
  return '[${items.map(_str).join(', ')}]';
}

(String, String)? _latLng(Object? value) {
  final items = (value as List<dynamic>?) ?? const [];
  if (items.length != 2) return null;
  return ('${(items[0] as num).toDouble()}', '${(items[1] as num).toDouble()}');
}

String _str(String value) {
  final escaped = value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$');
  return "'$escaped'";
}

Future<String> _download(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('GET $url returned ${response.statusCode}');
    }
    return response.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}

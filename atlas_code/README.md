# atlas_code

Country codes and metadata for every ISO 3166-1 country and territory —
alpha-2 / alpha-3 / numeric codes, dial codes, flag emojis, currencies and
regions — plus country names localized by the operating system.

A modern, federated successor to the abandoned
[`country_codes`](https://pub.dev/packages/country_codes) package.

## Highlights

- **No `init()`** — all static data is compile-time `const` and available
  synchronously. Only OS-localized names are async.
- **Typed model** — `Country` with `alpha2`, `alpha3`, `numeric`, `dialCode`,
  `flagEmoji`, currencies, capitals, TLDs, borders, coordinates, `region`,
  `subregion`, `unMember`, and more.
- **Type-safe codes** — a generated `CountryCode` enum
  (`CountryCode.US.country`) so you never pass a typo'd string.
- **O(1), case-insensitive, non-throwing lookups** — unknown codes return
  `null`, never crash (and enum lookups are non-nullable).
- **All six platforms** — Android, iOS, macOS, web, Windows, Linux.
  Localized names use OS CLDR data on Android/iOS/macOS/web and fall back to
  bundled English names on Windows/Linux (clearly flagged via `isFallback`).
- **Maintained dataset** — generated from
  [mledoze/countries](https://github.com/mledoze/countries) with a
  one-command regeneration script, so the data can't rot.

## Static data — synchronous, no setup

```dart
import 'package:atlas_code/atlas_code.dart';

final us = Countries.fromAlpha2('us')!;       // case-insensitive
us.alpha3;        // 'USA'
us.numeric;       // '840'
us.dialCode;      // '+1'
us.flagEmoji;     // 🇺🇸
us.currencyCodes; // ['USD']
us.subregion;     // 'North America'

Countries.fromAlpha3('PRT');   // Portugal
Countries.fromNumeric('40');   // Austria (zero-padding optional)
Countries.fromCode('840');     // any code system, auto-detected
Countries.withDialCode('+1');  // [US, CA, ...] — whole NANP
Countries.all;                 // all 250, sorted by alpha-2
Countries.unMembers;           // the 193 UN member states

// The device's region, synchronously — no init() needed:
final here = Countries.current;          // Country? from the platform locale
final ptCountry = Countries.forLocale(const Locale('pt', 'PT'));
```

Deprecated region codes some devices still report (`YU`, `AN`, `TP`, …) are
transparently remapped to their current equivalents.

## Type-safe country codes

```dart
final us = CountryCode.US.country;       // non-nullable
final same = Countries.of(CountryCode.US);
us.code;                                  // CountryCode.US

// India, Iceland, the Dominican Republic and American Samoa use uppercase
// like every other value because `in`, `is`, `do`, `as` are Dart keywords:
CountryCode.IN.country.name;              // 'India'
```

## Richer metadata

```dart
final pt = CountryCode.PT.country;
pt.capitals;            // ['Lisbon']
pt.tlds;                // ['.pt']
pt.neighbors;           // [Spain]
pt.latitude;            // 39.5
pt.currencies;          // [Currency(EUR, Euro)] — code, name and symbol

Countries.currency('EUR');     // Currency(EUR, Euro, €)
Countries.byCurrency('EUR');   // the whole eurozone
```

## Who's calling? Phone-prefix lookup

```dart
Countries.byPhoneNumber('+1 684 555 0100'); // [American Samoa] (+1684 beats +1)
Countries.byPhoneNumber('+1 212 555 0100'); // [US, CA, …] — the NANP shares +1
Countries.byPhoneNumber('00351 912 345 678'); // [Portugal]
```

Longest-prefix matching over international numbers (`+` or `00`). Shared
numbering plans legitimately return several countries — full number
validation is out of scope (use libphonenumber for that).

## Search and sorting for pickers

```dart
final names = await AtlasCode().localizedNames(locale: const Locale('es'));
names.search('espana');     // finds España — diacritic- and case-insensitive,
                            // also matches English names, codes, dial codes
names.sortedCountries();    // alphabetical by localized name
country.matches('spain');   // English-only variant, no async needed
```

## Reacting to system locale changes

```dart
final atlas = AtlasCode();
atlas.deviceLocaleChanges.listen((locale) { /* re-fetch localized names */ });
atlas.deviceCountryChanges.listen((country) { /* region changed */ });
```

## Flags on Windows

Windows ships no flag emoji font, so `flagEmoji` renders as letter pairs
there (including web apps running on Windows). Check
`Countries.flagEmojiSupported` to decide between the emoji and a custom
asset.

## OS-localized country names — async

```dart
final atlas = AtlasCode();

// Device language by default, or pass a locale:
final names = await atlas.localizedNames(locale: const Locale('pt'));
names.of(us);            // 'Estados Unidos'
names['DE'];             // 'Alemanha'
names.isFallback;        // true when the OS had no data (bundled English used)

await atlas.localizedNameOf(us, locale: const Locale('it')); // 'Stati Uniti'
```

Results are cached per language tag. Any code the OS doesn't know is filled
with the bundled English name, so lookups are total.

| Platform | Source of localized names |
| --- | --- |
| Android | `java.util.Locale` (ICU/CLDR) |
| iOS / macOS | `Locale.localizedString(forRegionCode:)` |
| Web | `Intl.DisplayNames` |
| Windows / Linux | bundled English names (`isFallback == true`) |

## Phone-field dial code prefix

```dart
TextFormField(
  keyboardType: TextInputType.phone,
  inputFormatters: [
    DialCodeFormatter.forCountry(Countries.fromAlpha2('PT')!), // '+351 '
  ],
);
```

The formatter survives paste, select-all-delete and edits inside the prefix,
and replaces pasted foreign dial codes while keeping the subscriber digits.

## Migrating from `country_codes`

| `country_codes` | `atlas_code` |
| --- | --- |
| `await CountryCodes.init()` | not needed |
| `CountryCodes.getDeviceLocale()` | `AtlasCode().deviceLocale` |
| `CountryCodes.detailsForLocale()` | `Countries.current` / `Countries.forLocale(...)` |
| `CountryCodes.detailsFromAlpha2('US')` | `Countries.fromAlpha2('US')` |
| `CountryCodes.alpha2Code()` | `Countries.current?.alpha2` |
| `CountryCodes.dialCode()` | `Countries.current?.dialCode` |
| `CountryCodes.name(locale: l)` | `await AtlasCode().localizedNames(locale: l)` |
| `details.localizedName` | `names.of(country)` |
| `DialCodeFormatter()` | `DialCodeFormatter.forCountry(...)` (explicit country, no globals) |

## Regenerating the dataset

```sh
cd atlas_code
dart run tool/generate_countries.dart        # fetches the latest upstream data
```

The script also regenerates the shared alpha-2 code list used by the web
implementation. Factual corrections on top of upstream live in the script's
`_overrides` map.

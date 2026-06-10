# 0.1.0

Initial release.

- Bundled dataset of all 250 ISO 3166-1 countries and territories, generated
  from [mledoze/countries](https://github.com/mledoze/countries):
  alpha-2/alpha-3/numeric codes, dial codes, currencies, languages,
  regions/subregions, capitals, TLDs, land borders, coordinates,
  independence and UN membership.
- `Countries`: synchronous, O(1), case-insensitive, non-throwing lookups —
  `fromAlpha2/3`, `fromNumeric`, `fromCode`, `withDialCode`, `forLocale`,
  `current`, `byCurrency`, plus deprecated-region-code remapping.
- Generated `CountryCode` enum for type-safe, non-nullable lookups
  (`Countries.of`, `code.country`).
- `Currency` type with `Countries.currency` and `country.currencies`.
- `Countries.byPhoneNumber`: longest-prefix country resolution for
  international phone numbers, shared-numbering-plan aware.
- OS-localized country names via `AtlasCode.localizedNames`, with bundled
  English fallback flagged by `isFallback` and per-language caching.
- Locale reactivity: `deviceLocaleChanges` / `deviceCountryChanges` streams.
- Diacritic-insensitive `search`/`sortedCountries` helpers and a
  `foldedDiacritics` String extension.
- `country.flagEmoji` derived from regional indicators, with
  `Countries.flagEmojiSupported` for platforms without flag emoji fonts.
- `DialCodeFormatter` that enforces a dial-code prefix and survives paste
  and in-prefix edits.

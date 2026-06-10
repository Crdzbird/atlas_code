# atlas_code

A federated Flutter plugin providing country codes and metadata for every
ISO 3166-1 country and territory — alpha-2 / alpha-3 / numeric codes, dial
codes, flag emojis, currencies and regions — plus OS-localized country names.

A modern successor to the abandoned
[`country_codes`](https://pub.dev/packages/country_codes) package.
See [`atlas_code/README.md`](atlas_code/README.md) for usage.

## Packages

| Package | Role |
| --- | --- |
| [`atlas_code`](atlas_code) | App-facing API: `Countries`, `Country`, `AtlasCode`, `DialCodeFormatter` and the bundled dataset |
| [`atlas_code_platform_interface`](atlas_code_platform_interface) | The shared contract platform implementations fulfill |
| [`atlas_code_android`](atlas_code_android) | Android — localized names via `java.util.Locale` (Pigeon + Kotlin) |
| [`atlas_code_ios`](atlas_code_ios) | iOS — localized names via `Locale.localizedString(forRegionCode:)` (Pigeon + Swift) |
| [`atlas_code_macos`](atlas_code_macos) | macOS — same as iOS |
| [`atlas_code_web`](atlas_code_web) | Web — localized names via `Intl.DisplayNames` |
| [`atlas_code_windows`](atlas_code_windows) | Windows — Dart-only; bundled English fallback |
| [`atlas_code_linux`](atlas_code_linux) | Linux — Dart-only; bundled English fallback |

Only the *localized country names* feature touches platform code; all other
data is pure-Dart `const` and identical on every platform.

## Development

```sh
# Regenerate the bundled dataset from upstream (mledoze/countries):
cd atlas_code && dart run tool/generate_countries.dart

# Regenerate Pigeon bindings after changing a pigeons/messages.dart:
cd atlas_code_android && dart run pigeon --input pigeons/messages.dart

# Run all tests:
for pkg in atlas_code atlas_code_platform_interface atlas_code_android \
           atlas_code_ios atlas_code_macos atlas_code_windows atlas_code_linux; do
  (cd "$pkg" && flutter test)
done
(cd atlas_code_web && flutter test --platform chrome)
```

## Integration tests 🧪

Integration tests live in the `atlas_code/example` app:

```sh
cd atlas_code/example
flutter test integration_test   # on a connected device / simulator
fluttium test flows/search_country.yaml   # requires fluttium_cli
```

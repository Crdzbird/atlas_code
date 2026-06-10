import 'dart:async';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:atlas_code/src/countries.dart';
import 'package:atlas_code/src/data/countries.g.dart';
import 'package:atlas_code/src/models/country.dart';
import 'package:atlas_code/src/models/localized_country_names.dart';
import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/widgets.dart'
    show WidgetsBinding, WidgetsBindingObserver;

/// {@template atlas_code}
/// Entry point for the platform-backed features of the plugin: country
/// names localized by the operating system.
///
/// All static country data (codes, dial codes, flags, currencies) is
/// available synchronously through `Countries` without creating an
/// [AtlasCode] instance.
/// {@endtemplate}
class AtlasCode {
  /// {@macro atlas_code}
  AtlasCode({@visibleForTesting this._platform});

  final AtlasCodePlatform? _platform;

  AtlasCodePlatform get _effectivePlatform =>
      _platform ?? AtlasCodePlatform.instance;

  final Map<String, LocalizedCountryNames> _cache = {};

  static final Map<String, String> _englishNames = {
    for (final country in allCountries) country.alpha2: country.name,
  };

  /// The device locale as reported by the platform, available synchronously.
  Locale get deviceLocale => PlatformDispatcher.instance.locale;

  StreamController<Locale>? _localeController;
  _LocaleObserver? _localeObserver;

  /// Emits the new primary device locale whenever the user changes the
  /// system language or region while the app is running.
  ///
  /// Requires an initialized widgets binding (`runApp`, or
  /// `WidgetsFlutterBinding.ensureInitialized()`). The underlying observer
  /// is registered on first listen and removed when the last subscription
  /// is cancelled.
  Stream<Locale> get deviceLocaleChanges {
    final controller = _localeController ??= StreamController.broadcast(
      onListen: () {
        final observer = _localeObserver = _LocaleObserver(
          (locale) => _localeController!.add(locale),
        );
        WidgetsBinding.instance.addObserver(observer);
      },
      onCancel: () {
        if (_localeObserver case final observer?) {
          WidgetsBinding.instance.removeObserver(observer);
          _localeObserver = null;
        }
      },
    );
    return controller.stream;
  }

  /// Emits the device's country whenever a system locale change moves it
  /// to a different region. `null` when the new locale carries no
  /// recognizable region.
  Stream<Country?> get deviceCountryChanges =>
      deviceLocaleChanges.map(Countries.forLocale).distinct();

  /// Country display names localized to [locale], or to the device locale
  /// when omitted.
  ///
  /// Uses the operating system's locale data (CLDR) where the platform
  /// provides it. When it doesn't — or the platform call fails — the result
  /// falls back to the bundled English names and is marked with
  /// [LocalizedCountryNames.isFallback].
  ///
  /// Results are cached per language tag for the lifetime of this instance.
  Future<LocalizedCountryNames> localizedNames({Locale? locale}) async {
    final tag = (locale ?? deviceLocale).toLanguageTag();
    final cached = _cache[tag];
    if (cached != null) return cached;

    var platformNames = const <String, String>{};
    try {
      platformNames = await _effectivePlatform.localizedCountryNames(tag);
    } on Exception {
      // Treat any platform failure as "no localization data" — the bundled
      // English names below keep the API total.
      platformNames = const {};
    }

    final result = platformNames.isEmpty
        ? LocalizedCountryNames(
            languageTag: tag,
            names: _englishNames,
            isFallback: true,
          )
        : LocalizedCountryNames(
            languageTag: tag,
            // Platform names win; bundled English fills any code the OS
            // doesn't know so lookups stay total.
            names: {..._englishNames, ...platformNames},
            isFallback: false,
          );
    _cache[tag] = result;
    return result;
  }

  /// The localized display name for a single [country].
  ///
  /// Convenience over [localizedNames] — same locale resolution, caching
  /// and fallback behavior.
  Future<String> localizedNameOf(Country country, {Locale? locale}) async {
    final names = await localizedNames(locale: locale);
    return names.of(country);
  }
}

class _LocaleObserver with WidgetsBindingObserver {
  _LocaleObserver(this._onLocaleChanged);

  final void Function(Locale locale) _onLocaleChanged;

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (locales case [final primary, ...]) _onLocaleChanged(primary);
  }
}

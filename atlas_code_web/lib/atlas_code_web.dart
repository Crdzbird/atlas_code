import 'dart:js_interop';

import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';

/// Binding to the browser's `Intl.DisplayNames` API.
@JS('Intl.DisplayNames')
extension type _IntlDisplayNames._(JSObject _) implements JSObject {
  external _IntlDisplayNames(JSArray<JSString> locales, JSObject options);

  /// The localized display name for [code], or `null` when unknown
  /// (requires `fallback: 'none'` in the constructor options).
  @JS('of')
  external String? regionName(String code);
}

extension type _DisplayNamesOptions._(JSObject _) implements JSObject {
  external factory _DisplayNamesOptions({String type, String fallback});
}

/// The Web implementation of [AtlasCodePlatform], backed by the browser's
/// `Intl.DisplayNames` API (CLDR data shipped with the browser).
class AtlasCodeWeb extends AtlasCodePlatform {
  /// Registers this class as the default instance of [AtlasCodePlatform].
  static void registerWith([Object? registrar]) {
    AtlasCodePlatform.instance = AtlasCodeWeb();
  }

  @override
  Future<Map<String, String>> localizedCountryNames(String languageTag) async {
    final _IntlDisplayNames displayNames;
    try {
      displayNames = _IntlDisplayNames(
        [languageTag.toJS].toJS,
        _DisplayNamesOptions(type: 'region', fallback: 'none'),
      );
    } on Object {
      // Intl.DisplayNames unsupported by this browser, or the tag is not a
      // structurally valid BCP-47 tag — report no data so the core package
      // falls back to bundled English names.
      return const {};
    }

    return {
      for (final code in isoAlpha2Codes)
        if (displayNames.regionName(code) case final name?
            when name.isNotEmpty && name != code)
          code: name,
    };
  }
}

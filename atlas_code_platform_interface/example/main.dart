import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';

/// A platform implementation extends [AtlasCodePlatform] and registers
/// itself as the default instance, returning OS localized country display
/// names keyed by uppercase ISO 3166-1 alpha-2 code.
final class _ExampleAtlasCode extends AtlasCodePlatform {
  @override
  Future<Map<String, String>> localizedCountryNames(String languageTag) async {
    return {for (final code in isoAlpha2Codes) code: 'Name of $code'};
  }
}

Future<void> main() async {
  AtlasCodePlatform.instance = _ExampleAtlasCode();
  final names =
      await AtlasCodePlatform.instance.localizedCountryNames('en-US');
  assert(names.containsKey('US'), 'every implementation covers all codes');
}

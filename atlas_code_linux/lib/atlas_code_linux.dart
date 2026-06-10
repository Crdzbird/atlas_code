import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';

/// {@template atlas_code_linux}
/// The Linux implementation of [AtlasCodePlatform].
///
/// Linux has no system CLDR display-name API that can be relied on across
/// distributions, so this implementation reports no localization data and
/// the core package serves its bundled English names instead. Lookups,
/// dial codes, flags and all other static data work exactly as on the
/// other platforms.
/// {@endtemplate}
class AtlasCodeLinux extends AtlasCodePlatform {
  /// Registers this class as the default instance of [AtlasCodePlatform].
  static void registerWith() {
    AtlasCodePlatform.instance = AtlasCodeLinux();
  }

  @override
  Future<Map<String, String>> localizedCountryNames(String languageTag) async {
    return const {};
  }
}

import 'package:atlas_code_linux/atlas_code_linux.dart';

/// This package is an endorsed implementation of the atlas_code plugin:
/// apps depend on atlas_code and this package is included automatically.
/// It reports no localization data, so the app facing package serves its
/// bundled English names instead.
Future<void> main() async {
  AtlasCodeLinux.registerWith();
  final names = await AtlasCodeLinux().localizedCountryNames('en');
  assert(names.isEmpty, 'the app facing package falls back to English');
}

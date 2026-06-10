import 'package:atlas_code_windows/atlas_code_windows.dart';

/// This package is an endorsed implementation of the atlas_code plugin:
/// apps depend on atlas_code and this package is included automatically.
/// It reports no localization data, so the app facing package serves its
/// bundled English names instead.
Future<void> main() async {
  AtlasCodeWindows.registerWith();
  final names = await AtlasCodeWindows().localizedCountryNames('en');
  assert(names.isEmpty, 'the app facing package falls back to English');
}

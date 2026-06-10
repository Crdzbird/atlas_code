import 'package:atlas_code_macos/atlas_code_macos.dart';

/// This package is an endorsed implementation of the atlas_code plugin:
/// apps depend on atlas_code and this package is included automatically.
/// Direct use looks like this.
Future<void> main() async {
  AtlasCodeMacOS.registerWith();
  final names = await AtlasCodeMacOS().localizedCountryNames('pt');
  assert(names.isNotEmpty, 'OS locale data localizes the country names');
}

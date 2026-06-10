import 'package:atlas_code_ios/atlas_code_ios.dart';

/// This package is an endorsed implementation of the atlas_code plugin:
/// apps depend on atlas_code and this package is included automatically.
/// Direct use looks like this.
Future<void> main() async {
  AtlasCodeIOS.registerWith();
  final names = await AtlasCodeIOS().localizedCountryNames('pt');
  assert(names.isNotEmpty, 'OS locale data localizes the country names');
}

import 'package:atlas_code_web/atlas_code_web.dart';

/// This package is an endorsed implementation of the atlas_code plugin:
/// apps depend on atlas_code and this package is included automatically.
/// Direct use looks like this.
Future<void> main() async {
  AtlasCodeWeb.registerWith();
  final names = await AtlasCodeWeb().localizedCountryNames('pt');
  assert(names.isNotEmpty, 'OS locale data localizes the country names');
}

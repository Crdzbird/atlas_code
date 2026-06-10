import 'package:atlas_code_android/atlas_code_android.dart';

/// This package is an endorsed implementation of the atlas_code plugin:
/// apps depend on atlas_code and this package is included automatically.
/// Direct use looks like this.
Future<void> main() async {
  AtlasCodeAndroid.registerWith();
  final names = await AtlasCodeAndroid().localizedCountryNames('pt');
  assert(names.isNotEmpty, 'OS locale data localizes the country names');
}

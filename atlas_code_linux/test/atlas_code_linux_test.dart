import 'package:atlas_code_linux/atlas_code_linux.dart';
import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(AtlasCodeLinux, () {
    test('can be registered', () {
      AtlasCodeLinux.registerWith();
      expect(AtlasCodePlatform.instance, isA<AtlasCodeLinux>());
    });

    test('localizedCountryNames reports no data so core falls back', () async {
      final names = await AtlasCodeLinux().localizedCountryNames('en');
      expect(names, isEmpty);
    });
  });
}

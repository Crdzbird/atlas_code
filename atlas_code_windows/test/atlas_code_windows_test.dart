import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';
import 'package:atlas_code_windows/atlas_code_windows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(AtlasCodeWindows, () {
    test('can be registered', () {
      AtlasCodeWindows.registerWith();
      expect(AtlasCodePlatform.instance, isA<AtlasCodeWindows>());
    });

    test('localizedCountryNames reports no data so core falls back', () async {
      final names = await AtlasCodeWindows().localizedCountryNames('en');
      expect(names, isEmpty);
    });
  });
}

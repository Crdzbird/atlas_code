@TestOn('browser')
library;

import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';
import 'package:atlas_code_web/atlas_code_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AtlasCodeWeb', () {
    late AtlasCodeWeb atlasCode;

    setUp(() {
      atlasCode = AtlasCodeWeb();
    });

    test('can be registered', () {
      AtlasCodeWeb.registerWith();
      expect(AtlasCodePlatform.instance, isA<AtlasCodeWeb>());
    });

    test('localizedCountryNames localizes via Intl.DisplayNames', () async {
      final names = await atlasCode.localizedCountryNames('pt');
      expect(names['US'], 'Estados Unidos');
      expect(names['DE'], 'Alemanha');
    });

    test('localizedCountryNames covers the full code list in English',
        () async {
      final names = await atlasCode.localizedCountryNames('en');
      expect(names['US'], 'United States');
      expect(names.length, greaterThan(200));
    });

    test('returns an empty map for a malformed language tag', () async {
      final names = await atlasCode.localizedCountryNames('not a tag!!');
      expect(names, isEmpty);
    });
  });
}

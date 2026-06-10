import 'package:atlas_code_ios/atlas_code_ios.dart';
import 'package:atlas_code_ios/src/messages.g.dart';
import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAtlasCodeApi extends Mock implements AtlasCodeApi {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(AtlasCodeIOS, () {
    const kNames = {'US': 'Estados Unidos', 'PT': 'Portugal'};
    late AtlasCodeIOS atlasCode;
    late AtlasCodeApi api;

    setUp(() {
      api = _MockAtlasCodeApi();
      atlasCode = AtlasCodeIOS(api: api);
    });

    test('can be registered', () {
      AtlasCodeIOS.registerWith();
      expect(AtlasCodePlatform.instance, isA<AtlasCodeIOS>());
    });

    test('localizedCountryNames forwards the language tag', () async {
      when(() => api.localizedCountryNames(any()))
          .thenAnswer((_) async => kNames);

      await expectLater(
        atlasCode.localizedCountryNames('es'),
        completion(equals(kNames)),
      );

      verify(() => api.localizedCountryNames('es')).called(1);
    });
  });
}

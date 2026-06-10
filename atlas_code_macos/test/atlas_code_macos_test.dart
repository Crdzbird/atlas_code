import 'package:atlas_code_macos/atlas_code_macos.dart';
import 'package:atlas_code_macos/src/messages.g.dart';
import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAtlasCodeApi extends Mock implements AtlasCodeApi {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(AtlasCodeMacOS, () {
    const kNames = {'US': 'Estados Unidos', 'PT': 'Portugal'};
    late AtlasCodeMacOS atlasCode;
    late AtlasCodeApi api;

    setUp(() {
      api = _MockAtlasCodeApi();
      atlasCode = AtlasCodeMacOS(api: api);
    });

    test('can be registered', () {
      AtlasCodeMacOS.registerWith();
      expect(AtlasCodePlatform.instance, isA<AtlasCodeMacOS>());
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

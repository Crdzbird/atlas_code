import 'package:atlas_code_android/atlas_code_android.dart';
import 'package:atlas_code_android/src/messages.g.dart';
import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAtlasCodeApi extends Mock implements AtlasCodeApi {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(AtlasCodeAndroid, () {
    const kNames = {'US': 'United States', 'DE': 'Deutschland'};
    late AtlasCodeAndroid atlasCode;
    late AtlasCodeApi api;

    setUp(() {
      api = _MockAtlasCodeApi();
      atlasCode = AtlasCodeAndroid(api: api);
    });

    test('can be registered', () {
      AtlasCodeAndroid.registerWith();
      expect(AtlasCodePlatform.instance, isA<AtlasCodeAndroid>());
    });

    test('localizedCountryNames forwards the language tag', () async {
      when(() => api.localizedCountryNames(any()))
          .thenAnswer((_) async => kNames);

      await expectLater(
        atlasCode.localizedCountryNames('de-DE'),
        completion(equals(kNames)),
      );

      verify(() => api.localizedCountryNames('de-DE')).called(1);
    });
  });
}

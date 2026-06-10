import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class AtlasCodeMock extends AtlasCodePlatform {
  static const mockNames = {'US': 'Estados Unidos'};

  @override
  Future<Map<String, String>> localizedCountryNames(
    String languageTag,
  ) async =>
      mockNames;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AtlasCodePlatform defaultInstance;

  setUpAll(() {
    defaultInstance = AtlasCodePlatform.instance;
  });

  test('default instance is MethodChannelAtlasCode', () {
    expect(defaultInstance, isA<MethodChannelAtlasCode>());
  });

  group('AtlasCodePlatformInterface', () {
    setUp(() {
      AtlasCodePlatform.instance = AtlasCodeMock();
    });

    group('localizedCountryNames', () {
      test('returns the implementation result', () async {
        expect(
          await AtlasCodePlatform.instance.localizedCountryNames('es'),
          equals(AtlasCodeMock.mockNames),
        );
      });
    });
  });
}
